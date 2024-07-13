//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import Foundation

// Specifies a proper subset of the current dice, e.g., which dice to keep when rerolling.
struct DiceSelection: Equatable {
    var flags: Int
    
    var count: Int {
        var count = 0
        var v = UInt32(flags)
        while v > 0 {
            // Clear least significant set bit
            v &= v - 1
            // Count set bits until there are none left
            count = count + 1
        }
        return count
    }
    
    func apply(to value: [Int]) -> [Int] {
        var selected = [Int]()
        for i in 0..<value.count {
            if isSet(i) {
                selected.append(value[i])
            }
        }
        return selected
    }
    
    func isSet(_ ordinal: Int) -> Bool {
        flags & Self.flag(ordinal) != 0
    }
    
    // We only select proper subsets (keeping all dice isn't an option in Yahtzee)
    static let all: [DiceSelection] = (0..<31).map { DiceSelection(flags: $0) }
    
    private static let distinctSets = DiceSelectionSets()
    
    // For a given dice pattern, returns a necessary and sufficient set of DiceSelections that
    // will produce all possible results.
    static func distinct(for pattern: DicePattern) -> [DiceSelection] {
        Self.distinctSets.distinct(for: pattern)
    }
    
    static func flag(_ ordinal: Int) -> Int {
        1 << ordinal
    }
}

// For each dice pattern, computes a necessary and sufficient set of DiceSelections that
// will produce all possible results.
class DiceSelectionSets {
    private let distinctSets: [[DiceSelection]]
    
    func distinct(for pattern: DicePattern) -> [DiceSelection] {
        distinctSets[pattern.rawValue]
    }
    
    init() {
        distinctSets = DicePattern.allCases.map { pattern in
            let example = pattern.canonicalExample
            var seen = Set<Int>()
            return DiceSelection.all.compactMap { selection in
                let remainder = selection.apply(to: example)
                let key = Dice.computeKey(for: remainder)
                guard !seen.contains(key) else { return nil }
                seen.insert(key)
                return selection
            }
        }
    }
}
