//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import Foundation

import XCTest
@testable import Solver

// Base class for test cases that use Dice
class TestCaseWithDice: XCTestCase {
    static let store = DiceStore()
    
    // Retrieve a Dice object from the base 10 representation of the dice value,
    // e.g., 33446 == [3, 3, 4, 4, 6]. This is useful for writing test cases.
    func dice10(_ base10: Int) -> Dice {
        var base10 = base10
        var value = [Int]()
        while base10 > 0 {
            value.append(base10 % 10)
            base10 /= 10
        }
        return Self.store.find(byValue: value)
    }


}
