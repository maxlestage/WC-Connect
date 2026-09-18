import XCTest
// Les sources partagées sont compilées directement dans la cible de test :
// les tests ne dépendent ni de l'app ni d'un simulateur hôte.

final class AchievementTests: XCTestCase {

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Paris") ?? .gmt
        return calendar
    }

    private func date(_ day: Int, hour: Int = 9, minute: Int = 0) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 4, day: day, hour: hour, minute: minute)) ?? Date()
    }

    private func session(
        day: Int,
        hour: Int = 9,
        minute: Int = 0,
        seconds: Double = 240,
        place: Place = .home,
        comfort: Int? = nil
    ) -> ToiletSession {
        let start = date(day, hour: hour, minute: minute)
        return ToiletSession(startedAt: start, endedAt: start.addingTimeInterval(seconds), place: place, comfort: comfort)
    }

    private func isUnlocked(_ achievement: Achievement, _ sessions: [ToiletSession]) -> Bool {
        AchievementEngine.isUnlocked(achievement, sessions: sessions, calendar: calendar)
    }

    func testNothingUnlockedWithoutHistory() {
        for achievement in Achievement.allCases {
            XCTAssertFalse(isUnlocked(achievement, []), "\(achievement.title) ne devrait pas être débloqué")
        }
    }

    func testRunningSessionsDoNotUnlockAnything() {
        let running = [ToiletSession(startedAt: date(1), endedAt: nil)]
        XCTAssertFalse(isUnlocked(.debut, running))
    }

    func testFirstVisit() {
        XCTAssertTrue(isUnlocked(.debut, [session(day: 1)]))
    }

    func testEclairNeedsUnderFortyFiveSeconds() {
        XCTAssertTrue(isUnlocked(.eclair, [session(day: 1, seconds: 44)]))
        XCTAssertFalse(isUnlocked(.eclair, [session(day: 1, seconds: 45)]))
    }

    func testMarathonienNeedsOverTwentyMinutes() {
        XCTAssertTrue(isUnlocked(.marathonien, [session(day: 1, seconds: 20 * 60 + 1)]))
        XCTAssertFalse(isUnlocked(.marathonien, [session(day: 1, seconds: 20 * 60)]))
    }

    func testNoctambuleWindow() {
        XCTAssertTrue(isUnlocked(.noctambule, [session(day: 1, hour: 3)]))
        XCTAssertFalse(isUnlocked(.noctambule, [session(day: 1, hour: 1)]))
        XCTAssertFalse(isUnlocked(.noctambule, [session(day: 1, hour: 5)]))
    }

    func testAvantLeCoq() {
        XCTAssertTrue(isUnlocked(.avantLeCoq, [session(day: 1, hour: 5)]))
        XCTAssertFalse(isUnlocked(.avantLeCoq, [session(day: 1, hour: 6)]))
    }

    func testGlobeTrotteurNeedsThreePlacesInOneDay() {
        let sameDay = [
            session(day: 2, hour: 8, place: .home),
            session(day: 2, hour: 12, place: .work),
            session(day: 2, hour: 19, place: .outside)
        ]
        XCTAssertTrue(isUnlocked(.globeTrotteur, sameDay))

        let spreadOut = [
            session(day: 2, place: .home),
            session(day: 3, place: .work),
            session(day: 4, place: .outside)
        ]
        XCTAssertFalse(isUnlocked(.globeTrotteur, spreadOut))
    }

    func testHorlogeSuisseToleratesAQuarterOfAnHour() {
        let regular = [
            session(day: 5, hour: 8, minute: 0),
            session(day: 6, hour: 8, minute: 12),
            session(day: 7, hour: 7, minute: 50)
        ]
        XCTAssertTrue(isUnlocked(.horlogeSuisse, regular))

        let drifting = [
            session(day: 5, hour: 8, minute: 0),
            session(day: 6, hour: 9, minute: 0),
            session(day: 7, hour: 10, minute: 0)
        ]
        XCTAssertFalse(isUnlocked(.horlogeSuisse, drifting))
    }

    func testHorlogeSuisseNeedsConsecutiveDays() {
        let withGap = [
            session(day: 5, hour: 8),
            session(day: 6, hour: 8),
            session(day: 8, hour: 8)
        ]
        XCTAssertFalse(isUnlocked(.horlogeSuisse, withGap))
    }

    func testSemaineParfaiteNeedsSevenConsecutiveDays() {
        let week = (1...7).map { session(day: $0) }
        XCTAssertTrue(isUnlocked(.semaineParfaite, week))

        let sixDays = (1...6).map { session(day: $0) }
        XCTAssertFalse(isUnlocked(.semaineParfaite, sixDays))
    }

    func testCenturion() {
        let many = (1...100).map { session(day: 1 + $0 % 28, hour: $0 % 24) }
        XCTAssertTrue(isUnlocked(.centurion, many))
        XCTAssertFalse(isUnlocked(.centurion, Array(many.dropLast())))
    }

    func testPenseurNeedsBothDurationAndComfort() {
        XCTAssertTrue(isUnlocked(.penseur, [session(day: 1, seconds: 16 * 60, comfort: 5)]))
        XCTAssertFalse(isUnlocked(.penseur, [session(day: 1, seconds: 16 * 60, comfort: 4)]))
        XCTAssertFalse(isUnlocked(.penseur, [session(day: 1, seconds: 10 * 60, comfort: 5)]))
    }

    func testCinqEtoilesNeedsTenPerfectVisits() {
        let ten = (1...10).map { session(day: $0, comfort: 5) }
        XCTAssertTrue(isUnlocked(.cinqEtoiles, ten))
        XCTAssertFalse(isUnlocked(.cinqEtoiles, Array(ten.dropLast())))
    }

    func testDoubleNeedsTwoVisitsWithinHalfAnHour() {
        XCTAssertTrue(isUnlocked(.double, [session(day: 1, hour: 9, minute: 0), session(day: 1, hour: 9, minute: 20)]))
        XCTAssertFalse(isUnlocked(.double, [session(day: 1, hour: 9, minute: 0), session(day: 1, hour: 10, minute: 0)]))
    }

    func testJourneeChargee() {
        let busy = (0..<5).map { session(day: 3, hour: 7 + $0 * 2) }
        XCTAssertTrue(isUnlocked(.journeeChargee, busy))
        XCTAssertFalse(isUnlocked(.journeeChargee, Array(busy.dropLast())))
    }

    func testBureauDiscret() {
        let work = (1...20).map { session(day: 1 + $0 % 28, hour: $0 % 24, place: .work) }
        XCTAssertTrue(isUnlocked(.bureauDiscret, work))
        XCTAssertFalse(isUnlocked(.bureauDiscret, Array(work.dropLast())))
    }

    func testUnlockedListMatchesIndividualChecks() {
        let sessions = [session(day: 1, seconds: 30), session(day: 1, hour: 3)]
        let list = AchievementEngine.unlocked(sessions: sessions, calendar: calendar)
        XCTAssertEqual(Set(list), Set([.debut, .eclair, .noctambule, .avantLeCoq]))
    }

    func testRanksCoverEveryCount() {
        var titles: Set<String> = []
        for count in 0...Achievement.allCases.count {
            let rank = AchievementEngine.rank(unlockedCount: count)
            XCTAssertFalse(rank.isEmpty)
            titles.insert(rank)
        }
        XCTAssertGreaterThanOrEqual(titles.count, 5)
    }

    func testAchievementsAreFullyDescribed() {
        for achievement in Achievement.allCases {
            XCTAssertFalse(achievement.title.isEmpty)
            XCTAssertGreaterThan(achievement.detail.count, 15)
            XCTAssertFalse(achievement.symbol.isEmpty)
        }
    }
}
