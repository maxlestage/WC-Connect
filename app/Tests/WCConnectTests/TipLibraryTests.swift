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

    // MARK: - Sans se lever

    func testLaFamilleSansSeLeverExisteEtEstFournie() {
        let assis = TipLibrary.tips(for: .seated)
        XCTAssertGreaterThanOrEqual(assis.count, 5, "cette famille doit couvrir le sujet, pas l'effleurer")
        for conseil in assis {
            XCTAssertEqual(conseil.category, .seated)
            XCTAssertFalse(conseil.title.isEmpty, conseil.id)
            XCTAssertFalse(conseil.detail.isEmpty, conseil.id)
        }
    }

    func testDesConseilsAssisSontUtilisablesPendantLaVisite() {
        // Soulager la pression et limiter la durée n'ont d'intérêt que si
        // l'app les propose au moment où l'on est assis.
        let immediats = TipLibrary.tips(for: .seated).filter(\.isImmediate)
        XCTAssertGreaterThanOrEqual(immediats.count, 2)
    }

    func testAucunConseilAssisNeDemandeDeSeLeverOuDeMarcher() {
        // Le reproche fait aux autres familles : « levez-vous », « marchez ».
        // Cette famille existe précisément pour ne pas le faire.
        let interdits = ["levez-vous", "marchez", "debout", "en marchant"]
        for conseil in TipLibrary.tips(for: .seated) {
            let texte = (conseil.title + " " + conseil.detail).lowercased()
            for mot in interdits {
                XCTAssertFalse(
                    texte.contains(mot),
                    "« \(conseil.id) » demande de \(mot) alors que la famille s'adresse à qui ne se lève pas"
                )
            }
        }
    }

    func testAucunConseilAssisNeDecritUnGesteDeSoin() {
        // L'app ne prescrit rien : suppositoire, stimulation et irrigation ne
        // peuvent apparaître que pour renvoyer vers un professionnel.
        for conseil in TipLibrary.tips(for: .seated) where conseil.id != "seated-program" {
            let texte = (conseil.title + " " + conseil.detail).lowercased()
            for mot in ["suppositoire", "stimulation", "irrigation", "lavement"] {
                XCTAssertFalse(texte.contains(mot), "« \(conseil.id) » décrit un geste de soin")
            }
        }
        let renvoi = TipLibrary.tips(for: .seated).first { $0.id == "seated-program" }
        XCTAssertNotNil(renvoi, "le renvoi vers l'équipe soignante doit exister")
        XCTAssertTrue(
            renvoi?.detail.lowercased().contains("professionnel") == true,
            "ce conseil doit renvoyer explicitement vers un professionnel"
        )
    }

    func testLaDysreflexieAutonomeFigureEnPremierSignalDAlerte() {
        // Une urgence vitale, déclenchée entre autres par un intestin plein :
        // elle ne se règle pas avec des conseils d'hygiène de vie, et doit
        // rester en tête de liste.
        let premier = TipLibrary.redFlags.first?.lowercased() ?? ""
        XCTAssertTrue(premier.contains("dysréflexie"), "signal absent ou déplacé : \(premier)")
        XCTAssertTrue(premier.contains("urgence"), "le caractère d'urgence doit être dit")
        XCTAssertTrue(premier.contains("secours"), "la conduite à tenir doit être dite")
    }

    func testLaPeauFigureParmiLesSignauxDAlerte() {
        let peau = TipLibrary.redFlags.contains { $0.lowercased().contains("rougeur") }
        XCTAssertTrue(peau, "le risque d'escarre doit figurer parmi les signaux")
    }
}
