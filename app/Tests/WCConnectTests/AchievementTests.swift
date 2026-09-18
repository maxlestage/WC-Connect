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

    // MARK: - Hauts faits secrets

    func testCoupDeMinuit() {
        XCTAssertTrue(isUnlocked(.coupDeMinuit, [session(day: 3, hour: 0, minute: 2)]))
        XCTAssertFalse(isUnlocked(.coupDeMinuit, [session(day: 3, hour: 0, minute: 6)]))
        XCTAssertFalse(isUnlocked(.coupDeMinuit, [session(day: 3, hour: 1, minute: 0)]))
    }

    func testReveillon() {
        let saintSylvestre = calendar.date(from: DateComponents(year: 2026, month: 12, day: 31, hour: 22)) ?? Date()
        let premierJanvier = calendar.date(from: DateComponents(year: 2027, month: 1, day: 1, hour: 2)) ?? Date()
        let banal = calendar.date(from: DateComponents(year: 2026, month: 12, day: 30, hour: 22)) ?? Date()

        for date in [saintSylvestre, premierJanvier] {
            let visite = ToiletSession(startedAt: date, endedAt: date.addingTimeInterval(240))
            XCTAssertTrue(isUnlocked(.reveillon, [visite]))
        }
        let ordinaire = ToiletSession(startedAt: banal, endedAt: banal.addingTimeInterval(240))
        XCTAssertFalse(isUnlocked(.reveillon, [ordinaire]))
    }

    func testNombrePi() {
        XCTAssertTrue(isUnlocked(.nombrePi, [session(day: 3, seconds: 194)]))
        XCTAssertFalse(isUnlocked(.nombrePi, [session(day: 3, seconds: 195)]))
    }

    func testTriple() {
        let serree = [
            session(day: 4, hour: 9, minute: 0),
            session(day: 4, hour: 9, minute: 20),
            session(day: 4, hour: 9, minute: 50)
        ]
        XCTAssertTrue(isUnlocked(.triple, serree))

        let etalee = [
            session(day: 4, hour: 9, minute: 0),
            session(day: 4, hour: 10, minute: 30),
            session(day: 4, hour: 12, minute: 0)
        ]
        XCTAssertFalse(isUnlocked(.triple, etalee))
    }

    func testJourSansFin() {
        let jumelles = [session(day: 5, hour: 8, seconds: 231), session(day: 5, hour: 18, seconds: 231)]
        XCTAssertTrue(isUnlocked(.jourSansFin, jumelles))

        let distinctes = [session(day: 5, hour: 8, seconds: 231), session(day: 5, hour: 18, seconds: 232)]
        XCTAssertFalse(isUnlocked(.jourSansFin, distinctes))
    }

    func testLesSecretsSontMarquesCommeTels() {
        let secrets = Achievement.allCases.filter(\.isSecret)
        XCTAssertEqual(secrets.count, 5)
        XCTAssertFalse(Achievement.debut.isSecret)
        XCTAssertTrue(Achievement.nombrePi.isSecret)
    }

    func testUnlockedListMatchesIndividualChecks() {
        let sessions = [session(day: 1, seconds: 30), session(day: 1, hour: 3)]
        let list = AchievementEngine.unlocked(sessions: sessions, calendar: calendar)
        XCTAssertEqual(Set(list), Set([.debut, .eclair, .noctambule, .avantLeCoq]))
    }

    func testNewlyUnlockedListsOnlyTheGains() {
        let before = [session(day: 1)]
        let after = before + [session(day: 1, hour: 3, seconds: 30)]

        let gains = AchievementEngine.newlyUnlocked(previous: before, current: after, calendar: calendar)
        XCTAssertEqual(Set(gains), Set([.eclair, .noctambule, .avantLeCoq]))
        XCTAssertFalse(gains.contains(.debut), "déjà acquis avant")
    }

    func testNewlyUnlockedIsEmptyWithoutProgress() {
        let sessions = [session(day: 1)]
        XCTAssertTrue(AchievementEngine.newlyUnlocked(previous: sessions, current: sessions, calendar: calendar).isEmpty)
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
