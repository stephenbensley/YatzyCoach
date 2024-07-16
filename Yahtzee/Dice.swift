//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import Foundation

// Represents a roll of the dice. The Dice objects are read-only and shared. Dice can not be
// created directly; they must be retrieved from the DiceStore.
final class Dice: Equatable {
    static let minDieValue = 1
    static let maxDieValue = 6
    static let numDieValues = 6
    static let maxCount = 5
    static let extraRolls = 2
    
    // Combinations with repetition: C(n+r-1, r) where n is dice count and r is numDieValues
    static let numCombinations = [ 1, 6, 21,  56,  126,  252 ]
    // Permutations with repetition: n^r
    static let numPermutations = [ 1, 6, 36, 216, 1296, 7776 ]
    // Permutation of pattern: n!/(s1! * s2! * ... * sn!) where sn is number of dice with value n
    static let numPermutationsByPattern = [
        [   1,  0,  0,  0,  0,  0,  0 ],
        [   1,  0,  0,  0,  0,  0,  0 ],
        [   2,  1,  0,  0,  0,  0,  0 ],
        [   6,  3,  0,  1,  0,  0,  0 ],
        [  24, 12,  6,  4,  0,  1,  0 ],
        [ 120, 60, 30, 20, 10,  5,  1 ]
    ]
    
    // Values of the individual dice in canonical order.
    let value: [Int]
    // An ordinal that uniquely identifies this dice combo. All permutations of a given combo will
    // have the same ordinal. Ordinals are dense and thus can be used as array indices.
    let ordinal: Int
    // Pattern formed by the dice
    let pattern: DicePattern
    // Probability of rolling this dice combo.
    let probability: Double
    // Dice that result from applying the various keepOptions
    let keepResults: [Dice]
    // Cached results of Points.computeBase
    private let basePoints: [Int]
    
    // Number of dice
    var count: Int { value.count }
    
    // Different options the player has for keeping some of the dice when rerolling.
    var keepOptions: [DiceSelection] { DiceSelection.distinct(for: pattern) }
    
    // A key that uniquely identifies this dice combo. Differs from ordinal in that it can be
    // determined solely from Dice.value, and it has the nice property that adding two keys
    // generates the key of the concatenated values.
    var key: Int { Self.computeKey(for: value) }
    
    // Points scored without regard to game state, i.e., no bonuses, wildcards.
    func basePoints(scoredAs opt: ScoringOption) -> Int { self.basePoints[opt.rawValue] }
    
    // This is fileprivate since only DiceStore creates new Dice.
    // byKey is used to resolve keys to the corresponding Dice object.
    fileprivate init(value: [Int], ordinal: Int, byKey: (Int) -> Dice) {
        self.ordinal = ordinal
        
        // Count the number of times each die value appears. We include an extra dummy element, so
        // that every run will be zero terminated -- it makes the run determination a bit
        // simpler.
        var counts = (Self.minDieValue...Self.maxDieValue + 1).map { (count: 0, value: $0) }
        value.forEach { counts[$0 - 1].count += 1 }
        
        // Find the longest run of consecutive values.
        var longestRun = 0
        var runLength = 0
        counts.forEach {
            if $0.count > 0 {
                runLength += 1
            } else {
                longestRun = max(longestRun, runLength)
                runLength = 0
            }
        }
        
        // Sort in descending order, first by count, then by value. This is our canonical order.
        counts.sort(by: >)
        
        // Fill in the canonical dice values.
        var canonical = [Int]()
        counts.forEach { canonical += repeatElement($0.value, count: $0.count) }
        self.value = canonical
        
        // Determine the pattern type based on the counts.
        var pattern: DicePattern
        switch counts[0].count {
        case 2:
            if counts[1].count == 2 {
                pattern = .twoPair
            } else {
                pattern = .pair
            }
        case 3:
            if counts[1].count == 2 {
                pattern = .fullHouse
            } else {
                pattern = .threeOfAKind
            }
        case 4:
            pattern = .fourOfAKind
        case 5:
            pattern = .fiveOfAKind
        default:
            pattern = .none
        }
        self.pattern = pattern
        
        // Compute the probability of rolling this combo out of all possible permutations.
        let numerator = Self.numPermutationsByPattern[value.count][pattern.rawValue]
        let denominator = Self.numPermutations[value.count]
        self.probability = Double(numerator) / Double(denominator)
        
        // Remaining properties only makes sense when all five dice are present.
        guard value.count == Self.maxCount else {
            self.keepResults = [Dice]()
            self.basePoints = [Int]()
            return
        }
        
        // Cache the results of the keepOptions.
        self.keepResults = DiceSelection.distinct(for: pattern).map {
            byKey(Self.computeKey(for: $0.apply(to: canonical)))
        }
        
        // Compute base points for each scoring option.
        self.basePoints = ScoringOption.allCases.map {
            Points.computeBase(
                for: value,
                scoredAs: $0,
                pattern: pattern,
                longestRun: longestRun
            )
        }
    }
    
