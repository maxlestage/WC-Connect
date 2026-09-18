import XCTest
// Heure conseillée pour une visite régulière.

final class RoutineSuggestionTests: XCTestCase {

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Paris") ?? .gmt
        return calendar
    }

    private func visite(day: Int, hour: Int, terminee: Bool = true) -> ToiletSession {
        let debut = calendar.date(
            from: DateComponents(year: 2026, month: 3, day: day, hour: hour)
        ) ?? Date()
        return ToiletSession(
            startedAt: debut,
            endedAt: terminee ? debut.addingTimeInterval(240) : nil
        )
    }

    private func heure(_ sessions: [ToiletSession]) -> Int {
        RoutineSuggestion.hour(sessions: sessions, calendar: calendar)
    }

    func testHistoriqueVideProposeApresLePetitDejeuner() {
        XCTAssertEqual(heure([]), RoutineSuggestion.fallbackHour)
        XCTAssertEqual(RoutineSuggestion.fallbackHour, 8)
    }

    func testHeureLaPlusFrequenteDuMatin() {
        let sessions = [
            visite(day: 1, hour: 7),
            visite(day: 2, hour: 7),
            visite(day: 3, hour: 9),
            visite(day: 4, hour: 22)
        ]
        XCTAssertEqual(heure(sessions), 7)
    }

    func testLeMatinLEmporteSurUneHabitudeDuSoir() {
        // Quatre visites le soir, une seule le matin : le créneau du matin
        // reste conseillé, c'est là que le réflexe est le plus franc.
        let sessions = [
            visite(day: 1, hour: 21),
            visite(day: 2, hour: 21),
            visite(day: 3, hour: 21),
            visite(day: 4, hour: 21),
            visite(day: 5, hour: 9)
        ]
        XCTAssertEqual(heure(sessions), 9)
    }

    func testSansAucuneVisiteDuMatinOnSuitLHabitude() {
        let sessions = [
            visite(day: 1, hour: 20),
            visite(day: 2, hour: 20),
            visite(day: 3, hour: 23)
        ]
        XCTAssertEqual(heure(sessions), 20)
    }

    func testEgaliteRetientLHeureLaPlusTot() {
        let sessions = [visite(day: 1, hour: 10), visite(day: 2, hour: 6)]
        XCTAssertEqual(heure(sessions), 6)
    }

    func testVisitesEnCoursIgnorees() {
        let sessions = [
            visite(day: 1, hour: 6, terminee: false),
            visite(day: 2, hour: 6, terminee: false),
            visite(day: 3, hour: 10)
        ]
        XCTAssertEqual(heure(sessions), 10)
    }

    func testHeureToujoursDansLaJournee() {
        for h in 0...23 {
            let proposee = heure([visite(day: 1, hour: h)])
            XCTAssertTrue((0...23).contains(proposee), "heure \(h) → \(proposee)")
        }
    }
}
