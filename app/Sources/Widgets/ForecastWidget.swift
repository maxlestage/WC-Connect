import AppIntents
import SwiftUI
import WidgetKit

struct ForecastEntry: TimelineEntry {
    let date: Date
    let forecast: GutForecast
    let nextVisit: (date: Date, reliability: Int)?
}

/// Le bulletin météo intestinal, sur l'écran d'accueil. Parce qu'il le faut.
struct ForecastProvider: TimelineProvider {
    private let storage = SessionStorage.shared

    func placeholder(in context: Context) -> ForecastEntry {
        ForecastEntry(date: Date(), forecast: .unknown, nextVisit: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (ForecastEntry) -> Void) {
        completion(entry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ForecastEntry>) -> Void) {
        // Un bulletin n'a pas besoin d'être rafraîchi à la minute.
        completion(Timeline(entries: [entry()], policy: .after(Date().addingTimeInterval(3_600))))
    }

    private func entry() -> ForecastEntry {
        let state = storage.load()
        return ForecastEntry(
            date: Date(),
            forecast: ForecastEngine.forecast(sessions: state.sessions),
            nextVisit: ForecastEngine.nextVisit(sessions: state.sessions)
        )
    }
}

struct ForecastWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "WCConnectForecast", provider: ForecastProvider()) { entry in
            ForecastWidgetView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Météo intestinale")
        .description("Le bulletin du jour, calculé sur votre semaine.")
        .supportedFamilies([.systemSmall, .accessoryRectangular])
    }
}

struct ForecastWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: ForecastEntry

    var body: some View {
        switch family {
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 1) {
                Text("Météo intestinale")
                    .font(.caption2.weight(.semibold))
                Text(entry.forecast.title)
                    .font(.headline)
                Text("\(entry.forecast.pressure) hPa · \(entry.forecast.showerRisk) %")
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        default:
            VStack(alignment: .leading, spacing: 6) {
                Image(systemName: entry.forecast.symbol)
                    .font(.title2)
                    .foregroundStyle(WCTheme.accent)
                Text(entry.forecast.title)
                    .font(.headline)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)
                Text("\(entry.forecast.pressure) hPa")
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
                if let nextVisit = entry.nextVisit {
                    Text("Prochaine visite prévue vers %@ — fiabilité %@ %%".wcLocalized(
                        WCFormat.time(nextVisit.date),
                        String(nextVisit.reliability)
                    ))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                } else {
                    Text(entry.forecast.wind)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
