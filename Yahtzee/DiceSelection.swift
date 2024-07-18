//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import Foundation

// Specifies a proper subset of the current dice, e.g., which dice to keep when rerolling.
struct DiceSelection: Equatable {
    var flags: Int = 0
    
    var count: Int { flags.nonzeroBitCount }
    
    // Returns only the selected values.
    func apply(to value: [Int]) -> [Int] {
        value.indices.filter({ isSet($0) }).map({ value[$0] })
    }
    
    func isSet(_ ordinal: Int) -> Bool { flags & Self.flag(ordinal) != 0 }
    
    mutating func toggle(_ ordinal: Int) { flags ^= Self.flag(ordinal) }
    
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
final class DiceSelectionSets {
    private let distinctSets: [[DiceSelection]]
    
    func distinct(for pattern: DicePattern) -> [DiceSelection] { distinctSets[pattern.rawValue] }
    
    init() {
        distinctSets = DicePattern.allCases.map { pattern in
            let example = pattern.canonicalExample
            var seen = Set<Int>()
            // Search all possible DiceSelections to guarantee the result is sufficient.
            return DiceSelection.all.compactMap { selection in
                let remainder = selection.apply(to: example)
                let key = Dice.computeKey(for: remainder)
                // If this selection produces a remainder that has already been seen, then it's
                // unnecessary and can be ignored.
                guard !seen.contains(key) else { return nil }
                seen.insert(key)
                return selection
            }
        }
    }
}
