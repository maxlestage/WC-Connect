import SwiftUI

struct WatchHistoryView: View {
    @EnvironmentObject private var store: SessionStore

    var body: some View {
        List {
            if store.sessions.isEmpty {
                Text("Aucune visite")
                    .foregroundStyle(.secondary)
            }
            ForEach(store.sessions.prefix(20)) { session in
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Image(systemName: session.kind.symbol)
                            .foregroundStyle(WCTheme.color(for: session.kind))
                        Text(WCFormat.duration(session.finalDuration ?? 0))
                            .font(.body.weight(.semibold))
                            .monospacedDigit()
                    }
                    Text("\(WCFormat.dayHeader(session.startedAt)) · \(WCFormat.time(session.startedAt))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        store.delete(session)
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .navigationTitle("Historique")
    }
}
