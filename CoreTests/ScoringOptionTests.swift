//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YatzyCoach/blob/main/LICENSE.
//

import Foundation
import XCTest

class ScoringOptionTests: XCTestCase {
    func testIsUpper() throws {
        XCTAssert(ScoringOption.sixes.isUpper)
        XCTAssert(!ScoringOption.threeOfAKind.isUpper)
    }
    
    func testSet() throws {
        var options = ScoringOptions()
        for opt in ScoringOption.allCases {
            XCTAssert(!options.isSet(opt))
            options.set(opt)
            XCTAssert(options.isSet(opt))
        }
    }
    
    func testUpper() throws {
        var all = ScoringOptions()
        all.setAll()
        let upperOnly = all.upper
        for opt in ScoringOption.allCases {
            if opt.isUpper {
                XCTAssert(upperOnly.isSet(opt))
            } else {
                XCTAssert(!upperOnly.isSet(opt))
            }
        }
    }
    
    func testAll() throws {
        let n = ScoringOption.allCases.count
        for turn in 0...n {
            let all = ScoringOptions.all(forTurn: turn)
            XCTAssert(all.count == Self.C(n, turn))
        }
    }
    
    static func C(_ n: Int, _ r: Int) -> Int {
        return factorial(n)/(factorial(n - r) * factorial(r))
    }
    
    static func factorial(_ n: Int) -> Int {
        guard n > 0 else {
            return 1
        }
        return n * factorial(n - 1)
    }
}
