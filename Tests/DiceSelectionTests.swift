//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import Foundation
import XCTest

class DiceSelectionTests: XCTestCase {
    
    func testApply() throws  {
        // Least significant flag applies to first element in value, so the flags and values
        // appear in opposite order below.
        XCTAssert(DiceSelection(flags: 0b00000).apply(to: [4, 4, 3, 2, 1]) == [])
        XCTAssert(DiceSelection(flags: 0b01001).apply(to: [4, 4, 3, 2, 1]) == [4, 2])
        XCTAssert(DiceSelection(flags: 0b10110).apply(to: [4, 4, 3, 2, 1]) == [4, 3, 1])
    }
}
