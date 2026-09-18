import XCTest
// Les sources partagées sont compilées directement dans la cible de test :
// les tests ne dépendent ni de l'app ni d'un simulateur hôte.

final class StatsEngineTests: XCTestCase {

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Paris") ?? .gmt
        return calendar
    }

    private func date(_ day: Int, hour: Int = 9) -> Date {
        calendar.date(from: DateComponents(year: 2026, month: 3, day: day, hour: hour)) ?? Date()
    }

    private func session(day: Int, hour: Int = 9, minutes: Double = 4, place: Place = .home, comfort: Int? = nil) -> ToiletSession {
        let start = date(day, hour: hour)
        return ToiletSession(
            startedAt: start,
            endedAt: start.addingTimeInterval(minutes * 60),
            place: place,
            comfort: comfort
        )
    }

    func testEmptyHistoryProducesEmptyWeek() {
        let stats = StatsEngine.compute(sessions: [], now: date(10), calendar: calendar)
        XCTAssertEqual(stats.total, 0)
        XCTAssertEqual(stats.week.count, 7)
        XCTAssertTrue(stats.week.allSatisfy { $0.count == 0 })
    }

    func testRunningSessionsAreExcluded() {
        let running = ToiletSession(startedAt: date(10), endedAt: nil)
        let stats = StatsEngine.compute(sessions: [running, session(day: 10)], now: date(10), calendar: calendar)
        XCTAssertEqual(stats.total, 1)
    }

    func testAveragesAndTotals() {
        let sessions = [
            session(day: 9, minutes: 2),
            session(day: 10, hour: 8, minutes: 4),
            session(day: 10, hour: 20, minutes: 6)
        ]
        let stats = StatsEngine.compute(sessions: sessions, now: date(10), calendar: calendar)

        XCTAssertEqual(stats.total, 3)
        XCTAssertEqual(stats.today, 2)
        XCTAssertEqual(stats.totalDuration, 12 * 60)
        XCTAssertEqual(stats.averageDuration, 4 * 60)
        XCTAssertEqual(stats.longestDuration, 6 * 60)
        // Deux jours couverts, trois visites.
        XCTAssertEqual(stats.averagePerDay, 1.5, accuracy: 0.001)
    }

    func testBusiestHourPrefersEarliestOnTie() {
        let sessions = [
            session(day: 10, hour: 8),
            session(day: 9, hour: 8),
            session(day: 10, hour: 21),
            session(day: 9, hour: 21)
        ]
        let stats = StatsEngine.compute(sessions: sessions, now: date(10), calendar: calendar)
        XCTAssertEqual(stats.busiestHour, 8)
    }

    func testStreakCountsConsecutiveDays() {
        let sessions = [session(day: 10), session(day: 9), session(day: 8), session(day: 6)]
        XCTAssertEqual(StatsEngine.streak(sessions: sessions, now: date(10), calendar: calendar), 3)
    }

    func testStreakToleratesAnEmptyCurrentDay() {
        let sessions = [session(day: 9), session(day: 8)]
        XCTAssertEqual(StatsEngine.streak(sessions: sessions, now: date(10), calendar: calendar), 2)
    }

    func testStreakIsZeroWhenHistoryIsStale() {
        let sessions = [session(day: 5)]
        XCTAssertEqual(StatsEngine.streak(sessions: sessions, now: date(10), calendar: calendar), 0)
    }

    func testWeekIsOrderedOldestFirstAndCoversSevenDays() {
        let sessions = [session(day: 10), session(day: 10), session(day: 8)]
        let week = StatsEngine.week(sessions: sessions, now: date(10), calendar: calendar)

        XCTAssertEqual(week.count, 7)
        XCTAssertEqual(week.map(\.count), [0, 0, 0, 0, 1, 0, 2])
        XCTAssertEqual(week.last?.date, calendar.startOfDay(for: date(10)))
    }

    func testAverageComfortIgnoresMissingRatings() {
        let sessions = [
            session(day: 10, comfort: 5),
            session(day: 10, hour: 12, comfort: 3),
            session(day: 10, hour: 15, comfort: nil)
        ]
        let stats = StatsEngine.compute(sessions: sessions, now: date(10), calendar: calendar)
        XCTAssertEqual(stats.averageComfort ?? 0, 4, accuracy: 0.001)
    }

    func testHourBucketsCoverTheWholeDay() {
        let sessions = [session(day: 10, hour: 1), session(day: 10, hour: 2), session(day: 10, hour: 23)]
        let buckets = StatsEngine.hourBuckets(sessions: sessions, blockSize: 3, calendar: calendar)

        XCTAssertEqual(buckets.count, 8)
        XCTAssertEqual(buckets.first?.count, 2)
        XCTAssertEqual(buckets.last?.count, 1)
    }

    func testByPlaceCounts() {
        let sessions = [
            session(day: 10, place: .home),
            session(day: 10, hour: 11, place: .work),
            session(day: 10, hour: 14, place: .work)
        ]
        let stats = StatsEngine.compute(sessions: sessions, now: date(10), calendar: calendar)
        XCTAssertEqual(stats.byPlace[.work], 2)
        XCTAssertEqual(stats.byPlace[.home], 1)
        XCTAssertNil(stats.byPlace[.outside])
    }

    // MARK: - Journal

    private func journal(day: Int, hour: Int = 9, bristol: Bristol?, effort: Int? = nil, symptoms: [Symptom]? = nil) -> ToiletSession {
        let start = date(day, hour: hour)
        return ToiletSession(
            startedAt: start,
            endedAt: start.addingTimeInterval(4 * 60),
            bristol: bristol,
            effort: effort,
            symptoms: symptoms
        )
    }

    func testJournalAgregeConsistanceEtSymptomes() {
        let sessions = [
            journal(day: 10, bristol: .one, effort: 4, symptoms: [.straining, .incomplete]),
            journal(day: 10, hour: 12, bristol: .one, effort: 2, symptoms: [.straining]),
            journal(day: 10, hour: 16, bristol: .four, symptoms: [])
        ]
        let stats = StatsEngine.compute(sessions: sessions, now: date(10), calendar: calendar)

        XCTAssertEqual(stats.byBristol[.one], 2)
        XCTAssertEqual(stats.byBristol[.four], 1)
        XCTAssertNil(stats.byBristol[.seven])
        XCTAssertEqual(stats.bySymptom[.straining], 2)
        XCTAssertEqual(stats.bySymptom[.incomplete], 1)
        XCTAssertNil(stats.bySymptom[.blood])
        XCTAssertEqual(stats.averageEffort ?? 0, 3, accuracy: 0.001)
    }

    func testJournalVideNeProduitAucuneAgregation() {
        let sessions = [session(day: 10), session(day: 10, hour: 15)]
        let stats = StatsEngine.compute(sessions: sessions, now: date(10), calendar: calendar)

        XCTAssertTrue(stats.byBristol.isEmpty)
        XCTAssertTrue(stats.bySymptom.isEmpty)
        XCTAssertNil(stats.averageEffort)
    }

    func testStatsVidesNOntPasDeJournal() {
        XCTAssertTrue(Stats.empty.byBristol.isEmpty)
        XCTAssertTrue(Stats.empty.bySymptom.isEmpty)
        XCTAssertNil(Stats.empty.averageEffort)
    }
}
