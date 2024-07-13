//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import Foundation

import XCTest
@testable import Solver

class DiceSelectionTests: XCTestCase {
    
    func testCount() throws {
        XCTAssert(DiceSelection(flags: 0b00000).count == 0)
        XCTAssert(DiceSelection(flags: 0b01000).count == 1)
        XCTAssert(DiceSelection(flags: 0b10010).count == 2)
        XCTAssert(DiceSelection(flags: 0b10101).count == 3)
        XCTAssert(DiceSelection(flags: 0b01111).count == 4)
    }
    
    func testApply() throws  {
        // Least significant flag applies to first element in value, so the flags and values
        // appear in opposite order.
        XCTAssert(DiceSelection(flags: 0b00000).apply(to: [4, 4, 3, 2, 1]) == [])
        XCTAssert(DiceSelection(flags: 0b01001).apply(to: [4, 4, 3, 2, 1]) == [4, 2])
        XCTAssert(DiceSelection(flags: 0b10110).apply(to: [4, 4, 3, 2, 1]) == [4, 3, 1])
    }
    
}