    static func computeKey(for value: [Int]) -> Int {
        value.reduce(0) { $0 + numPermutations[$1 - 1] }
    }
    
    static func ==(_ lhs: Dice, _ rhs: Dice) -> Bool {
        lhs.count == rhs.count && lhs.ordinal == rhs.ordinal
    }
}

final class DiceStore {
    private var byCount = [[Dice]](repeating: [Dice](), count: Dice.maxCount + 1)
    private var byKey = [Int: Dice]()
    private var add14 = [[Dice]]()
    private var add23 = [[Dice]]()
    
    func concatenate(_ lhs: Dice, _ rhs: Dice) -> Dice {
        // Concatenation is only supported if the result has count == Dice.maxCount. There are no
        // use cases for other counts.
        assert(lhs.count + rhs.count == Dice.maxCount)
        
        switch lhs.count {
        case 0:
            return rhs
        case 1:
            return add14[lhs.ordinal][rhs.ordinal]
        case 2:
            return add23[lhs.ordinal][rhs.ordinal]
        case 3:
            return add23[rhs.ordinal][lhs.ordinal]
        case 4:
            return add14[rhs.ordinal][lhs.ordinal]
        case 5:
            return lhs
        default:
            assert(false)
            return lhs
        }
    }
    
    // Various functions to retrieve cached Dice objects
    func all(withCount count: Int) -> [Dice] { byCount[count] }
    func find(byKey key: Int) -> Dice { byKey[key]! }
    func find(byValue value: [Int]) -> Dice { find(byKey: Dice.computeKey(for: value)) }
    
    static func generateCombos(withCount count: Int) -> [[Int]] {
        var combos = [[Int]]()
        // Build the first combo: all 1s
        var combo = [Int](repeating: 1, count: count)
        
        repeat {
            // Save the latest combo
            combos.append(combo)
            // Find the first die value that is less than its max value.
            guard let idx = combo.firstIndex(where: { $0 < Dice.maxDieValue }) else {
                // If every die is at its max value, we're done.
                break
            }
            // Increment this die's value and set all the previous values to the same value.
            let newValue = combo[idx] + 1
            (0...idx).forEach { combo[$0] = newValue }
         } while true
        
        assert(combos.count == Dice.numCombinations[count])
        return combos
    }
    
    init() {
        for count in 0...Dice.maxCount {
            let combos = Self.generateCombos(withCount: count)
            combos.forEach {
                let ordinal = byCount[count].count
                let dice = Dice(value: $0, ordinal: ordinal, byKey: find)
                byCount[count].append(dice)
                byKey[dice.key] = dice
            }
        }
        
        add14 = byCount[1].map { dice1 in
            byCount[4].map { dice4 in
                find(byKey: dice1.key + dice4.key)
            }
        }
        
        add23 = byCount[2].map { dice2 in
            byCount[3].map { dice3 in
                find(byKey: dice2.key + dice3.key)
            }
        }
    }
}
