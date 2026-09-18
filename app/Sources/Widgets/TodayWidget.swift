import AppIntents
import SwiftUI
import WidgetKit

struct TodayEntry: TimelineEntry {
    let date: Date
    let state: SessionState
    let todayCount: Int
    let averageDuration: TimeInterval

    var active: ToiletSession? { state.active }
}

/// Lit directement le fichier partagé : aucun réseau, aucune attente.
struct TodayProvider: TimelineProvider {
    private let storage = SessionStorage.shared

    func placeholder(in context: Context) -> TodayEntry {
        TodayEntry(date: Date(), state: .empty, todayCount: 0, averageDuration: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayEntry) -> Void) {
        completion(entry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayEntry>) -> Void) {
        let current = entry()
        // Une visite en cours se rafraîchit à la minute, sinon au quart d'heure.
        let refresh = current.active == nil ? 900.0 : 60.0
        completion(Timeline(entries: [current], policy: .after(Date().addingTimeInterval(refresh))))
    }

    private func entry() -> TodayEntry {
        let state = storage.load()
        let stats = StatsEngine.compute(sessions: state.sessions)
        return TodayEntry(
            date: Date(),
            state: state,
            todayCount: stats.today,
            averageDuration: stats.averageDuration
        )
    }
}

struct TodayWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "WCConnectToday", provider: TodayProvider()) { entry in
            TodayWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("WC Connect")
        .description("Visites du jour et chronomètre de la visite en cours.")
        .supportedFamilies(TodayWidget.families)

    }

    static var families: [WidgetFamily] {
        #if os(watchOS)
        return [.accessoryCircular, .accessoryCorner, .accessoryInline, .accessoryRectangular]
        #else
        return [.systemSmall, .systemMedium, .accessoryCircular, .accessoryInline, .accessoryRectangular]
        #endif
    }
}

struct TodayWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: TodayEntry

    var body: some View {
        switch family {
        case .accessoryInline:
            inline
        case .accessoryCircular:
            circular
        case .accessoryRectangular:
            rectangular
        #if os(watchOS)
        case .accessoryCorner:
            circular
        #endif
        case .systemMedium:
            medium
        default:
            small
        }
    }

    // MARK: - Familles

    private var inline: some View {
        if let active = entry.active {
            return Text("WC · \(WCFormat.clock(active.duration(now: entry.date)))")
        }
        return Text("WC · \(entry.todayCount) aujourd'hui")
    }

    private var circular: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Image(systemName: "toilet.fill")
                    .font(.caption2)
                Text(circularValue)
                    .font(.caption.weight(.semibold))
                    .monospacedDigit()
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
        }
    }

    private var circularValue: String {
        if let active = entry.active {
            return WCFormat.clock(active.duration(now: entry.date))
        }
        return "\(entry.todayCount)"
    }

    private var rectangular: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(entry.active == nil ? "WC Connect" : "Visite en cours")
                .font(.caption.weight(.semibold))
            if let active = entry.active {
                Text(timerInterval: active.clockRange, countsDown: false)
                    .font(.title3.weight(.semibold))
                    .monospacedDigit()
                Text(active.place.title)
                    .font(.caption2)
            } else {
                Text("\(entry.todayCount) visite\(entry.todayCount > 1 ? "s" : "") aujourd'hui")
                    .font(.title3.weight(.semibold))
                Text(entry.averageDuration > 0 ? "Moyenne \(WCFormat.duration(entry.averageDuration))" : "Aucune visite enregistrée")
                    .font(.caption2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var small: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "toilet.fill")
                    .foregroundStyle(WCTheme.accent)
                Spacer()
                if entry.active != nil {
                    Circle().fill(WCTheme.mint).frame(width: 8, height: 8)
                }
            }
            Spacer(minLength: 0)
            if let active = entry.active {
                Text(WCFormat.clock(active.duration(now: entry.date)))
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                Text(active.kind.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("\(entry.todayCount)")
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                Text("visite\(entry.todayCount > 1 ? "s" : "") aujourd'hui")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            actionButton
        }
    }

    private var medium: some View {
        HStack(spacing: 16) {
            small
            Divider()
            VStack(alignment: .leading, spacing: 6) {
                Label("\(entry.state.sessions.count) au total", systemImage: "number")
                Label(
                    entry.averageDuration > 0 ? WCFormat.duration(entry.averageDuration) : "—",
                    systemImage: "timer"
                )
                if let last = entry.state.sessions.first {
                    Label(WCFormat.time(last.startedAt), systemImage: "clock.arrow.circlepath")
                }
                Spacer(minLength: 0)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    /// Bouton interactif (iOS 17+) : démarre ou termine la visite sans ouvrir l'app.
    @ViewBuilder
    private var actionButton: some View {
        #if os(iOS)
        Button(intent: ToggleVisitIntent()) {
            Label(
                entry.active == nil ? "Démarrer" : "Terminer",
                systemImage: entry.active == nil ? "play.fill" : "checkmark"
            )
            .font(.caption.weight(.semibold))
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bordered)
        .tint(WCTheme.accent)
        #else
        EmptyView()
        #endif
    }
}
