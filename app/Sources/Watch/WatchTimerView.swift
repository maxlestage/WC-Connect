import SwiftUI
import WatchKit

/// Écran principal de la montre : démarrer/terminer une visite au poignet.
struct WatchTimerView: View {
    @EnvironmentObject private var store: SessionStore

    @AppStorage("defaultKind", store: AppGroup.defaults) private var defaultKindRaw = SessionKind.standard.rawValue
    @AppStorage("defaultPlace", store: AppGroup.defaults) private var defaultPlaceRaw = Place.home.rawValue
    @AppStorage("hapticsEnabled", store: AppGroup.defaults) private var hapticsEnabled = true

    private var kind: SessionKind { SessionKind(rawValue: defaultKindRaw) ?? .standard }
    private var place: Place { Place(rawValue: defaultPlaceRaw) ?? .home }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    let session = store.active
                    let elapsed = session?.duration(now: context.date) ?? 0
                    let color = WCTheme.color(for: session?.kind ?? kind)

                    ZStack {
                        ProgressRing(
                            progress: elapsed / max((session?.kind ?? kind).goal, 1),
                            color: color,
                            lineWidth: 10
                        )
                        VStack(spacing: 2) {
                            Text(session == nil ? "Prêt" : WCFormat.clock(elapsed))
                                .font(.system(size: 26, weight: .semibold, design: .rounded))
                                .monospacedDigit()
                                .minimumScaleFactor(0.6)
                                .lineLimit(1)
                            Text(session == nil ? "\(kind.title) · \(place.title)" : (session?.place.title ?? ""))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(height: 120)
                }

                if store.active == nil {
                    Button {
                        store.start(kind: kind, place: place, source: .watch)
                        haptic(.start)
                    } label: {
                        Label("Démarrer", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Picker("Type", selection: $defaultKindRaw) {
                        ForEach(SessionKind.allCases, id: \.rawValue) { value in
                            Text(value.title).tag(value.rawValue)
                        }
                    }
                    .pickerStyle(.navigationLink)

                    Picker("Lieu", selection: $defaultPlaceRaw) {
                        ForEach(Place.allCases, id: \.rawValue) { value in
                            Text(value.title).tag(value.rawValue)
                        }
                    }
                    .pickerStyle(.navigationLink)
                } else {
                    Button {
                        store.stop()
                        haptic(.success)
                    } label: {
                        Label("Terminer", systemImage: "checkmark")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    Button(role: .destructive) {
                        store.cancel()
                        haptic(.failure)
                    } label: {
                        Label("Annuler", systemImage: "xmark")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.horizontal, 4)
        }
        .navigationTitle("WC Connect")
    }

    private func haptic(_ type: WKHapticType) {
        guard hapticsEnabled else { return }
        WKInterfaceDevice.current().play(type)
    }
}
