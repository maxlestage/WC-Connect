import SwiftUI

/// Tuile de statistique (valeur + libellé).
struct StatTile: View {
    let value: String
    let label: String
    let symbol: String
    var color: Color = WCTheme.accent

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: symbol)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(color)
            Text(value)
                .font(.title3.weight(.semibold))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2, reservesSpace: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

/// Étoiles de confort, éditables ou en lecture seule.
struct ComfortRating: View {
    @Binding var value: Int
    var editable = true

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...5, id: \.self) { index in
                Image(systemName: index <= value ? "star.fill" : "star")
                    .foregroundStyle(index <= value ? WCTheme.warn : Color.secondary)
                    .onTapGesture {
                        guard editable else { return }
                        value = (value == index) ? 0 : index
                    }
                    .accessibilityLabel("%@ sur 5".wcLocalized(String(index)))
            }
        }
        .font(.title3)
    }
}

/// Ligne d'historique.
struct SessionRow: View {
    let session: ToiletSession

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: session.kind.symbol)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 34, height: 34)
                .background(WCTheme.color(for: session.kind), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(WCFormat.duration(session.finalDuration ?? session.duration()))
                    .font(.body.weight(.semibold))
                    .monospacedDigit()
                HStack(spacing: 6) {
                    Text(WCFormat.time(session.startedAt))
                    Text("·")
                    Label(session.place.title, systemImage: session.place.symbol)
                        .labelStyle(.titleAndIcon)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            if session.needsAdvice {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(WCTheme.warn)
                    .accessibilityLabel("Symptôme à signaler")
            }

            if let comfort = session.comfort, comfort > 0 {
                HStack(spacing: 2) {
                    Text("\(comfort)")
                    Image(systemName: "star.fill")
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(WCTheme.warn)
            }
        }
        .padding(.vertical, 2)
    }
}

extension SessionStore {
    /// Jeu de données pour les aperçus SwiftUI.
    @MainActor
    static var preview: SessionStore {
        let store = SessionStore(
            storage: SessionStorage(
                fileURL: URL(fileURLWithPath: NSTemporaryDirectory())
                    .appendingPathComponent("wc-preview-\(UUID().uuidString).json")
            )
        )
        let now = Date()
        for day in 0..<6 {
            for visit in 0..<(2 + day % 2) {
                let start = now.addingTimeInterval(Double(-day) * 86_400 - Double(visit) * 12_000)
                store.add(
                    ToiletSession(
                        startedAt: start,
                        endedAt: start.addingTimeInterval(Double(120 + visit * 90 + day * 20)),
                        kind: SessionKind.allCases[(day + visit) % 3],
                        place: Place.allCases[(day + visit) % 3],
                        comfort: 3 + (visit % 3) - 1,
                        source: visit.isMultiple(of: 2) ? .phone : .watch
                    )
                )
            }
        }
        return store
    }
}
