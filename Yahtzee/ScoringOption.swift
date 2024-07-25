//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import Foundation

// Different options for scoring in Yahtzee
enum ScoringOption: Int, CaseIterable, Codable {
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
        var result = [ScoringOptions]()
        
        // Array of Bools indicating which options have been used.
        var selectors = [Bool](repeating: false, count: ScoringOption.allCases.count)
        // Every turn an option must be used.
        selectors.replaceSubrange(0..<turn, with: [Bool](repeating: true, count: turn))
        
        repeat {
            // Convert the selectors to ScoringOptions and add to result
            var options = ScoringOptions()
            ScoringOption.allCases.filter({ selectors[$0.rawValue] }).forEach { options.set($0) }
            result.append(options)
            
            // Cycle through the permutations
        } while nextPermutation(&selectors)
        
        return result
    }
    
    static func flag(_ opt: ScoringOption) -> Int { 1 << opt.rawValue }
    
    private static func nextPermutation(_ selectors: inout [Bool]) -> Bool {
        // Counts of 0 and 1 only have one permutation, and the loop below can't handle these
        // cases.
        guard selectors.count > 1 else {
            return false
        }
        
        // Find first selector that's set where following selector isn't set.
        for i in 0..<selectors.count - 1 where selectors[i] && !selectors[i+1] {
            // Find first selector that's set. Guaranteed to succeed since count > 0
            let j = selectors.firstIndex(of: true)!
            // Swap these ...
            selectors.swapAt(i + 1, j)
            // ... and reverse all the preceding elements.
            selectors[0...i].reverse()
            return true
        }
        
        // All the true selectors have been pushed to the end of the array, so we're done.
        return false
    }
}
