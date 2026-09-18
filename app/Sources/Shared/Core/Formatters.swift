import Foundation

public enum WCFormat {
    /// « 4:07 » ou « 1:02:33 » pour un chronomètre.
    public static func clock(_ interval: TimeInterval) -> String {
        let total = Int(max(0, interval.rounded()))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        }
        return String(format: "%d:%02d", minutes, seconds)
    }

    /// « 4 min 07 s » pour les résumés et statistiques.
    public static func duration(_ interval: TimeInterval) -> String {
        let total = Int(max(0, interval.rounded()))
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0 {
            return "\(hours) h \(String(format: "%02d", minutes)) min"
        }
        if minutes > 0 {
            return "\(minutes) min \(String(format: "%02d", seconds)) s"
        }
        return "\(seconds) s"
    }

    public static func time(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }

    public static func dayHeader(_ date: Date, now: Date = Date(), calendar: Calendar = .current) -> String {
        if calendar.isDateInToday(date) { return "Aujourd'hui" }
        if calendar.isDateInYesterday(date) { return "Hier" }
        return date.formatted(.dateTime.weekday(.wide).day().month(.wide))
    }

    public static func hourLabel(_ hour: Int) -> String {
        "\(hour) h"
    }
}
