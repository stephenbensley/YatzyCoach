//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YatzyCoach/blob/main/LICENSE.
//

import Foundation
import XCTest

class TurnValuesTests: XCTestCase {
    func testDecode() throws {
        guard let turnValues = TurnValues(fileURLWithPath: "./YatzySolution.json") else {
            XCTFail()
            return
        }

        let expectedValue = turnValues.find(turnState: TurnState())
        XCTAssertEqual(expectedValue, 254.59, accuracy: 0.01)
    }
}
