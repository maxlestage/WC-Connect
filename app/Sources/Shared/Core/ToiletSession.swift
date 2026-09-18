import Foundation

/// Nature de la visite.
public enum SessionKind: String, Codable, CaseIterable, Hashable, Sendable {
    case quick
    case standard
    case long

    public var title: String {
        switch self {
        case .quick: return "Express".wcLocalized
        case .standard: return "Standard".wcLocalized
        case .long: return "Longue".wcLocalized
        }
    }

    public var symbol: String {
        switch self {
        case .quick: return "hare.fill"
        case .standard: return "toilet.fill"
        case .long: return "tortoise.fill"
        }
    }

    /// Objectif indicatif utilisé par la Live Activity et l'anneau de progression.
    public var goal: TimeInterval {
        switch self {
        case .quick: return 2 * 60
        case .standard: return 5 * 60
        case .long: return 12 * 60
        }
    }
}

/// Lieu de la visite.
public enum Place: String, Codable, CaseIterable, Hashable, Sendable {
    case home
    case work
    case outside

    public var title: String {
        switch self {
        case .home: return "Maison".wcLocalized
        case .work: return "Travail".wcLocalized
        case .outside: return "Dehors".wcLocalized
        }
    }

    public var symbol: String {
        switch self {
        case .home: return "house.fill"
        case .work: return "building.2.fill"
        case .outside: return "map.fill"
        }
    }
}

/// Appareil ayant démarré la visite.
public enum SessionSource: String, Codable, Hashable, Sendable {
    case phone
    case watch
    case widget

    public var title: String {
        switch self {
        case .phone: return "iPhone".wcLocalized
        case .watch: return "Apple Watch".wcLocalized
        case .widget: return "Widget".wcLocalized
        }
    }
}

/// Une visite aux toilettes, en cours (`endedAt == nil`) ou terminée.
public struct ToiletSession: Identifiable, Codable, Hashable, Sendable {
    public var id: UUID
    public var startedAt: Date
    public var endedAt: Date?
    public var kind: SessionKind
    public var place: Place
    /// Confort ressenti de 1 à 5, saisi à la fin de la visite.
    public var comfort: Int?
    public var note: String?
    public var source: SessionSource

    public init(
        id: UUID = UUID(),
        startedAt: Date = Date(),
        endedAt: Date? = nil,
        kind: SessionKind = .standard,
        place: Place = .home,
        comfort: Int? = nil,
        note: String? = nil,
        source: SessionSource = .phone
    ) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.kind = kind
        self.place = place
        self.comfort = comfort
        self.note = note
        self.source = source
    }

    public var isRunning: Bool { endedAt == nil }

    /// Durée écoulée : définitive si la visite est terminée, sinon calculée à `now`.
    public func duration(now: Date = Date()) -> TimeInterval {
        max(0, (endedAt ?? now).timeIntervalSince(startedAt))
    }

    /// Plage passée à `Text(timerInterval:)` pour un chronomètre animé par le
    /// système (largement dimensionnée : le texte ne doit pas se figer).
    public var clockRange: ClosedRange<Date> {
        startedAt...startedAt.addingTimeInterval(4 * 60 * 60)
    }

    public var finalDuration: TimeInterval? {
        guard let endedAt else { return nil }
        return max(0, endedAt.timeIntervalSince(startedAt))
    }
}
