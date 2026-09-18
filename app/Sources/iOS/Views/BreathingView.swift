import SwiftUI

/// Exercice de respiration guidée : cercle animé, décompte et rappel de ne
/// jamais bloquer son souffle.
struct BreathingView: View {
    let pattern: BreathingPattern

    @Environment(\.dismiss) private var dismiss
    @State private var startedAt: Date?
    @State private var finished = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if let startedAt {
                    running(from: startedAt)
                } else {
                    intro
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: [WCTheme.accent.opacity(0.18), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle(pattern.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fermer") { dismiss() }
                }
            }
        }
    }

    // MARK: - Avant le départ

    private var intro: some View {
        VStack(spacing: 20) {
            Image(systemName: "wind")
                .font(.system(size: 54))
                .foregroundStyle(WCTheme.accent)

            Text(pattern.subtitle)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            HStack(spacing: 18) {
                labelled("Rythme".wcLocalized, pattern.rhythm)
                labelled("Cycles".wcLocalized, "\(pattern.cycles)")
                labelled("Durée".wcLocalized, WCFormat.duration(pattern.totalDuration))
            }

            Spacer()

            Button {
                finished = false
                startedAt = Date()
            } label: {
                Label("Commencer", systemImage: "play.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }

    private func labelled(_ title: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline)
                .monospacedDigit()
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Pendant l'exercice

    private func running(from start: Date) -> some View {
        TimelineView(.periodic(from: .now, by: 1.0 / 20.0)) { context in
            let state = pattern.state(at: context.date.timeIntervalSince(start))

            VStack(spacing: 28) {
                ZStack {
                    Circle()
                        .fill(WCTheme.accent.opacity(0.14))
                    Circle()
                        .fill(WCTheme.accent.opacity(0.28))
                        .scaleEffect(state.scale)
                    VStack(spacing: 6) {
                        Text(state.isFinished ? "Terminé".wcLocalized : state.phase.title)
                            .font(.title2.weight(.semibold))
                        if !state.isFinished {
                            Text("\(Int(state.phaseRemaining.rounded(.up)))")
                                .font(.system(size: 44, weight: .semibold, design: .rounded))
                                .monospacedDigit()
                                .contentTransition(.numericText())
                        }
                    }
                }
                .frame(height: 280)
                .animation(.easeInOut(duration: 0.1), value: state.scale)

                if state.isFinished {
                    Text("Six respirations de plus si besoin — sans jamais pousser en retenant votre souffle.")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Cycle %@ sur %@".wcLocalized(String(state.cycle), String(pattern.cycles)))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if state.isFinished {
                    Button {
                        startedAt = Date()
                    } label: {
                        Label("Recommencer", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button(role: .cancel) {
                        startedAt = nil
                    } label: {
                        Label("Arrêter", systemImage: "stop.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .onChange(of: state.isFinished) { _, isFinished in
                guard isFinished, !finished else { return }
                finished = true
            }
        }
    }
}

#Preview {
    BreathingView(pattern: .belly)
}
