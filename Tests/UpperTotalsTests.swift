//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import Foundation

import XCTest
@testable import Solver

class UpperTotalsTests: XCTestCase {
    func testAllPossible() throws {
        let upperTotals = UpperTotals()
        var options = ScoringOptions()
        options.set(.twos)
        options.set(.fours)
        
        let possible = upperTotals.allPossible(for: options)
        let expected = Array(stride(from: 0 , through: 30, by: 2))
        XCTAssert(possible == expected)
    }
}
