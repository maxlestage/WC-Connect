import XCTest
// Les sources partagées sont compilées directement dans la cible de test :
// les tests ne dépendent ni de l'app ni d'un simulateur hôte.

final class HaikuTests: XCTestCase {

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Paris") ?? .gmt
        return calendar
    }

    private func session(hour: Int, seconds: Double, id: UUID = UUID()) -> ToiletSession {
        let start = calendar.date(from: DateComponents(year: 2026, month: 6, day: 10, hour: hour)) ?? Date()
        let kind: SessionKind = seconds < 120 ? .quick : (seconds > 8 * 60 ? .long : .standard)
        return ToiletSession(id: id, startedAt: start, endedAt: start.addingTimeInterval(seconds), kind: kind)
    }

    func testTroisVersNonVides() {
        let poeme = HaikuEngine.haiku(for: session(hour: 9, seconds: 240), calendar: calendar)
        XCTAssertEqual(poeme.lines.count, 3)
        XCTAssertTrue(poeme.lines.allSatisfy { !$0.isEmpty })
        XCTAssertEqual(poeme.text.split(separator: "\n").count, 3)
    }

    func testDeterministePourUneMemeVisite() {
        let visite = session(hour: 9, seconds: 240)
        XCTAssertEqual(
            HaikuEngine.haiku(for: visite, calendar: calendar),
            HaikuEngine.haiku(for: visite, calendar: calendar),
            "le même passage doit donner le même poème"
        )
    }

    func testDeuxVisitesDifferentesDonnentSouventDesPoemesDifferents() {
        let poemes = (0..<12).map { _ in
            HaikuEngine.haiku(for: session(hour: 9, seconds: 240, id: UUID()), calendar: calendar).text
        }
        XCTAssertGreaterThan(Set(poemes).count, 1, "le générateur ne doit pas être constant")
    }

    func testLeDeuxiemeVersSuitLaDuree() {
        // La durée pilote le vers central : un passage express et une longue
        // méditation ne peuvent pas partager le même.
        let identifiant = UUID()
        let express = HaikuEngine.haiku(for: session(hour: 9, seconds: 60, id: identifiant), calendar: calendar)
        let longue = HaikuEngine.haiku(for: session(hour: 9, seconds: 15 * 60, id: identifiant), calendar: calendar)

        XCTAssertEqual(express.first, longue.first, "même graine, même premier vers")
        XCTAssertNotEqual(express.second, longue.second)
    }

    func testLeTroisiemeVersSuitLHeure() {
        let identifiant = UUID()
        let matin = HaikuEngine.haiku(for: session(hour: 7, seconds: 240, id: identifiant), calendar: calendar)
        let nuit = HaikuEngine.haiku(for: session(hour: 2, seconds: 240, id: identifiant), calendar: calendar)
        XCTAssertNotEqual(matin.third, nuit.third)
    }

    func testInventaireDesVers() {
        // 6 ouvertures + 9 vers centraux + 15 chutes.
        XCTAssertEqual(HaikuEngine.verseCount, 30)
    }
}
