//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YatzyCoach/blob/main/LICENSE.
//

import Foundation
import UtiliKit

// Different options for scoring in Yatzy
enum ScoringOption: Int, CaseIterable, Codable {
    case ones
    case twos
    case threes
    case fours
    case fives
    case sixes
    case threeOfAKind
    case fourOfAKind
    case fullHouse
    case smStraight
    case lgStraight
    case Yatzy
    case chance
    
    // Is this option scored in the upper part of the scorecard?
    var isUpper: Bool { self.rawValue <= Self.sixes.rawValue }
    
    // Maps a die value to the corresponding upper scoring option.
    static func fromDieValue(_ dieValue: Int) -> ScoringOption {
        ScoringOption(rawValue: dieValue - 1)!
    }
}

// Set of ScoringOptions -- useful for tracing which options have already been used.
struct ScoringOptions: Codable {
    private(set) var flags: Int = 0
    
    var allSet: Bool { flags == 0x1fff }
    var anySet: Bool { flags != 0}
    
    // Returns just the lower or upper options.
    var lower: ScoringOptions { ScoringOptions(flags: flags & 0x1fc0) }
    var upper: ScoringOptions { ScoringOptions(flags: flags & 0x003f) }
    
    mutating func clear(_ opt: ScoringOption) { flags &= ~Self.flag(opt) }
    
    func isSet(_ opt: ScoringOption) -> Bool { flags & Self.flag(opt) != 0 }
    // Checks if the upper option corresponding to a particular die value is set.
    func isSet(dieValue: Int) -> Bool { isSet(ScoringOption.fromDieValue(dieValue)) }
    
    mutating func set(_ opt: ScoringOption) { flags |= Self.flag(opt) }
    mutating func setAll() { flags = 0x1fff }
    
    static func all(forTurn turn: Int) -> [ScoringOptions] {
        // Every turn an option must be used.
        BitPermutations.all(
            bitCount: ScoringOption.allCases.count,
            nonZeroCount: turn
        ).map {
            ScoringOptions(flags: $0)
        }
    }

    static func flag(_ opt: ScoringOption) -> Int { 1 << opt.rawValue }
}
