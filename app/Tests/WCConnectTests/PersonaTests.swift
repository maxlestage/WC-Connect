import XCTest
// Les sources partagées sont compilées directement dans la cible de test :
// les tests ne dépendent ni de l'app ni d'un simulateur hôte.

final class PersonaTests: XCTestCase {

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Paris") ?? .gmt
        return calendar
    }

    private func sessions(hour: Int, seconds: Double, count: Int = 4) -> [ToiletSession] {
        (1...count).compactMap { day in
            guard let start = calendar.date(from: DateComponents(year: 2026, month: 5, day: day, hour: hour)) else {
                return nil
            }
            return ToiletSession(startedAt: start, endedAt: start.addingTimeInterval(seconds))
        }
    }

    private func persona(hour: Int, seconds: Double) -> Persona {
        PersonaEngine.persona(sessions: sessions(hour: hour, seconds: seconds), calendar: calendar)
    }

    func testEmptyHistoryHasNoProfile() {
        let empty = PersonaEngine.persona(sessions: [], calendar: calendar)
        XCTAssertEqual(empty.title, "Profil vierge")
    }

    func testMorningSprinter() {
        XCTAssertEqual(persona(hour: 7, seconds: 60).title, "Le Sprinteur du matin")
    }

    func testEveningPhilosopher() {
        XCTAssertEqual(persona(hour: 20, seconds: 12 * 60).title, "Le Philosophe du soir")
    }

    func testLunchRegular() {
        XCTAssertEqual(persona(hour: 12, seconds: 5 * 60).title, "L'Habitué de la pause déjeuner")
    }

    func testNightGetsItsOwnNames() {
        XCTAssertEqual(persona(hour: 3, seconds: 60).title, "Le Fantôme nocturne")
        XCTAssertEqual(persona(hour: 3, seconds: 5 * 60).title, "Le Veilleur")
        XCTAssertEqual(persona(hour: 3, seconds: 12 * 60).title, "L'Ermite de la nuit")
    }

    func testTempoBoundaries() {
        XCTAssertEqual(PersonaEngine.Tempo.from(averageDuration: 119), .eclair)
        XCTAssertEqual(PersonaEngine.Tempo.from(averageDuration: 120), .regulier)
        XCTAssertEqual(PersonaEngine.Tempo.from(averageDuration: 8 * 60), .regulier)
        XCTAssertEqual(PersonaEngine.Tempo.from(averageDuration: 8 * 60 + 1), .contemplatif)
    }

    func testMomentBoundaries() {
        XCTAssertEqual(PersonaEngine.Moment.from(hour: 4), .nuit)
        XCTAssertEqual(PersonaEngine.Moment.from(hour: 5), .matin)
        XCTAssertEqual(PersonaEngine.Moment.from(hour: 11), .midi)
        XCTAssertEqual(PersonaEngine.Moment.from(hour: 14), .apresMidi)
        XCTAssertEqual(PersonaEngine.Moment.from(hour: 18), .soir)
        XCTAssertEqual(PersonaEngine.Moment.from(hour: 23), .nuit)
    }

    func testDetailMentionsDurationAndHour() {
        let profile = persona(hour: 9, seconds: 4 * 60)
        XCTAssertTrue(profile.detail.contains("min"))
        XCTAssertTrue(profile.detail.contains("9 h"))
        XCTAssertFalse(profile.symbol.isEmpty)
    }
}
