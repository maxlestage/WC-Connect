import XCTest
// Bilan destiné à une consultation : ce sont les chiffres que le praticien
// demande, et ils doivent être exacts.

final class MedicalReportTests: XCTestCase {

    private var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Europe/Paris") ?? .gmt
        return calendar
    }

    /// 15 mars 2026, 12 h.
    private var maintenant: Date {
        calendar.date(from: DateComponents(year: 2026, month: 3, day: 15, hour: 12)) ?? Date()
    }

    private func visite(
        day: Int,
        month: Int = 3,
        hour: Int = 9,
        minutes: Double = 4,
        bristol: Bristol? = nil,
        effort: Int? = nil,
        symptoms: [Symptom]? = nil,
        terminee: Bool = true
    ) -> ToiletSession {
        let debut = calendar.date(
            from: DateComponents(year: 2026, month: month, day: day, hour: hour)
        ) ?? Date()
        return ToiletSession(
            startedAt: debut,
            endedAt: terminee ? debut.addingTimeInterval(minutes * 60) : nil,
            bristol: bristol,
            effort: effort,
            symptoms: symptoms
        )
    }

    private func bilan(_ sessions: [ToiletSession], days: Int = 7) -> MedicalReport {
        MedicalReportEngine.build(
            sessions: sessions, days: days, now: maintenant, calendar: calendar
        )
    }

    // MARK: - Fenêtre

    func testFenetreCouvreLeNombreDeJoursDemande() {
        let rapport = bilan([], days: 30)
        XCTAssertEqual(rapport.daysCovered, 30)
        let premier = calendar.dateComponents([.month, .day], from: rapport.from)
        // 30 jours dont aujourd'hui : du 14 février au 15 mars.
        XCTAssertEqual(premier.month, 2)
        XCTAssertEqual(premier.day, 14)
    }

    func testVisitesHorsFenetreIgnorees() {
        // Fenêtre de 7 jours : du 9 au 15 mars.
        let rapport = bilan([visite(day: 8), visite(day: 9), visite(day: 15)])
        XCTAssertEqual(rapport.visits, 2)
        XCTAssertEqual(rapport.daysWithVisit, 2)
    }

    func testVisiteEnCoursIgnoree() {
        let rapport = bilan([visite(day: 14), visite(day: 15, terminee: false)])
        XCTAssertEqual(rapport.visits, 1)
    }

    // MARK: - Chiffres

    func testBilanVide() {
        let rapport = bilan([])
        XCTAssertTrue(rapport.isEmpty)
        XCTAssertEqual(rapport.visits, 0)
        XCTAssertEqual(rapport.daysWithVisit, 0)
        XCTAssertEqual(rapport.averageDuration, 0)
        XCTAssertNil(rapport.averageEffort)
        XCTAssertTrue(rapport.byBristol.isEmpty)
        XCTAssertTrue(rapport.bySymptom.isEmpty)
        // Aucune visite sur sept jours : sept jours d'absence.
        XCTAssertEqual(rapport.longestGapDays, 7)
        XCTAssertEqual(rapport.visitsPerWeek, 0)
    }

    func testFrequenceParSemaine() {
        let rapport = bilan([visite(day: 9), visite(day: 12), visite(day: 15)])
        XCTAssertEqual(rapport.visitsPerWeek, 3, accuracy: 0.001)

        let surTrente = bilan([visite(day: 9), visite(day: 12), visite(day: 15)], days: 30)
        XCTAssertEqual(surTrente.visitsPerWeek, 0.7, accuracy: 0.001)
    }

    func testPlusLongueAbsenceEntreDeuxVisites() {
        // Visites les 9, 12 et 15 : les 10 et 11 sont vides, puis les 13 et 14.
        let rapport = bilan([visite(day: 9), visite(day: 12), visite(day: 15)])
        XCTAssertEqual(rapport.longestGapDays, 2)
    }

    func testPlusLongueAbsenceCompteLeTrouAvantLaPremiereVisite() {
        // Une seule visite aujourd'hui : les six jours précédents sont vides.
        let rapport = bilan([visite(day: 15)])
        XCTAssertEqual(rapport.longestGapDays, 6)
    }

    func testPlusLongueAbsenceCompteLeTrouApresLaDerniereVisite() {
        let rapport = bilan([visite(day: 9)])
        XCTAssertEqual(rapport.longestGapDays, 6)
    }

    func testPlusieursVisitesLeMemeJourNeComptentQuUnJour() {
        // Les deux visites sont avant l'heure de référence (midi) : une visite
        // du soir serait dans le futur, et donc écartée.
        let rapport = bilan([visite(day: 15, hour: 8), visite(day: 15, hour: 11)])
        XCTAssertEqual(rapport.visits, 2)
        XCTAssertEqual(rapport.daysWithVisit, 1)
    }

    func testVisiteDansLeFuturIgnoree() {
        // Une visite enregistrée après l'heure de référence ne compte pas :
        // un bilan ne décrit que ce qui a déjà eu lieu.
        let rapport = bilan([visite(day: 15, hour: 8), visite(day: 15, hour: 19)])
        XCTAssertEqual(rapport.visits, 1)
    }

    func testDureeMoyenne() {
        let rapport = bilan([visite(day: 14, minutes: 2), visite(day: 15, minutes: 6)])
        XCTAssertEqual(rapport.averageDuration, 4 * 60, accuracy: 0.5)
    }

    // MARK: - Journal

    func testAgregatsDuJournal() {
        let rapport = bilan([
            visite(day: 13, bristol: .one, effort: 4, symptoms: [.straining]),
            visite(day: 14, bristol: .two, effort: 2, symptoms: [.straining, .blood]),
            visite(day: 15, bristol: .four)
        ])

        XCTAssertEqual(rapport.byBristol[.one], 1)
        XCTAssertEqual(rapport.byBristol[.two], 1)
        XCTAssertEqual(rapport.byBristol[.four], 1)
        XCTAssertEqual(rapport.bySymptom[.straining], 2)
        XCTAssertEqual(rapport.bySymptom[.blood], 1)
        XCTAssertEqual(rapport.averageEffort ?? 0, 3, accuracy: 0.001)

        XCTAssertEqual(rapport.count(of: .constipation), 2)
        XCTAssertEqual(rapport.count(of: .ideal), 1)
        XCTAssertEqual(rapport.count(of: .loose), 0)

        XCTAssertEqual(rapport.notableSymptoms, [.blood])
    }

    func testAucunSymptomeNotableSansSignal() {
        let rapport = bilan([visite(day: 15, symptoms: [.bloating, .cramps])])
        XCTAssertTrue(rapport.notableSymptoms.isEmpty)
    }

    func testFenetreAberranteRameneeAUnJour() {
        let rapport = bilan([visite(day: 15)], days: 0)
        XCTAssertEqual(rapport.daysCovered, 1)
        XCTAssertEqual(rapport.visits, 1)
        XCTAssertEqual(rapport.longestGapDays, 0)
    }
}
