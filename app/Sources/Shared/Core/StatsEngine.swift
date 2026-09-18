import Foundation

public struct DayBucket: Identifiable, Hashable, Sendable {
    public let date: Date
    public let count: Int
    public let totalDuration: TimeInterval
    public var id: Date { date }

    public init(date: Date, count: Int, totalDuration: TimeInterval) {
        self.date = date
        self.count = count
        self.totalDuration = totalDuration
    }
}

public struct Stats: Sendable {
    public let total: Int
    public let today: Int
    public let averagePerDay: Double
    public let averageDuration: TimeInterval
    public let totalDuration: TimeInterval
    public let longestDuration: TimeInterval
    public let streakDays: Int
    public let busiestHour: Int?
    public let averageComfort: Double?
    public let week: [DayBucket]
    public let byPlace: [Place: Int]
    public let byKind: [SessionKind: Int]

    public static let empty = Stats(
        total: 0, today: 0, averagePerDay: 0, averageDuration: 0, totalDuration: 0,
        longestDuration: 0, streakDays: 0, busiestHour: nil, averageComfort: nil,
        week: [], byPlace: [:], byKind: [:]
    )
}

/// Calculs purs (sans état) sur l'historique : testables et réutilisables par
/// l'app, les widgets et la Watch.
public enum StatsEngine {

    /// - Parameter sessions: visites terminées ou en cours (les visites en cours
    ///   sont ignorées, leur durée n'étant pas encore connue).
    public static func compute(
        sessions: [ToiletSession],
        now: Date = Date(),
        calendar: Calendar = .current,
        weekLength: Int = 7
    ) -> Stats {
        let finished = sessions.filter { $0.endedAt != nil }
        guard !finished.isEmpty else {
            return Stats(
                total: 0, today: 0, averagePerDay: 0, averageDuration: 0, totalDuration: 0,
                longestDuration: 0, streakDays: 0, busiestHour: nil, averageComfort: nil,
                week: emptyWeek(now: now, calendar: calendar, weekLength: weekLength),
                byPlace: [:], byKind: [:]
            )
        }

        let durations = finished.compactMap { $0.finalDuration }
        let totalDuration = durations.reduce(0, +)
        let today = finished.filter { calendar.isDate($0.startedAt, inSameDayAs: now) }.count

        // Moyenne par jour sur la période réellement couverte par l'historique.
        let firstDay = calendar.startOfDay(for: finished.map(\.startedAt).min() ?? now)
        let lastDay = calendar.startOfDay(for: now)
        let spannedDays = max(1, (calendar.dateComponents([.day], from: firstDay, to: lastDay).day ?? 0) + 1)

        var hourCounts: [Int: Int] = [:]
        var byPlace: [Place: Int] = [:]
        var byKind: [SessionKind: Int] = [:]
        var comfortSum = 0
        var comfortCount = 0

        for session in finished {
            let hour = calendar.component(.hour, from: session.startedAt)
            hourCounts[hour, default: 0] += 1
            byPlace[session.place, default: 0] += 1
            byKind[session.kind, default: 0] += 1
            if let comfort = session.comfort {
                comfortSum += comfort
                comfortCount += 1
            }
        }

        // En cas d'égalité, on retient l'heure la plus tôt pour rester stable.
        let busiestHour = hourCounts
            .sorted { ($0.value, -$0.key) > ($1.value, -$1.key) }
            .first?.key

        return Stats(
            total: finished.count,
            today: today,
            averagePerDay: Double(finished.count) / Double(spannedDays),
            averageDuration: totalDuration / Double(durations.count),
            totalDuration: totalDuration,
            longestDuration: durations.max() ?? 0,
            streakDays: streak(sessions: finished, now: now, calendar: calendar),
            busiestHour: busiestHour,
            averageComfort: comfortCount > 0 ? Double(comfortSum) / Double(comfortCount) : nil,
            week: week(sessions: finished, now: now, calendar: calendar, weekLength: weekLength),
            byPlace: byPlace,
            byKind: byKind
        )
    }

    /// Nombre de jours consécutifs, en remontant depuis aujourd'hui, comportant
    /// au moins une visite. Un historique qui s'arrête hier compte quand même
    /// (la journée en cours n'est pas encore finie).
    public static func streak(sessions: [ToiletSession], now: Date = Date(), calendar: Calendar = .current) -> Int {
        let days = Set(sessions.map { calendar.startOfDay(for: $0.startedAt) })
        guard !days.isEmpty else { return 0 }

        var cursor = calendar.startOfDay(for: now)
        if !days.contains(cursor) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor), days.contains(yesterday) else {
                return 0
            }
            cursor = yesterday
        }

        var count = 0
        while days.contains(cursor) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return count
    }

    /// Derniers `weekLength` jours, du plus ancien au plus récent.
    public static func week(
        sessions: [ToiletSession],
        now: Date = Date(),
        calendar: Calendar = .current,
        weekLength: Int = 7
    ) -> [DayBucket] {
        var buckets: [Date: (count: Int, duration: TimeInterval)] = [:]
        for session in sessions {
            let day = calendar.startOfDay(for: session.startedAt)
            var bucket = buckets[day] ?? (0, 0)
            bucket.count += 1
            bucket.duration += session.finalDuration ?? 0
            buckets[day] = bucket
        }

        return days(now: now, calendar: calendar, weekLength: weekLength).map { day in
            let bucket = buckets[day] ?? (0, 0)
            return DayBucket(date: day, count: bucket.count, totalDuration: bucket.duration)
        }
    }

    private static func emptyWeek(now: Date, calendar: Calendar, weekLength: Int) -> [DayBucket] {
        days(now: now, calendar: calendar, weekLength: weekLength)
            .map { DayBucket(date: $0, count: 0, totalDuration: 0) }
    }

    private static func days(now: Date, calendar: Calendar, weekLength: Int) -> [Date] {
        let today = calendar.startOfDay(for: now)
        return (0..<max(1, weekLength)).reversed().compactMap {
            calendar.date(byAdding: .day, value: -$0, to: today)
        }
    }
}

public struct HourBucket: Identifiable, Hashable, Sendable {
    /// Heure de début du créneau (0, 3, 6, ...).
    public let hour: Int
    public let count: Int
    public var id: Int { hour }

    public init(hour: Int, count: Int) {
        self.hour = hour
        self.count = count
    }
}

public extension StatsEngine {
    /// Répartition des visites sur la journée, par créneaux de `blockSize` heures.
    static func hourBuckets(
        sessions: [ToiletSession],
        blockSize: Int = 3,
        calendar: Calendar = .current
    ) -> [HourBucket] {
        let size = max(1, min(blockSize, 24))
        var counts: [Int: Int] = [:]
        for session in sessions where session.endedAt != nil {
            let hour = calendar.component(.hour, from: session.startedAt)
            counts[(hour / size) * size, default: 0] += 1
        }
        return stride(from: 0, to: 24, by: size).map { HourBucket(hour: $0, count: counts[$0] ?? 0) }
    }
}
