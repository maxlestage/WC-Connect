import XCTest
// Objectif de la semaine : régularité sur sept jours et visites qui ne
// s'éternisent pas.

final class WeeklyGoalTests: XCTestCase {

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Paris") ?? .gmt
        return calendar
    }

    private let maintenant = Date(timeIntervalSince1970: 1_800_000_000)

    /// Une visite terminée, `jours` jours avant `maintenant`.
    private func visite(ilYA jours: Double, minutes: Double = 4) -> ToiletSession {
        let debut = maintenant.addingTimeInterval(-jours * 86_400)
        return ToiletSession(startedAt: debut, endedAt: debut.addingTimeInterval(minutes * 60))
    }

    private func progres(_ sessions: [ToiletSession], goal: WeeklyGoal = .default) -> GoalProgress {
        GoalEngine.progress(sessions: sessions, goal: goal, now: maintenant, calendar: calendar)
    }

    // MARK: - Objectif

    func testObjectifParDefautModeste() {
        XCTAssertEqual(WeeklyGoal.default.activeDays, 5)
        XCTAssertEqual(WeeklyGoal.default.maxAverageDuration, 6 * 60)
    }

    func testObjectifBorneSesValeurs() {
        XCTAssertEqual(WeeklyGoal(activeDays: 0).activeDays, 1)
        XCTAssertEqual(WeeklyGoal(activeDays: 99).activeDays, 7)
        XCTAssertEqual(WeeklyGoal(activeDays: 3).activeDays, 3)
        XCTAssertEqual(WeeklyGoal(maxAverageDuration: 0).maxAverageDuration, 60)
    }

    // MARK: - Avancement

    func testHistoriqueVideNAtteintPasLObjectif() {
        let p = progres([])
        XCTAssertEqual(p.daysWithVisit, 0)
        XCTAssertEqual(p.regularity, 0)
        XCTAssertFalse(p.isRegular)
        // Rien de mesuré : on ne reproche pas une durée qui n'existe pas.
        XCTAssertTrue(p.isBrief)
        XCTAssertFalse(p.isReached)
    }

    func testPlusieursVisitesLeMemeJourNeComptentQuUneFois() {
        let jour = [visite(ilYA: 1), visite(ilYA: 1.1), visite(ilYA: 1.2)]
        XCTAssertEqual(progres(jour).daysWithVisit, 1)
    }

    func testCinqJoursDeVisitesCourtesAtteignentLObjectif() {
        let sessions = (1...5).map { visite(ilYA: Double($0), minutes: 3) }
        let p = progres(sessions)
        XCTAssertEqual(p.daysWithVisit, 5)
        XCTAssertEqual(p.regularity, 1)
        XCTAssertTrue(p.isRegular)
        XCTAssertTrue(p.isBrief)
        XCTAssertTrue(p.isReached)
    }

    func testRegulariteTenueMaisVisitesTropLongues() {
        let sessions = (1...5).map { visite(ilYA: Double($0), minutes: 15) }
        let p = progres(sessions)
        XCTAssertTrue(p.isRegular)
        XCTAssertFalse(p.isBrief)
        XCTAssertFalse(p.isReached)
    }

    func testRegulariteNeDepassePasUn() {
        let sessions = (1...7).map { visite(ilYA: Double($0), minutes: 2) }
        XCTAssertEqual(progres(sessions).daysWithVisit, 7)
        XCTAssertEqual(progres(sessions).regularity, 1)
    }

    func testVisitesTropAnciennesSontIgnorees() {
        let sessions = [visite(ilYA: 8), visite(ilYA: 20), visite(ilYA: 1)]
        XCTAssertEqual(progres(sessions).daysWithVisit, 1)
    }

    func testVisiteEnCoursIgnoree() {
        let encours = ToiletSession(startedAt: maintenant.addingTimeInterval(-600))
        XCTAssertEqual(progres([encours]).daysWithVisit, 0)
    }

    func testVisiteDansLeFuturIgnoree() {
        let debut = maintenant.addingTimeInterval(3_600)
        let future = ToiletSession(startedAt: debut, endedAt: debut.addingTimeInterval(120))
        XCTAssertEqual(progres([future]).daysWithVisit, 0)
    }

    func testMoyenneCalculeeSurLesVisitesRetenues() {
        let sessions = [visite(ilYA: 1, minutes: 2), visite(ilYA: 2, minutes: 6)]
        XCTAssertEqual(progres(sessions).averageDuration, 4 * 60, accuracy: 0.5)
    }

    // MARK: - Résumés

    func testResumeNonVideDansLesTroisCas() {
        let atteint = progres((1...5).map { visite(ilYA: Double($0), minutes: 3) })
        let longues = progres((1...5).map { visite(ilYA: Double($0), minutes: 15) })
        let irregulier = progres([visite(ilYA: 1)])

        for p in [atteint, longues, irregulier] {
            XCTAssertFalse(p.summary.isEmpty)
            XCTAssertFalse(p.summary.contains("%@"), "format non substitué : \(p.summary)")
        }
        XCTAssertNotEqual(atteint.summary, longues.summary)
        XCTAssertNotEqual(atteint.summary, irregulier.summary)
    }

    func testResumeMentionneLesJoursQuandLaRegulariteManque() {
        let p = progres([visite(ilYA: 1), visite(ilYA: 2)])
        XCTAssertTrue(p.summary.contains("2"), p.summary)
        XCTAssertTrue(p.summary.contains("5"), p.summary)
    }
}
