//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import Foundation
import XCTest

class PointsTests: TestCaseWithDice {
    func testCompute() throws {
        var state = TurnState().next(scoringAs: .aces, points: 4)
        XCTAssert(Points.compute(
            state: state,
            dice: dice10(11133),
            option: .aces
        ) == 0)
        XCTAssert(Points.compute(
            state: state.next(scoringAs: .yahtzee, points: 50),
            dice: dice10(11111),
            option: .lgStraight
        ) == 140)
        XCTAssert(Points.compute(
            state: state.next(scoringAs: .yahtzee, points: 0),
            dice: dice10(11111),
            option: .lgStraight
        ) == 40)
        XCTAssert(Points.compute(
            state: state.next(scoringAs: .yahtzee, points: 0),
            dice: dice10(33333),
            option: .lgStraight
        ) == 0)
        state = state.next(scoringAs: .fours, points: 16)
        state = state.next(scoringAs: .fives, points: 20)
        XCTAssert(Points.compute(
            state: state,
            dice: dice10(66665),
            option: .sixes
        ) == 59)
        state = state.next(scoringAs: .sixes, points: 24)
        XCTAssert(Points.compute(
            state: state,
            dice: dice10(22345),
            option: .twos
        ) == 4)
    }
}
