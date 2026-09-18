import XCTest
// Journal des symptômes : échelle de Bristol, symptômes, et compatibilité des
// historiques enregistrés avant l'existence du journal.

final class JournalTests: XCTestCase {

    // MARK: - Échelle de Bristol

    func testBristolCouvreLesSeptTypes() {
        XCTAssertEqual(Bristol.allCases.count, 7)
        XCTAssertEqual(Bristol.allCases.map(\.rawValue), Array(1...7))
    }

    func testBristolTendances() {
        XCTAssertEqual(Bristol.one.tendency, .constipation)
        XCTAssertEqual(Bristol.two.tendency, .constipation)
        XCTAssertEqual(Bristol.three.tendency, .ideal)
        XCTAssertEqual(Bristol.four.tendency, .ideal)
        XCTAssertEqual(Bristol.five.tendency, .ideal)
        XCTAssertEqual(Bristol.six.tendency, .loose)
        XCTAssertEqual(Bristol.seven.tendency, .loose)
    }

    func testBristolNotableHorsDeLaNorme() {
        for type in Bristol.allCases {
            XCTAssertEqual(type.isNotable, type.tendency != .ideal, "type \(type.rawValue)")
        }
    }

    func testBristolTitreContientLeNumero() {
        for type in Bristol.allCases {
            XCTAssertTrue(
                type.title.contains(String(type.rawValue)),
                "le titre du type \(type.rawValue) doit porter son numéro : \(type.title)"
            )
            XCTAssertFalse(type.title.contains("%@"), "format non substitué : \(type.title)")
            XCTAssertFalse(type.detail.isEmpty)
            XCTAssertFalse(type.tendency.title.isEmpty)
        }
    }

    func testBristolCodableParSonNumero() throws {
        let json = try JSONEncoder().encode(Bristol.four)
        XCTAssertEqual(String(data: json, encoding: .utf8), "4")
        XCTAssertEqual(try JSONDecoder().decode(Bristol.self, from: Data("7".utf8)), .seven)
    }

    // MARK: - Symptômes

    func testSeulLeSangJustifieUnAvis() {
        let avis = Symptom.allCases.filter(\.needsAdvice)
        XCTAssertEqual(avis, [.blood])
    }

    func testSymptomesTousNommesEtIllustres() {
        XCTAssertEqual(Symptom.allCases.count, 6)
        for symptome in Symptom.allCases {
            XCTAssertFalse(symptome.title.isEmpty, symptome.rawValue)
            XCTAssertFalse(symptome.symbol.isEmpty, symptome.rawValue)
            XCTAssertEqual(symptome.id, symptome.rawValue)
        }
    }

    func testSymptomesIdentifiantsStablesPourLePersistance() {
        // Ces identifiants sont écrits dans l'historique et dans le CSV :
        // les renommer casserait les journaux déjà enregistrés.
        XCTAssertEqual(
            Symptom.allCases.map(\.rawValue),
            ["bloating", "cramps", "urgency", "incomplete", "straining", "blood"]
        )
    }

    // MARK: - Visite

    func testVisiteSansJournalNeSignaleRien() {
        let visite = ToiletSession()
        XCTAssertTrue(visite.symptomList.isEmpty)
        XCTAssertFalse(visite.needsAdvice)
    }

    func testVisiteAvecSangDemandeUnAvis() {
        let visite = ToiletSession(symptoms: [.bloating, .blood])
        XCTAssertTrue(visite.needsAdvice)
    }

    func testVisiteAvecSymptomesBeninsNeDemandePasDAvis() {
        let visite = ToiletSession(symptoms: [.bloating, .cramps, .urgency, .incomplete, .straining])
        XCTAssertFalse(visite.needsAdvice)
    }

    func testAncienHistoriqueSeDecodeSansLesChampsDuJournal() throws {
        // Un historique enregistré avant le journal : ni bristol, ni effort,
        // ni symptoms. Le décodage doit passer, sinon l'app perd l'historique.
        let json = """
        {
          "id": "6B5F2C1E-0000-4000-8000-000000000001",
          "startedAt": 760000000,
          "endedAt": 760000240,
          "kind": "standard",
          "place": "home",
          "comfort": 4,
          "source": "phone"
        }
        """
        let visite = try JSONDecoder().decode(ToiletSession.self, from: Data(json.utf8))
        XCTAssertEqual(visite.comfort, 4)
        XCTAssertNil(visite.bristol)
        XCTAssertNil(visite.effort)
        XCTAssertNil(visite.symptoms)
        XCTAssertTrue(visite.symptomList.isEmpty)
        XCTAssertFalse(visite.needsAdvice)
        XCTAssertEqual(visite.finalDuration, 240)
    }

    func testJournalSurviteALAllerRetourCodable() throws {
        let visite = ToiletSession(
            startedAt: Date(timeIntervalSince1970: 760_000_000),
            endedAt: Date(timeIntervalSince1970: 760_000_300),
            bristol: .two,
            effort: 4,
            symptoms: [.straining, .incomplete]
        )
        let relu = try JSONDecoder().decode(
            ToiletSession.self, from: JSONEncoder().encode(visite)
        )
        XCTAssertEqual(relu, visite)
        XCTAssertEqual(relu.bristol, .two)
        XCTAssertEqual(relu.symptomList.count, 2)
    }
}
