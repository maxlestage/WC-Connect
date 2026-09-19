import SwiftUI

/// Anneau de progression du chronomètre.
struct ProgressRing: View {
    let progress: Double
    let color: Color
    var lineWidth: CGFloat = 16

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.15), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(
                    AngularGradient(colors: [color.opacity(0.7), color], center: .center),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.4), value: progress)
        }
    }
}

/// Souffle lent qui remplace l'anneau de progression en mode serein.
///
/// Rien n'y mesure le temps : le halo enfle et se rétracte au rythme d'une
/// respiration posée (environ cinq secondes dans un sens), et cette durée ne
/// dépend d'aucun objectif. Quand « Réduire les animations » est activé, le
/// halo reste immobile — l'accessibilité passe avant l'effet.
struct BreathingHalo: View {
    /// Une visite est en cours : le halo respire. Sinon il se pose.
    var active: Bool
    var color: Color

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var expanded = false

    private var scale: CGFloat {
        guard active, !reduceMotion else { return 0.88 }
        return expanded ? 1 : 0.8
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.10))
                .scaleEffect(scale)
            Circle()
                .fill(color.opacity(0.14))
                .scaleEffect(scale * 0.82)
            Circle()
                .strokeBorder(color.opacity(0.35), lineWidth: 2)
                .scaleEffect(scale * 0.94)
        }
        .animation(.easeInOut(duration: 5.5).repeatForever(autoreverses: true), value: expanded)
        .animation(.easeInOut(duration: 0.6), value: active)
        .onAppear { expanded = true }
        .accessibilityHidden(true)
    }
}
