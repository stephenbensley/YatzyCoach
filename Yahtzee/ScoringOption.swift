//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import Foundation

// Different options for scoring in Yahtzee
enum ScoringOption: Int, CaseIterable {
    case aces
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
    case yahtzee
    case chance
    
    // Is this option scored in the upper part of the score card?
    var isUpper: Bool { self.rawValue <= Self.sixes.rawValue }
    
    // Maps a die value to the corresponding upper scoring option.
    static func fromDieValue(_ dieValue: Int) -> ScoringOption {
        ScoringOption(rawValue: dieValue - 1)!
    }
}

// Set of ScoringOptions -- useful for tracing which options have already been used.
struct ScoringOptions {
    var flags: Int = 0
    
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
        var result = [ScoringOptions]()
        
        // Array of Bools indicating which options have been used.
        var selectors = [Bool](repeating: false, count: ScoringOption.allCases.count)
        // Every turn an option must be used.
        selectors.replaceSubrange(0..<turn, with: [Bool](repeating: true, count: turn))
        
        repeat {
            // Convert the selectors to ScoringOptions and add to result
            var options = ScoringOptions()
            ScoringOption.allCases.filter({ selectors[$0.rawValue] }).forEach({ options.set($0) })
            result.append(options)

            // Cycle through the permutations
        } while nextPermutation(&selectors)
        
        return result
    }
    
    static func flag(_ opt: ScoringOption) -> Int { 1 << opt.rawValue }
    
    private static func nextPermutation(_ selectors: inout [Bool]) -> Bool {
        guard selectors.count > 1 else {
            return false
        }
        
        for i in 0..<selectors.count - 1 {
            if selectors[i] && !selectors[i+1] {
                // Guaranteed to succeed since at least selectors[i] is true.
                let j = selectors.firstIndex(of: true)!
                selectors.swapAt(i + 1, j)
                selectors.replaceSubrange(0...i, with: selectors[0...i].reversed())
                return true
            }
        }
        
        return false
    }
}
