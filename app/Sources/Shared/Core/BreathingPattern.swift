import Foundation

/// Phase d'un cycle respiratoire.
public enum BreathingPhase: String, Codable, Hashable, Sendable {
    case inhale
    case hold
    case exhale
    case rest

    public var title: String {
        switch self {
        case .inhale: return "Inspirez"
        case .hold: return "Retenez"
        case .exhale: return "Expirez"
        case .rest: return "Pause"
        }
    }

    /// Taille relative du cercle animé pendant la phase, de son début à sa fin.
    public var scale: (from: Double, to: Double) {
        switch self {
        case .inhale: return (0.55, 1.0)
        case .hold: return (1.0, 1.0)
        case .exhale: return (1.0, 0.55)
        case .rest: return (0.55, 0.55)
        }
    }
}

public struct BreathingStep: Hashable, Sendable {
    public let phase: BreathingPhase
    public let duration: TimeInterval

    public init(_ phase: BreathingPhase, _ duration: TimeInterval) {
        self.phase = phase
        self.duration = max(0.5, duration)
    }
}

/// État de l'exercice à un instant donné.
public struct BreathingState: Hashable, Sendable {
    public let phase: BreathingPhase
    /// Temps écoulé dans la phase en cours.
    public let phaseElapsed: TimeInterval
    public let phaseDuration: TimeInterval
    /// Cycle en cours, à partir de 1.
    public let cycle: Int
    public let isFinished: Bool

    public var phaseProgress: Double {
        guard phaseDuration > 0 else { return 1 }
        return min(max(phaseElapsed / phaseDuration, 0), 1)
    }

    public var phaseRemaining: TimeInterval {
        max(0, phaseDuration - phaseElapsed)
    }

    /// Taille du cercle animé, interpolée dans la phase.
    public var scale: Double {
        let bounds = phase.scale
        return bounds.from + (bounds.to - bounds.from) * phaseProgress
    }
}

/// Exercice de respiration guidée.
///
/// Les durées sont exprimées en secondes et la logique est purement calculée :
/// l'interface se contente d'interroger `state(at:)` à chaque image.
public struct BreathingPattern: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let steps: [BreathingStep]
    public let cycles: Int

    public init(id: String, title: String, subtitle: String, steps: [BreathingStep], cycles: Int) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.steps = steps
        self.cycles = max(1, cycles)
    }

    public var cycleDuration: TimeInterval {
        steps.reduce(0) { $0 + $1.duration }
    }

    public var totalDuration: TimeInterval {
        cycleDuration * Double(cycles)
    }

    /// Libellé compact du rythme, par exemple « 4-6 » ou « 4-7-8 ».
    public var rhythm: String {
        steps
            .filter { $0.phase != .rest }
            .map { String(Int($0.duration.rounded())) }
            .joined(separator: "-")
    }

    public func state(at elapsed: TimeInterval) -> BreathingState {
        let clamped = max(0, elapsed)
        guard let last = steps.last else {
            return BreathingState(phase: .rest, phaseElapsed: 0, phaseDuration: 1, cycle: 1, isFinished: true)
        }
        if clamped >= totalDuration {
            return BreathingState(
                phase: last.phase,
                phaseElapsed: last.duration,
                phaseDuration: last.duration,
                cycle: cycles,
                isFinished: true
            )
        }

        let cycleIndex = Int(clamped / cycleDuration)
        var within = clamped - Double(cycleIndex) * cycleDuration

        for step in steps {
            if within < step.duration {
                return BreathingState(
                    phase: step.phase,
                    phaseElapsed: within,
                    phaseDuration: step.duration,
                    cycle: cycleIndex + 1,
                    isFinished: false
                )
            }
            within -= step.duration
        }

        // Inatteignable : la somme des étapes vaut cycleDuration.
        return BreathingState(
            phase: last.phase,
            phaseElapsed: last.duration,
            phaseDuration: last.duration,
            cycle: cycleIndex + 1,
            isFinished: false
        )
    }
}

public extension BreathingPattern {
    /// Respiration ventrale sans apnée : c'est celle à proposer pendant une
    /// visite, car retenir son souffle revient à pousser.
    static let belly = BreathingPattern(
        id: "belly",
        title: "Ventre 4-6",
        subtitle: "Sans apnée : la plus indiquée sur le trône, elle relâche le ventre et le périnée.",
        steps: [BreathingStep(.inhale, 4), BreathingStep(.exhale, 6)],
        cycles: 12
    )

    /// Cohérence cardiaque simplifiée.
    static let square = BreathingPattern(
        id: "square",
        title: "Carré 4-4-4-4",
        subtitle: "Quatre temps égaux pour calmer le rythme et se recentrer.",
        steps: [
            BreathingStep(.inhale, 4),
            BreathingStep(.hold, 4),
            BreathingStep(.exhale, 4),
            BreathingStep(.rest, 4)
        ],
        cycles: 8
    )

    /// Expiration longue, très relaxante.
    static let relax = BreathingPattern(
        id: "relax",
        title: "Détente 4-7-8",
        subtitle: "Expiration longue, pour relâcher les épaules et la mâchoire.",
        steps: [BreathingStep(.inhale, 4), BreathingStep(.hold, 7), BreathingStep(.exhale, 8)],
        cycles: 6
    )

    static let all: [BreathingPattern] = [.belly, .square, .relax]
}
