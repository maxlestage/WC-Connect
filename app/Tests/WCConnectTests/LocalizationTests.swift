import XCTest
// Les sources partagées sont compilées directement dans la cible de test :
// les tests ne dépendent ni de l'app ni d'un simulateur hôte.

/// Vérifie les tables de traduction embarquées, puisque rien d'autre ne le
/// fera : une clé oubliée en anglais ne se voit qu'à l'usage.
final class LocalizationTests: XCTestCase {

    private var bundle: Bundle { Bundle(for: LocalizationTests.self) }

    /// Charge une table `.strings` depuis le paquet de test.
    private func table(_ langue: String) throws -> [String: String] {
        guard let url = bundle.url(
            forResource: "Localizable",
            withExtension: "strings",
            subdirectory: "\(langue).lproj"
        ) else {
            throw XCTSkip("table \(langue) absente du paquet de test")
        }
        let contenu = try Data(contentsOf: url)
        let brut = try PropertyListSerialization.propertyList(from: contenu, format: nil)
        guard let table = brut as? [String: String] else {
            XCTFail("table \(langue) illisible")
            return [:]
        }
        return table
    }

    func testLesDeuxLanguesOntLesMemesCles() throws {
        let francais = try table("fr")
        let anglais = try table("en")

        XCTAssertFalse(francais.isEmpty, "la table française ne devrait pas être vide")
        XCTAssertEqual(
            Set(francais.keys).symmetricDifference(Set(anglais.keys)),
            [],
            "clés présentes dans une seule langue"
        )
    }

    func testAucuneTraductionVide() throws {
        for langue in ["fr", "en"] {
            for (cle, valeur) in try table(langue) {
                XCTAssertFalse(
                    valeur.trimmingCharacters(in: .whitespaces).isEmpty,
                    "traduction vide pour « \(cle) » en \(langue)"
                )
            }
        }
    }

    func testLaTableFrancaiseEstIdentite() throws {
        // Le français sert de clé : la valeur doit lui être identique, sinon la
        // chaîne affichée dépendrait de la présence de la table.
        for (cle, valeur) in try table("fr") {
            XCTAssertEqual(valeur, cle, "la table française doit être l'identité")
        }
    }

    func testLesTrousCorrespondentEntreLesLangues() throws {
        let francais = try table("fr")
        let anglais = try table("en")

        for (cle, traduction) in anglais {
            guard let original = francais[cle] else { continue }
            XCTAssertEqual(
                specifiers(in: original),
                specifiers(in: traduction),
                "les trous de « \(cle) » ne correspondent pas : \(traduction)"
            )
        }
    }

    func testQuelquesTraductionsAttendues() throws {
        let anglais = try table("en")
        XCTAssertEqual(anglais["Express"], "Express")
        XCTAssertEqual(anglais["Maison"], "Home")
        XCTAssertEqual(anglais["Tempête"], "Storm")
        XCTAssertEqual(anglais["Terminer"], "Finish")
        XCTAssertEqual(anglais["Éclair"], "Lightning")
    }

    func testToutesLesCategoriesEtHautsFaitsSontTraduits() throws {
        let anglais = try table("en")
        for categorie in TipCategory.allCases {
            XCTAssertNotNil(anglais[categorie.title], "catégorie non traduite : \(categorie.title)")
        }
        for haut in Achievement.allCases {
            XCTAssertNotNil(anglais[haut.title], "haut fait non traduit : \(haut.title)")
            XCTAssertNotNil(anglais[haut.detail], "détail non traduit : \(haut.title)")
        }
        for conseil in TipLibrary.all {
            XCTAssertNotNil(anglais[conseil.title], "conseil non traduit : \(conseil.id)")
            XCTAssertNotNil(anglais[conseil.detail], "détail non traduit : \(conseil.id)")
        }
        for signal in TipLibrary.redFlags {
            XCTAssertNotNil(anglais[signal], "signal d'alerte non traduit : \(signal)")
        }
    }

    /// Suite ordonnée des trous d'une chaîne de format.
    private func specifiers(in texte: String) -> [String] {
        let motif = try? NSRegularExpression(pattern: "%(?:%|@|[0-9.]*l?[dfs@])")
        let plage = NSRange(texte.startIndex..<texte.endIndex, in: texte)
        guard let resultats = motif?.matches(in: texte, range: plage) else { return [] }
        return resultats.compactMap { resultat in
            Range(resultat.range, in: texte).map { String(texte[$0]) }
        }
        .filter { $0 != "%%" }
    }
}
