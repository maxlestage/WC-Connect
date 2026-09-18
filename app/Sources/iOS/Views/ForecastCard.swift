import SwiftUI

/// Bulletin météo intestinal. Aucune valeur prédictive, beaucoup de sérieux
/// dans la présentation.
struct ForecastCard: View {
    let forecast: GutForecast
    let nextVisit: (date: Date, reliability: Int)?
    let persona: Persona

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                Image(systemName: forecast.symbol)
                    .font(.system(size: 34))
                    .foregroundStyle(WCTheme.accent)
                    .frame(width: 44)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Météo intestinale")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(forecast.title)
                        .font(.title3.weight(.bold))
                }
                Spacer(minLength: 0)
            }

            Text(forecast.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 0) {
                gauge("Pression".wcLocalized, "\(forecast.pressure) hPa")
                Divider().frame(height: 30)
                gauge("Averses".wcLocalized, "\(forecast.showerRisk) %")
                Divider().frame(height: 30)
                gauge("Visibilité".wcLocalized, forecast.visibility.components(separatedBy: ",").first ?? "—")
            }

            Label(forecast.wind, systemImage: "wind")
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            HStack(spacing: 10) {
                Image(systemName: persona.symbol)
                    .foregroundStyle(WCTheme.warn)
                VStack(alignment: .leading, spacing: 2) {
                    Text(persona.title)
                        .font(.subheadline.weight(.semibold))
                    Text(persona.detail)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            if let nextVisit {
                Label {
                    Text("Prochaine visite prévue vers %@ — fiabilité %@ %%".wcLocalized(WCFormat.time(nextVisit.date), String(nextVisit.reliability)))
                } icon: {
                    Image(systemName: "calendar.badge.clock")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.quaternary.opacity(0.3), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func gauge(_ title: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ForecastCard(
        forecast: ForecastEngine.forecast(sessions: []),
        nextVisit: (Date().addingTimeInterval(3600), 42),
        persona: PersonaEngine.persona(sessions: [])
    )
    .padding()
}
