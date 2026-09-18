import SwiftUI
import WatchKit

/// Respiration guidée au poignet : le cercle suit le rythme et un tapotement
/// marque chaque changement de phase, ce qui permet de garder les yeux fermés.
struct WatchBreathingView: View {
    @AppStorage("hapticsEnabled", store: AppGroup.defaults) private var hapticsEnabled = true

    private let pattern = BreathingPattern.belly

    @State private var startedAt: Date?

    var body: some View {
        VStack(spacing: 8) {
            if let startedAt {
                session(from: startedAt)
            } else {
                intro
            }
        }
        .navigationTitle("Respirer")
    }

    private var intro: some View {
        VStack(spacing: 10) {
            Image(systemName: "wind")
                .font(.title2)
                .foregroundStyle(WCTheme.accent)
            Text(pattern.title)
                .font(.headline)
            Text("Sans apnée, %@".wcLocalized(WCFormat.duration(pattern.totalDuration)))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                startedAt = Date()
                haptic(.start)
            } label: {
                Label("Commencer", systemImage: "play.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private func session(from start: Date) -> some View {
        TimelineView(.periodic(from: .now, by: 1.0 / 10.0)) { context in
            let state = pattern.state(at: context.date.timeIntervalSince(start))

            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(WCTheme.accent.opacity(0.18))
                    Circle()
                        .fill(WCTheme.accent.opacity(0.35))
                        .scaleEffect(state.scale)
                    VStack(spacing: 0) {
                        Text(state.isFinished ? "Terminé" : state.phase.title)
                            .font(.caption.weight(.semibold))
                        if !state.isFinished {
                            Text("\(Int(state.phaseRemaining.rounded(.up)))")
                                .font(.system(size: 26, weight: .semibold, design: .rounded))
                                .monospacedDigit()
                        }
                    }
                }
                .frame(height: 104)

                Button {
                    startedAt = state.isFinished ? Date() : nil
                } label: {
                    Text(state.isFinished ? "Recommencer" : "Arrêter")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .onChange(of: state.phase) { _, _ in
                haptic(.click)
            }
            .onChange(of: state.isFinished) { _, isFinished in
                if isFinished { haptic(.success) }
            }
        }
    }

    private func haptic(_ type: WKHapticType) {
        guard hapticsEnabled else { return }
        WKInterfaceDevice.current().play(type)
    }
}
