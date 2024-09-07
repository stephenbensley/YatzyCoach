//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YatzyCoach/blob/main/LICENSE.
//

import Foundation
import XCTest

class TurnStateTests: XCTestCase {
    func testId() throws {
        var seen = Set<Int>()
        var duplicates = 0
        var maxId = 0
        for turn in 0...ScoringOption.allCases.count {
            TurnState.all(forTurn: turn).forEach {
                let id = $0.id
                if seen.contains(id) {
                    duplicates += 1
                }
                maxId = max(maxId, id)
                seen.insert(id)
            }
        }
        XCTAssert(duplicates == 0)
        XCTAssert(maxId == TurnState.maxId)
        // Technically, I don't know if this number is correct, but the test is still useful.
        // It exercises a great deal code and will at least detect unintended changes in behavior.
        XCTAssert(seen.count == TurnState.stateCount)
    }
    
    func testNext() throws {
        var state = TurnState()
        state = state.next(scoringAs: .threes, points: 9)
        XCTAssert(state.upperTotal == 9)
        state = state.next(scoringAs: .threeOfAKind, points: 22)
        XCTAssert(state.upperTotal == 9)
        state = state.next(scoringAs: .fives, points: 20)
        state = state.next(scoringAs: .sixes, points: 24)
        XCTAssert(state.upperTotal == 53)
        state = state.next(scoringAs: .fours, points: 16)
        XCTAssert(state.upperTotal == Points.toEarnUpperBonus)
        XCTAssert(state.next(scoringAs: .Yatzy, points: 50).YatzyScored)
        XCTAssert(!state.next(scoringAs: .Yatzy, points: 0).YatzyScored)
    }
}
