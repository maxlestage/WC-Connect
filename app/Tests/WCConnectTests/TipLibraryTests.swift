import XCTest
// Les sources partagées sont compilées directement dans la cible de test :
// les tests ne dépendent ni de l'app ni d'un simulateur hôte.

final class TipLibraryTests: XCTestCase {

    func testEveryCategoryHasAtLeastOneTip() {
        for category in TipCategory.allCases {
            XCTAssertFalse(TipLibrary.tips(for: category).isEmpty, "catégorie vide : \(category.title)")
        }
    }

    func testIdentifiersAreUnique() {
        let identifiers = TipLibrary.all.map(\.id)
        XCTAssertEqual(Set(identifiers).count, identifiers.count)
    }

    func testImmediateTipsExistForTheVisitItself() {
        XCTAssertGreaterThanOrEqual(TipLibrary.immediate.count, 3)
        XCTAssertTrue(TipLibrary.immediate.allSatisfy(\.isImmediate))
    }

    func testSuggestionsAreStableForTheSameSeed() {
        XCTAssertEqual(TipLibrary.suggestions(seed: 42), TipLibrary.suggestions(seed: 42))
    }

    func testSuggestionsHaveNoDuplicates() {
        for seed in [0, 1, 7, 42, -13, Int.max] {
            let ids = TipLibrary.suggestions(seed: seed).map(\.id)
            XCTAssertEqual(Set(ids).count, ids.count, "doublon pour la graine \(seed)")
        }
    }

    func testSuggestionsRespectTheRequestedCount() {
        XCTAssertEqual(TipLibrary.suggestions(seed: 3, count: 2).count, 2)
        // Jamais plus que le vivier disponible.
        XCTAssertEqual(
            TipLibrary.suggestions(seed: 3, count: 99).count,
            TipLibrary.immediate.count
        )
    }

    func testRedFlagsAreProvided() {
        XCTAssertGreaterThanOrEqual(TipLibrary.redFlags.count, 5)
        XCTAssertTrue(TipLibrary.redFlags.allSatisfy { !$0.isEmpty })
    }

    func testDisclaimerMentionsThatItIsNotMedicalAdvice() {
        XCTAssertTrue(TipLibrary.disclaimer.lowercased().contains("dispositif médical"))
    }

    func testEveryTipHasReadableContent() {
        for tip in TipLibrary.all {
            XCTAssertFalse(tip.title.isEmpty, "titre vide : \(tip.id)")
            XCTAssertGreaterThan(tip.detail.count, 30, "détail trop court : \(tip.id)")
        }
    }

    func testSoundscapesAreDistinctAndNamed() {
        let names = Soundscape.allCases.map(\.resourceName)
        XCTAssertEqual(Set(names).count, names.count)
        XCTAssertTrue(Soundscape.allCases.allSatisfy { !$0.title.isEmpty && !$0.symbol.isEmpty })
    }
}
