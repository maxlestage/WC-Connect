import XCTest
// Les sources partagées sont compilées directement dans la cible de test :
// les tests ne dépendent ni de l'app ni d'un simulateur hôte.

@MainActor
final class SessionStoreTests: XCTestCase {

    private func makeStore() -> SessionStore {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("wc-tests-\(UUID().uuidString).json")
        return SessionStore(storage: SessionStorage(fileURL: url))
    }

    func testStartThenStopMovesSessionToHistory() {
        let store = makeStore()
        let start = Date().addingTimeInterval(-300)

        store.start(kind: .long, place: .work, source: .watch, at: start)
        XCTAssertNotNil(store.active)
        XCTAssertTrue(store.sessions.isEmpty)

        let stopped = store.stop(comfort: 4, note: "  ", at: start.addingTimeInterval(300))
        XCTAssertNil(store.active)
        XCTAssertEqual(store.sessions.count, 1)
        XCTAssertEqual(stopped?.finalDuration, 300)
        XCTAssertEqual(stopped?.comfort, 4)
        // Une note vide ne doit pas être enregistrée.
        XCTAssertNil(stopped?.note)
    }

    func testStartingTwiceClosesThePreviousVisit() {
        let store = makeStore()
        store.start(at: Date().addingTimeInterval(-600))
        store.start(at: Date())

        XCTAssertEqual(store.sessions.count, 1)
        XCTAssertNotNil(store.active)
    }

    func testCancelDiscardsTheVisit() {
        let store = makeStore()
        store.start()
        store.cancel()

        XCTAssertNil(store.active)
        XCTAssertTrue(store.sessions.isEmpty)
    }

    func testStopWithoutActiveSessionReturnsNil() {
        let store = makeStore()
        XCTAssertNil(store.stop())
    }

    func testStateIsPersistedAndReloaded() {
        let url = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("wc-tests-\(UUID().uuidString).json")
        let storage = SessionStorage(fileURL: url)

        let store = SessionStore(storage: storage)
        let start = Date().addingTimeInterval(-120)
        store.start(at: start)
        store.stop(at: start.addingTimeInterval(120))

        let reloaded = SessionStore(storage: storage)
        XCTAssertEqual(reloaded.sessions.count, 1)
        XCTAssertEqual(reloaded.sessions.first?.finalDuration, 120)
    }

    func testRemoteMergeKeepsFinishedVersionOfASession() {
        let store = makeStore()
        let start = Date().addingTimeInterval(-200)
        store.start(at: start)
        guard let active = store.active else { return XCTFail("visite active attendue") }

        var finished = active
        finished.endedAt = start.addingTimeInterval(200)

        store.apply(remote: SessionState(sessions: [finished], active: nil, updatedAt: Date().addingTimeInterval(60)))

        XCTAssertNil(store.active, "une visite clôturée sur l'autre appareil doit libérer le chronomètre")
        XCTAssertEqual(store.sessions.count, 1)
        XCTAssertEqual(store.sessions.first?.id, active.id)
    }

    func testRemoteMergeDeduplicatesSessions() {
        let store = makeStore()
        let start = Date().addingTimeInterval(-3600)
        let session = ToiletSession(startedAt: start, endedAt: start.addingTimeInterval(180))
        store.add(session)

        store.apply(remote: SessionState(sessions: [session], active: nil, updatedAt: Date()))
        XCTAssertEqual(store.sessions.count, 1)
    }

    func testOlderRemoteStateDoesNotResurrectAnActiveVisit() {
        let store = makeStore()
        let stale = ToiletSession(startedAt: Date().addingTimeInterval(-7200))
        store.apply(remote: SessionState(sessions: [], active: stale, updatedAt: .distantPast))
        XCTAssertNil(store.active)
    }

    func testHistoryIsSortedMostRecentFirst() {
        let store = makeStore()
        let now = Date()
        for offset in [3600.0, 60.0, 7200.0] {
            let start = now.addingTimeInterval(-offset)
            store.add(ToiletSession(startedAt: start, endedAt: start.addingTimeInterval(60)))
        }
        let dates = store.sessions.map(\.startedAt)
        XCTAssertEqual(dates, dates.sorted(by: >))
    }

    func testExportCSVHasHeaderAndOneLinePerSession() {
        let store = makeStore()
        let start = Date().addingTimeInterval(-600)
        store.add(ToiletSession(startedAt: start, endedAt: start.addingTimeInterval(240), note: "avec des \"guillemets\""))

        let lines = store.exportCSV().split(separator: "\n")
        XCTAssertEqual(lines.count, 2)
        XCTAssertTrue(lines[0].hasPrefix("debut,fin,duree_secondes"))
        XCTAssertTrue(lines[1].contains("240"))
        XCTAssertTrue(lines[1].contains("\"\"guillemets\"\""))
    }
}
