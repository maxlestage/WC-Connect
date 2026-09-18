import XCTest
// Jours sans visite, et alerte associée.

final class AbsenceEngineTests: XCTestCase {

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Paris") ?? .gmt
        return calendar
    }

    /// 15 mars 2026, 12 h.
    private var maintenant: Date {
        calendar.date(from: DateComponents(year: 2026, month: 3, day: 15, hour: 12)) ?? Date()
    }

    private func visite(day: Int, hour: Int = 9, terminee: Bool = true) -> ToiletSession {
        let debut = calendar.date(
            from: DateComponents(year: 2026, month: 3, day: day, hour: hour)
        ) ?? Date()
        return ToiletSession(
            startedAt: debut,
            endedAt: terminee ? debut.addingTimeInterval(240) : nil
        )
    }

    private func jours(_ sessions: [ToiletSession]) -> Int? {
        AbsenceEngine.daysSinceLastVisit(sessions: sessions, now: maintenant, calendar: calendar)
    }

    private func alerte(_ sessions: [ToiletSession], seuil: Int = 3) -> Date? {
        AbsenceEngine.nextAlert(
            sessions: sessions, thresholdDays: seuil, now: maintenant, calendar: calendar
        )
    }

    // MARK: - Jours écoulés

    func testHistoriqueVideNeDonneAucunJour() {
        XCTAssertNil(jours([]))
    }

    func testVisiteDuJourDonneZeroJour() {
        XCTAssertEqual(jours([visite(day: 15)]), 0)
    }

    func testTroisJoursSansVisite() {
        XCTAssertEqual(jours([visite(day: 12)]), 3)
    }

    func testSeuleLaDerniereVisiteCompte() {
        XCTAssertEqual(jours([visite(day: 1), visite(day: 13), visite(day: 8)]), 2)
    }

    func testVisiteEnCoursNeComptePas() {
        XCTAssertEqual(jours([visite(day: 10), visite(day: 15, terminee: false)]), 5)
    }

    // MARK: - Alerte

    func testAucuneAlerteSansHistorique() {
        XCTAssertNil(alerte([]))
    }

    func testAlerteTroisJoursApresLaDerniereVisite() {
        guard let date = alerte([visite(day: 14)]) else {
            return XCTFail("une alerte devrait être programmée")
        }
        let composants = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        XCTAssertEqual(composants.day, 17)
        XCTAssertEqual(composants.month, 3)
        XCTAssertEqual(composants.hour, AbsenceEngine.alertHour)
        XCTAssertEqual(AbsenceEngine.alertHour, 18)
    }

    func testAlerteToujoursDansLeFutur() {
        // Dernière visite il y a huit jours : la date théorique est passée,
        // il n'y a plus rien à programmer.
        XCTAssertNil(alerte([visite(day: 7)]))
    }

    func testAlerteDuJourMemeSeulementSiElleEstEncoreDevant() {
        // Visite le 12, seuil 3 → 15 mars à 18 h, et il est midi.
        XCTAssertNotNil(alerte([visite(day: 12)]))
        // Seuil 2 → 14 mars à 18 h, déjà passé.
        XCTAssertNil(alerte([visite(day: 12)], seuil: 2))
    }

    func testSeuilBorne() {
        // Un seuil aberrant est ramené dans les bornes plutôt que refusé.
        let avecUn = alerte([visite(day: 14)], seuil: 1)
        let avecDeux = alerte([visite(day: 14)], seuil: 2)
        XCTAssertEqual(avecUn, avecDeux, "un seuil sous la borne vaut la borne basse")
        XCTAssertEqual(AbsenceEngine.thresholdRange, 2...7)
    }

    func testResumeMentionneLesJours() {
        let phrase = AbsenceEngine.summary(days: 4)
        XCTAssertTrue(phrase.contains("4"), phrase)
        XCTAssertFalse(phrase.contains("%@"), "format non substitué : \(phrase)")
    }
}
