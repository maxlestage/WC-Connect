import XCTest
// Créneau de la veilleuse : le cas qui compte est celui qui traverse minuit.

final class CalmSettingsTests: XCTestCase {

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Paris") ?? .gmt
        return calendar
    }

    private func date(hour: Int) -> Date {
        calendar.date(
            from: DateComponents(year: 2026, month: 3, day: 15, hour: hour, minute: 30)
        ) ?? Date()
    }

    private func nuit(_ hour: Int, start: Int = 22, end: Int = 7) -> Bool {
        CalmSettings.isNight(at: date(hour: hour), start: start, end: end, calendar: calendar)
    }

    // MARK: - Créneau qui traverse minuit (le réglage par défaut : 22 h → 7 h)

    func testAvantLeDebutIlFaitJour() {
        XCTAssertFalse(nuit(21))
    }

    func testLHeureDeDebutEstDejaLaNuit() {
        XCTAssertTrue(nuit(22))
    }

    func testApresMinuitIlFaitEncoreNuit() {
        XCTAssertTrue(nuit(0))
        XCTAssertTrue(nuit(3))
        XCTAssertTrue(nuit(6))
    }

    func testLHeureDeFinEstDejaLeJour() {
        XCTAssertFalse(nuit(7))
        XCTAssertFalse(nuit(12))
    }

    // MARK: - Créneau dans la même journée

    func testCreneauSansPassageParMinuit() {
        XCTAssertFalse(nuit(12, start: 13, end: 18))
        XCTAssertTrue(nuit(13, start: 13, end: 18))
        XCTAssertTrue(nuit(17, start: 13, end: 18))
        XCTAssertFalse(nuit(18, start: 13, end: 18))
    }

    // MARK: - Cas limites

    /// Début et fin identiques : le créneau est vide, pas plein. Une veilleuse
    /// allumée en permanence par un réglage mal fichu serait pire que rien.
    func testCreneauVideQuandDebutEgaleFin() {
        for heure in 0...23 {
            XCTAssertFalse(nuit(heure, start: 22, end: 22), "heure \(heure)")
        }
    }

    /// Des heures hors bornes sont ramenées dans 0...23 plutôt que d'ouvrir un
    /// créneau absurde.
    func testHeuresHorsBornesRamenees() {
        XCTAssertTrue(nuit(23, start: 99, end: -4))
        XCTAssertFalse(nuit(12, start: 99, end: -4))
    }

    /// Minuit pile compte comme nuit dans un créneau qui traverse minuit.
    func testMinuitPileEstLaNuit() {
        let minuit = calendar.date(
            from: DateComponents(year: 2026, month: 3, day: 15, hour: 0, minute: 0)
        ) ?? Date()
        XCTAssertTrue(CalmSettings.isNight(at: minuit, start: 22, end: 7, calendar: calendar))
    }
}
