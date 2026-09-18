import XCTest
// Les sources partagées sont compilées directement dans la cible de test :
// les tests ne dépendent ni de l'app ni d'un simulateur hôte.

final class FormatTests: XCTestCase {

    func testClockUsesMinutesAndSeconds() {
        XCTAssertEqual(WCFormat.clock(0), "0:00")
        XCTAssertEqual(WCFormat.clock(9), "0:09")
        XCTAssertEqual(WCFormat.clock(247), "4:07")
    }

    func testClockAddsHoursWhenNeeded() {
        XCTAssertEqual(WCFormat.clock(3753), "1:02:33")
    }

    func testClockClampsNegativeValues() {
        XCTAssertEqual(WCFormat.clock(-42), "0:00")
    }

    func testDurationIsReadable() {
        XCTAssertEqual(WCFormat.duration(45), "45 s")
        XCTAssertEqual(WCFormat.duration(247), "4 min 07 s")
        XCTAssertEqual(WCFormat.duration(3753), "1 h 02 min")
    }

    func testSessionDurationUsesNowWhileRunning() {
        let start = Date()
        let session = ToiletSession(startedAt: start)
        XCTAssertNil(session.finalDuration)
        XCTAssertEqual(session.duration(now: start.addingTimeInterval(30)), 30, accuracy: 0.001)
    }

    func testGoalsAreOrderedByKind() {
        XCTAssertLessThan(SessionKind.quick.goal, SessionKind.standard.goal)
        XCTAssertLessThan(SessionKind.standard.goal, SessionKind.long.goal)
    }

    func testJoursSuiventLaLangue() {
        // La table française est l'identité : on vérifie la forme, pas la
        // traduction (couverte par LocalizationTests).
        XCTAssertEqual(WCFormat.days(12), "12 j")
        XCTAssertEqual(WCFormat.days(0), "0 j")
    }
}
