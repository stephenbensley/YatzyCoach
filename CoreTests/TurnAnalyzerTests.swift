//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YatzyCoach/blob/main/LICENSE.
//

import Foundation
import XCTest

class TurnAnalyzerTests: TestCaseWithDice {
    func testEvaluate() throws {
        let turnValues = TurnValues()
        
        var allButYatzy = ScoringOptions()
        allButYatzy.setAll()
        allButYatzy.clear(.Yatzy)
        
        let lastTurn = TurnState(used: allButYatzy, upperTotal: 0, YatzyScored: false)
        let finalYatzy = lastTurn.next(scoringAs: .Yatzy, points: Points.Yatzy)
        let finalNone = lastTurn.next(scoringAs: .Yatzy, points: 0)
        
        var ta = TurnAnalyzer(
            diceStore: Self.store,
            turnValues: turnValues,
            turnState: finalYatzy
        )
        var value = ta.evaluate()
        XCTAssertEqual(value, 0.0, accuracy: 0.000001)
        turnValues.insert(turnState: finalYatzy, value: value)
        
        ta = TurnAnalyzer(
            diceStore: Self.store,
            turnValues: turnValues,
            turnState: finalNone
        )
        value = ta.evaluate()
        XCTAssertEqual(value, 0.0, accuracy: 0.000001)
        turnValues.insert(turnState: finalNone, value: value)
        
        ta = TurnAnalyzer(
            diceStore: Self.store,
            turnValues: turnValues,
            turnState: lastTurn
        )
        value = ta.evaluate(dice: dice10(11111), rollsLeft: 0)
        XCTAssertEqual(value, 50.0, accuracy: 0.000001)
        value = ta.evaluate(dice: dice10(11111), rollsLeft: 1)
        XCTAssertEqual(value, 50.0, accuracy: 0.000001)
        value = ta.evaluate(dice: dice10(11111), rollsLeft: 2)
        XCTAssertEqual(value, 50.0, accuracy: 0.000001)
        value = ta.evaluate(dice: dice10(11112), rollsLeft: 0)
        XCTAssertEqual(value, 0.0, accuracy: 0.000001)
        value = ta.evaluate(dice: dice10(11112), rollsLeft: 1)
        XCTAssertEqual(value, 50.0 * (1.0 / 6.0), accuracy: 0.000001)
        value = ta.evaluate(dice: dice10(11112), rollsLeft: 2)
        XCTAssertEqual(value, 50.0 * (11.0 / 36.0), accuracy: 0.000001)
        value = ta.evaluate(dice: dice10(11134), rollsLeft: 0)
        XCTAssertEqual(value, 0.0, accuracy: 0.000001)
        value = ta.evaluate(dice: dice10(11134), rollsLeft: 1)
        XCTAssertEqual(value, 50.0 * (1.0 / 36.0), accuracy: 0.000001)
        value = ta.evaluate(dice: dice10(11134), rollsLeft: 2)
        // Probability of getting both on first roll + one on first and one on second + both on
        // second roll
        let prob = (1.0 / 36.0) + (10.0 / 216.0) + (25.0 / 1296.0)
        XCTAssertEqual(value, 50.0 * prob, accuracy: 0.000001)
        value = ta.evaluate()
        // Found the probability of Yatzy here: http://www.datagenetics.com/blog/january42012/
        XCTAssertEqual(value, 50.0 * 0.046029, accuracy: 0.0001)
    }
}
