import XCTest
// Répartition des rappels d'hydratation.

final class HydrationScheduleTests: XCTestCase {

    func testQuatreRappelsEntre9hEt20h() {
        let heures = HydrationSchedule.hours(count: 4, startHour: 9, endHour: 20)
        XCTAssertEqual(heures, [9, 13, 16, 20])
    }

    func testPremiereEtDerniereHeureRespectees() {
        for nombre in HydrationSchedule.countRange {
            let heures = HydrationSchedule.hours(count: nombre, startHour: 8, endHour: 21)
            XCTAssertEqual(heures.first, 8, "nombre \(nombre)")
            XCTAssertEqual(heures.last, 21, "nombre \(nombre)")
            XCTAssertEqual(heures.count, nombre, "nombre \(nombre)")
        }
    }

    func testHeuresToujoursCroissantesEtSansDoublon() {
        for nombre in 0...12 {
            for debut in 0...23 {
                for fin in 0...23 {
                    let heures = HydrationSchedule.hours(count: nombre, startHour: debut, endHour: fin)
                    XCTAssertEqual(heures, heures.sorted(), "\(nombre) \(debut)-\(fin)")
                    XCTAssertEqual(Set(heures).count, heures.count, "doublon : \(nombre) \(debut)-\(fin)")
                    XCTAssertFalse(heures.isEmpty, "\(nombre) \(debut)-\(fin)")
                    for heure in heures {
                        XCTAssertTrue(HydrationSchedule.hourRange.contains(heure), "\(heure)")
                    }
                }
            }
        }
    }

    func testNombreBorneEntreDeuxEtHuit() {
        XCTAssertEqual(HydrationSchedule.hours(count: 0, startHour: 9, endHour: 20).count, 2)
        XCTAssertEqual(HydrationSchedule.hours(count: 1, startHour: 9, endHour: 20).count, 2)
        XCTAssertEqual(HydrationSchedule.hours(count: 99, startHour: 9, endHour: 20).count, 8)
    }

    func testPlageEtroiteNeProgrammePasDeuxFoisLaMemeHeure() {
        // Deux heures disponibles, six rappels demandés : on en garde deux.
        XCTAssertEqual(HydrationSchedule.hours(count: 6, startHour: 22, endHour: 23), [22, 23])
    }

    func testFinAvantDebutEstCorrigee() {
        let heures = HydrationSchedule.hours(count: 3, startHour: 20, endHour: 8)
        XCTAssertEqual(heures.first, 20)
        XCTAssertTrue(heures.allSatisfy { $0 >= 20 })
    }

    func testHeuresHorsBornesRameneesDansLaJournee() {
        let heures = HydrationSchedule.hours(count: 3, startHour: -5, endHour: 99)
        XCTAssertEqual(heures.first, 0)
        XCTAssertEqual(heures.last, 23)
    }
}
