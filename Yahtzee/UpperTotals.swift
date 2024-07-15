//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import Foundation

// Computes all upper totals that can results from a given set of ScoringOptions
class UpperTotals {
    private let totals: [[Int]]
    
    func allPossible(for options: ScoringOptions) -> [Int] {
        totals[options.upper.flags]
    }
    
    init() {
        // Six upper options so 2^6 possibilities.
        let allUpper = (0..<64).map { ScoringOptions(flags: $0) }
        totals = allUpper.map { Self.computeUpperTotals(for: $0) }
    }
    
    static func computeUpperTotals(for options: ScoringOptions) -> [Int] {
        // Track which point totals we've seen. We don't care about totals greater than that
        // required to earn the upper bonus.
        var seen = [Bool](repeating: false, count: Points.toEarnUpperBonus + 1)
        
        // Recursively add all combinations. We recurse backwards from maxDieValue because starting
        // with the large values increases our chance of terminating early when we exceed the upper
        // bonus threshold.
        addPossiblePoints(for: options, dieValue: Dice.maxDieValue, subTotal: 0, seen: &seen)
        
        // Turn the array of flags into an array of ints.
        var result = [Int]()
        for i in 0..<seen.count {
            if (seen[i]) {
                result.append(i)
            }
        }
        return result
    }
    
    static func addPossiblePoints(
        for options: ScoringOptions,
        dieValue: Int,
        subTotal: Int,
        seen: inout [Bool]
    ) {
        // If we've processed all valid die values, we terminate the recursion.
        guard (dieValue >= Dice.minDieValue) else {
            seen[subTotal] = true
            return
        }
        
        // Always add points for the case where zero points were scored for the current dieValue
        // because this case applies regardless of whether the scoring option has been used.
        addPossiblePoints(
            for: options,
            dieValue: dieValue - 1,
            subTotal: subTotal,
            seen: &seen
        )
        
        // If this scoring option isn't in use, zero points was the only possibility.
        guard options.isSet(dieValue: dieValue) else {
            return
        }
                
        // This option is set, so add all possible totals for the current dieValue.
        var newSubTotal = subTotal
        for _ in 1...Dice.maxCount {
            newSubTotal += dieValue
            // If we've exceeded the threshold, there's no point continuing since subTotal will
            // only increase from here.
            if newSubTotal >= Points.toEarnUpperBonus {
                seen[Points.toEarnUpperBonus] = true
                break
            }
            // Now recurse through smaller die values.
            addPossiblePoints(
                for: options,
                dieValue: (dieValue - 1),
                subTotal: newSubTotal,
                seen: &seen
            )
        }
    }
 }
