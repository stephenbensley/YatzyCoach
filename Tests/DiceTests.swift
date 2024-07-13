//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import Foundation

import XCTest
@testable import Solver

class DiceTests: TestCaseWithDice {
    func testOrdinal() throws {
        for count in 0...Dice.maxCount {
            var seen = Set<Int>()
            var duplicates = 0
            var maxOrdinal = 0
            let combos = Self.store.all(withCount: count)
            combos.forEach {
                let ordinal = $0.ordinal
                if seen.contains(ordinal) {
                    duplicates += 1
                }
                maxOrdinal = max(maxOrdinal, ordinal)
                seen.insert(ordinal)
            }
            XCTAssert(duplicates == 0)
            XCTAssert(maxOrdinal == Dice.numCombinations[count] - 1)
        }
    }
    
    func testPattern() throws {
        XCTAssert(dice10(45623).pattern == .none)
        XCTAssert(dice10(22315).pattern == .pair)
        XCTAssert(dice10(15315).pattern == .twoPair)
        XCTAssert(dice10(24464).pattern == .threeOfAKind)
        XCTAssert(dice10(15115).pattern == .fullHouse)
        XCTAssert(dice10(13333).pattern == .fourOfAKind)
        XCTAssert(dice10(22222).pattern == .fiveOfAKind)
    }
    
    func testProbability() throws {
        for count in 0...Dice.maxCount {
            let combos = Self.store.all(withCount: count)
            let total = combos.reduce(0.0, { $0 + $1.probability })
            XCTAssertEqual(total, 1.0, accuracy: 0.000001)
        }
    }
    
    func testBasePoints() throws {
        XCTAssert(dice10(33345).basePoints(scoredAs: .threes) == 9)
        XCTAssert(dice10(33346).basePoints(scoredAs: .threeOfAKind) == 19)
        XCTAssert(dice10(33366).basePoints(scoredAs: .threeOfAKind) == 21)
        XCTAssert(dice10(33366).basePoints(scoredAs: .fullHouse) == Points.fullHouse)
        XCTAssert(dice10(34456).basePoints(scoredAs: .smStraight) == Points.smStraight)
        XCTAssert(dice10(23456).basePoints(scoredAs: .lgStraight) == Points.lgStraight)
        XCTAssert(dice10(33333).basePoints(scoredAs: .yahtzee) == Points.yahtzee)
        XCTAssert(dice10(33366).basePoints(scoredAs: .chance) == 21)
    }
    
    func testKeepOptions() throws {
        var extra = 0
        var missing = 0
        let combos = Self.store.all(withCount: Dice.maxCount)
        combos.forEach { dice in
            let actions = dice.keepOptions
            var seen = Set<Int>()
            // Ensure they're necessary.
            actions.forEach { action in
                let key = Dice.computeKey(for: action.apply(to: dice.value))
                if seen.contains(key) {
                    extra += 1
                }
                seen.insert(key)
            }
            // Ensure they're sufficient.
            DiceSelection.all.forEach { action in
                if !actions.contains(action) {
                    let key = Dice.computeKey(for: action.apply(to: dice.value))
                    if !seen.contains(key) {
                        missing += 1
                    }
                }
            }
        }
        
        XCTAssert(extra == 0)
        XCTAssert(missing == 0)
    }
    
    func testConcatenate() throws {
        let result = Self.store.concatenate(dice10(12), dice10(345))
        XCTAssert(result == dice10(12345))
    }
}
