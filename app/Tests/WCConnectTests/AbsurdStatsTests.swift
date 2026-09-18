import XCTest
// Les sources partagées sont compilées directement dans la cible de test :
// les tests ne dépendent ni de l'app ni d'un simulateur hôte.

final class AbsurdStatsTests: XCTestCase {

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
        XCTAssertEqual(items.first { $0.id == "paper" }?.value, "0,0 m")
    }

    func testDecimalsUseAFrenchComma() {
        let items = AbsurdStats.equivalences(totalDuration: 3 * 3600, visitCount: 5)
        let tgv = items.first { $0.id == "tgv" }?.value ?? ""
        XCTAssertTrue(tgv.contains(","), "séparateur décimal inattendu : \(tgv)")
        XCTAssertFalse(tgv.contains("."))
    }

    func testWalkingDistanceSwitchesFromMetresToKilometres() {
        let short = AbsurdStats.equivalences(totalDuration: 300, visitCount: 1)
        XCTAssertEqual(short.first { $0.id == "walk" }?.value.hasSuffix(" m"), true)

        let long = AbsurdStats.equivalences(totalDuration: 3600, visitCount: 1)
        XCTAssertEqual(long.first { $0.id == "walk" }?.value, "5,0 km")
    }

    func testPaperSwitchesToKilometres() {
        // 5 feuilles de 12 cm par visite : 2 000 visites font 1,2 km.
        let items = AbsurdStats.equivalences(totalDuration: 0, visitCount: 2_000)
        XCTAssertEqual(items.first { $0.id == "paper" }?.value, "1,20 km")
    }

    func testHeadlineAdaptsToTheScale() {
        XCTAssertTrue(AbsurdStats.headline(totalDuration: 120).contains("début"))
        XCTAssertTrue(AbsurdStats.headline(totalDuration: 3 * 3600).contains("heures"))
        XCTAssertTrue(AbsurdStats.headline(totalDuration: 50 * 3600).contains("jours"))
    }
}
