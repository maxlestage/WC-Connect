import XCTest
// Les sources partagées sont compilées directement dans la cible de test :
// les tests ne dépendent ni de l'app ni d'un simulateur hôte.

final class BreathingPatternTests: XCTestCase {

    private let pattern = BreathingPattern(
        id: "test",
        title: "Test",
        subtitle: "",
        steps: [BreathingStep(.inhale, 4), BreathingStep(.exhale, 6)],
        cycles: 3
    )

    func testCycleAndTotalDuration() {
        XCTAssertEqual(pattern.cycleDuration, 10)
        XCTAssertEqual(pattern.totalDuration, 30)
    }

    func testPhaseAtStartOfCycle() {
        let state = pattern.state(at: 0)
        XCTAssertEqual(state.phase, .inhale)
        XCTAssertEqual(state.cycle, 1)
        XCTAssertEqual(state.phaseProgress, 0)
        XCTAssertFalse(state.isFinished)
    }

    func testPhaseBoundaryBelongsToNextStep() {
        XCTAssertEqual(pattern.state(at: 3.99).phase, .inhale)
        XCTAssertEqual(pattern.state(at: 4).phase, .exhale)
        XCTAssertEqual(pattern.state(at: 4).phaseElapsed, 0)
    }

    func testSecondCycleRestartsOnInhale() {
        let state = pattern.state(at: 10)
        XCTAssertEqual(state.phase, .inhale)
        XCTAssertEqual(state.cycle, 2)
    }

    func testLastCycleIsReported() {
        XCTAssertEqual(pattern.state(at: 25).cycle, 3)
        XCTAssertEqual(pattern.state(at: 25).phase, .exhale)
    }

    func testFinishesAtTotalDuration() {
        XCTAssertTrue(pattern.state(at: 30).isFinished)
        XCTAssertTrue(pattern.state(at: 120).isFinished)
        XCTAssertEqual(pattern.state(at: 30).cycle, 3)
    }

    func testNegativeElapsedIsClamped() {
        let state = pattern.state(at: -5)
        XCTAssertEqual(state.phase, .inhale)
        XCTAssertEqual(state.phaseElapsed, 0)
    }

    func testScaleGrowsOnInhaleAndShrinksOnExhale() {
        XCTAssertLessThan(pattern.state(at: 0).scale, pattern.state(at: 3).scale)
        XCTAssertGreaterThan(pattern.state(at: 4.5).scale, pattern.state(at: 9).scale)
    }

    func testHoldKeepsTheCircleOpen() {
        let square = BreathingPattern.square
        let hold = square.state(at: 5)
        XCTAssertEqual(hold.phase, .hold)
        XCTAssertEqual(hold.scale, 1, accuracy: 0.001)
    }

    func testRhythmLabelIgnoresRest() {
        XCTAssertEqual(BreathingPattern.belly.rhythm, "4-6")
        XCTAssertEqual(BreathingPattern.relax.rhythm, "4-7-8")
        XCTAssertEqual(BreathingPattern.square.rhythm, "4-4-4")
    }

    func testBellyPatternHasNoBreathHold() {
        // Retenir son souffle revient à pousser : le rythme proposé pendant une
        // visite ne doit comporter aucune apnée.
        XCTAssertFalse(BreathingPattern.belly.steps.contains { $0.phase == .hold })
    }

    func testStepDurationIsNeverZero() {
        XCTAssertEqual(BreathingStep(.inhale, 0).duration, 0.5)
    }

    func testCyclesAreAtLeastOne() {
        let degenerate = BreathingPattern(id: "x", title: "", subtitle: "", steps: [BreathingStep(.inhale, 1)], cycles: 0)
        XCTAssertEqual(degenerate.cycles, 1)
    }
}
