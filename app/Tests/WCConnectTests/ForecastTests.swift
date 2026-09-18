import XCTest
// Les sources partagées sont compilées directement dans la cible de test :
// les tests ne dépendent ni de l'app ni d'un simulateur hôte.

final class ForecastTests: XCTestCase {

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Paris") ?? .gmt
        return calendar
    }

    private var now: Date {
        calendar.date(from: DateComponents(year: 2026, month: 5, day: 20, hour: 12)) ?? Date()
    }

    /// Visite située `daysAgo` jours avant la référence.
    private func session(daysAgo: Double, seconds: Double, comfort: Int? = nil, hour: Int? = nil) -> ToiletSession {
        var start = now.addingTimeInterval(-daysAgo * 86_400)
        if let hour {
            var components = calendar.dateComponents([.year, .month, .day], from: start)
            components.hour = hour
            start = calendar.date(from: components) ?? start
        }
        return ToiletSession(startedAt: start, endedAt: start.addingTimeInterval(seconds), comfort: comfort)
    }

    private func forecast(_ sessions: [ToiletSession]) -> GutForecast {
        ForecastEngine.forecast(sessions: sessions, now: now, calendar: calendar)
    }

    func testUnknownBelowThreeVisits() {
        let two = [session(daysAgo: 1, seconds: 200), session(daysAgo: 2, seconds: 200)]
        XCTAssertEqual(forecast(two).title, GutForecast.unknown.title)
        XCTAssertEqual(forecast([]).showerRisk, 0)
    }

    func testRunningSessionsAreIgnored() {
        let sessions = [
            session(daysAgo: 1, seconds: 200),
            session(daysAgo: 2, seconds: 200),
            ToiletSession(startedAt: now, endedAt: nil)
        ]
        XCTAssertEqual(forecast(sessions).title, GutForecast.unknown.title)
    }

    func testStormWhenVisitsDragOn() {
        let sessions = (1...4).map { session(daysAgo: Double($0), seconds: 15 * 60, comfort: 3) }
        XCTAssertEqual(forecast(sessions).title, "Tempête")
    }

    func testStormWhenComfortIsLow() {
        let sessions = (1...4).map { session(daysAgo: Double($0), seconds: 240, comfort: 2) }
        XCTAssertEqual(forecast(sessions).title, "Tempête")
    }

    func testDisturbedForLongishVisits() {
        let sessions = (1...4).map { session(daysAgo: Double($0), seconds: 8 * 60, comfort: 3) }
        XCTAssertEqual(forecast(sessions).title, "Perturbé")
    }

    func testFairWeatherWhenShortAndComfortable() {
        let sessions = (1...4).map { session(daysAgo: Double($0), seconds: 3 * 60, comfort: 5) }
        XCTAssertEqual(forecast(sessions).title, "Grand beau")
    }

    func testVariableByDefault() {
        let sessions = (1...4).map { session(daysAgo: Double($0), seconds: 6 * 60, comfort: 3) }
        XCTAssertEqual(forecast(sessions).title, "Variable")
    }

    func testIndicatorsStayWithinPlausibleBounds() {
        let scenarios: [[ToiletSession]] = [
            (1...4).map { session(daysAgo: Double($0), seconds: 30, comfort: 5) },
            (1...4).map { session(daysAgo: Double($0), seconds: 30 * 60, comfort: 1) },
            (1...12).map { session(daysAgo: Double($0) / 3, seconds: 300, comfort: 3) },
            (1...4).map { session(daysAgo: 8 + Double($0), seconds: 300, comfort: 4) }
        ]

        for sessions in scenarios {
            let bulletin = forecast(sessions)
            XCTAssertTrue((980...1035).contains(bulletin.pressure), "pression hors bornes : \(bulletin.pressure)")
            XCTAssertTrue((0...95).contains(bulletin.showerRisk), "risque hors bornes : \(bulletin.showerRisk)")
            XCTAssertFalse(bulletin.wind.isEmpty)
            XCTAssertFalse(bulletin.visibility.isEmpty)
            XCTAssertFalse(bulletin.summary.isEmpty)
            XCTAssertFalse(bulletin.symbol.isEmpty)
        }
    }

    func testComfortRaisesPressure() {
        let happy = (1...4).map { session(daysAgo: Double($0), seconds: 240, comfort: 5) }
        let grim = (1...4).map { session(daysAgo: Double($0), seconds: 240, comfort: 3) }
        XCTAssertGreaterThan(forecast(happy).pressure, forecast(grim).pressure)
    }

    func testNextVisitFallsOnTheFavouriteHourAndInTheFuture() {
        let sessions = (1...5).map { session(daysAgo: Double($0), seconds: 240, hour: 8) }
        guard let prediction = ForecastEngine.nextVisit(sessions: sessions, now: now, calendar: calendar) else {
            return XCTFail("prévision attendue")
        }
        XCTAssertEqual(calendar.component(.hour, from: prediction.date), 8)
        XCTAssertGreaterThan(prediction.date, now, "la prévision doit être à venir")
        XCTAssertTrue((3...80).contains(prediction.reliability))
    }

    func testNextVisitLaterTodayIsKeptToday() {
        let sessions = (1...5).map { session(daysAgo: Double($0), seconds: 240, hour: 19) }
        guard let prediction = ForecastEngine.nextVisit(sessions: sessions, now: now, calendar: calendar) else {
            return XCTFail("prévision attendue")
        }
        XCTAssertTrue(calendar.isDate(prediction.date, inSameDayAs: now))
    }

    func testNextVisitNeedsHistory() {
        XCTAssertNil(ForecastEngine.nextVisit(sessions: [], now: now, calendar: calendar))
    }
}
