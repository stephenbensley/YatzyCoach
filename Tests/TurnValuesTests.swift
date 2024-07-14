//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import Foundation
import XCTest

class TurnValuesTests: XCTestCase {
    func testDecode() throws {
        let data = try? Data(contentsOf: URL(fileURLWithPath: "./yahtzeeSolution.json"))
        XCTAssertNotNil(data)
        try XCTSkipIf(data == nil)
        
        let turnValues = TurnValues.decode(data: data!)
        XCTAssertNotNil(turnValues)
        try XCTSkipIf(turnValues == nil)
        
        let expectedValue = turnValues!.find(turnState: TurnState())
        XCTAssertEqual(expectedValue, 254.59, accuracy: 0.01)
    }
}
