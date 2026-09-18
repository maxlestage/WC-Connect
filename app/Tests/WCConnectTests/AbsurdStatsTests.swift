import XCTest
// Les sources partagées sont compilées directement dans la cible de test :
// les tests ne dépendent ni de l'app ni d'un simulateur hôte.

final class AbsurdStatsTests: XCTestCase {

    /// Séparateur décimal attendu : celui de la langue de l'appareil, puisque
    /// les conversions le suivent désormais.
    private var separator: String { Locale.current.decimalSeparator ?? "." }

    func testEquivalencesAreAlwaysProvided() {
        let items = AbsurdStats.equivalences(totalDuration: 0, visitCount: 0)
        XCTAssertEqual(items.count, 8)
        XCTAssertEqual(Set(items.map(\.id)).count, items.count)
        XCTAssertTrue(items.allSatisfy { !$0.value.isEmpty && !$0.label.isEmpty && !$0.symbol.isEmpty })
    }

    func testEpisodeCountUsesTwentyTwoMinutes() {
        let items = AbsurdStats.equivalences(totalDuration: 22 * 60 * 3, visitCount: 10)
        XCTAssertEqual(items.first { $0.id == "episodes" }?.value, "3")
    }

    func testCountsAreRoundedDown() {
        let items = AbsurdStats.equivalences(totalDuration: 22 * 60 * 2 + 21 * 60, visitCount: 1)
        XCTAssertEqual(items.first { $0.id == "episodes" }?.value, "2")
    }

    func testNegativeDurationIsClamped() {
        let items = AbsurdStats.equivalences(totalDuration: -500, visitCount: -3)
        XCTAssertEqual(items.first { $0.id == "episodes" }?.value, "0")
        XCTAssertEqual(items.first { $0.id == "paper" }?.value, "0\(separator)0 m")
    }

    func testDecimalsFollowTheDeviceLanguage() {
        let items = AbsurdStats.equivalences(totalDuration: 3 * 3600, visitCount: 5)
        let tgv = items.first { $0.id == "tgv" }?.value ?? ""
        XCTAssertTrue(tgv.contains(separator), "séparateur décimal inattendu : \(tgv)")
        if separator != "." {
            XCTAssertFalse(tgv.contains("."), "le point ne devrait pas subsister : \(tgv)")
        }
    }

    func testWalkingDistanceSwitchesFromMetresToKilometres() {
        let short = AbsurdStats.equivalences(totalDuration: 300, visitCount: 1)
        XCTAssertEqual(short.first { $0.id == "walk" }?.value.hasSuffix(" m"), true)

        let long = AbsurdStats.equivalences(totalDuration: 3600, visitCount: 1)
        XCTAssertEqual(long.first { $0.id == "walk" }?.value, "5\(separator)0 km")
    }

    func testPaperSwitchesToKilometres() {
        // 5 feuilles de 12 cm par visite : 2 000 visites font 1,2 km.
        let items = AbsurdStats.equivalences(totalDuration: 0, visitCount: 2_000)
        XCTAssertEqual(items.first { $0.id == "paper" }?.value, "1\(separator)20 km")
    }

    func testLifetimeDaysMatchTheArithmetic() {
        // 2 visites de 4 minutes par jour pendant 50 ans.
        let days = AbsurdStats.lifetimeDays(averagePerDay: 2, averageDuration: 240, years: 50)
        XCTAssertEqual(days, 2 * 240 * 365 * 50 / 86_400, accuracy: 0.001)
        XCTAssertEqual(days, 101.39, accuracy: 0.05)
    }

    func testLifetimeDaysClampNegativeInput() {
        XCTAssertEqual(AbsurdStats.lifetimeDays(averagePerDay: -2, averageDuration: 240), 0)
        XCTAssertEqual(AbsurdStats.lifetimeDays(averagePerDay: 2, averageDuration: -240), 0)
        XCTAssertEqual(AbsurdStats.lifetimeDays(averagePerDay: 2, averageDuration: 240, years: 0), 0)
    }

    func testLifetimeSentenceScales() {
        XCTAssertTrue(AbsurdStats.lifetimeSentence(averagePerDay: 0.001, averageDuration: 240)
            .contains("moins d'une journée"))
        XCTAssertTrue(AbsurdStats.lifetimeSentence(averagePerDay: 1, averageDuration: 60)
            .contains("jours"))
        XCTAssertTrue(AbsurdStats.lifetimeSentence(averagePerDay: 2.4, averageDuration: 252)
            .contains("mois"))
    }

    func testHeadlineAdaptsToTheScale() {
        XCTAssertTrue(AbsurdStats.headline(totalDuration: 120).contains("début"))
        XCTAssertTrue(AbsurdStats.headline(totalDuration: 3 * 3600).contains("heures"))
        XCTAssertTrue(AbsurdStats.headline(totalDuration: 50 * 3600).contains("jours"))
    }
}
