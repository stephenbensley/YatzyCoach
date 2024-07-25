//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import Foundation

// Derived scores that are reported on the scorecard. These are in addition to the ScoringOptions.
enum DerivedScore: Int, CaseIterable {
    case upperTotalBeforeBonus
    case upperBonus
    case upperTotal
    case lowerTotal
    case grandTotal
}

// Models a game of Yahtzee and provides coaching to the player.
@Observable
final class GameModel {
    // Precomputed solution for the game of Yahtzee.
    private let turnValues: TurnValues
    // DiceStore used for manipulating and evaluating dice rolls.
    private let diceStore: DiceStore
    // Points scored for each ScoringOption
    private var optionPoints: [Int?]
    // Points for each each DerivedScore case
    private var derivedPoints: [Int?]
    // State of the current turn
    private var turnState = TurnState()
    // Analyzer used to coach the player
    private var turnAnalyzer: TurnAnalyzer
    // Number of rolls left this turn.
    private(set) var rollsLeft: Int
    // Dice values as displayed to the player, i.e., not in canonical order.
    private(set) var playerDice: [Int]
    // The number of times each die has been rolled. Useful for triggering animations.
    private(set) var rollCount: [Int]
    // Canonical represetation of the dice
    private(set) var canonicalDice: Dice
    // Analysis of the current roll state
    private(set) var analysis: [ActionValue]
    
    var gameOver: Bool { turnState.used.allSet }
    
    // Return true if the player has earned or could still earn the upper bonus.
    var upperBonusPossible: Bool {
        var upper = derivedPoints(.upperTotalBeforeBonus) ?? 0
        
        // If we've already earned the bonus, there's nothing more to do.
        guard upper < Points.toEarnUpperBonus else {
            return true
        }
        
        // Stride backwards to improve chances of early termination.
        for i in stride(
            from: Dice.maxDieValue,
            through: Dice.minDieValue,
            by: -1
        ) where !turnState.used.isSet(dieValue: i) {
            upper += i * Dice.maxCount
            if upper >= Points.toEarnUpperBonus {
                // It's still in play.
                return true
            }
        }
        // Upper bonus is impossible
        return false
    }
    
    // Various boxes on the scorecard -- these return nil if the box should be blank.
    func optionPoints(_ option: ScoringOption) -> Int? { optionPoints[option.rawValue] }
    func derivedPoints(_ type: DerivedScore) -> Int? { derivedPoints[type.rawValue] }
    
    // Returns the best action the player can take.
    var bestAction: Action {
        analysis[0].action.uncanonize(from: canonicalDice, to: playerDice)
    }
    
    // Returns the value of a proposed action. Value is given relative to the value of the
    // best action, so highest value is 0.0.
    func actionValue(action: Action) -> Double {
        let canonicalAction = action.canonize(from: playerDice, to: canonicalDice)
        // There is guaranteed to be a match since analysis is exhaustive
        let match = analysis.first(where: { $0.action == canonicalAction })!
        return match.value - analysis[0].value
    }
    
    // Determines how many points will be scored by the current option
    func computePoints(option: ScoringOption) -> Points.ByType {
        return Points.computeByType(state: turnState, dice: canonicalDice, option: option)
    }

    // Updates the game state based on the player taking the specified action.
    func takeAction(action: Action) {
        assert(!gameOver)
        
        switch action {
        case .scoreDice(let option):
            assert(!turnState.used.isSet(option))
            
            // Compute points scored and update scorecard
            let points = computePoints(option: option)
            updateScoreCard(option: option, points: points)
            
            // Advance to the next turnState
            turnState = turnState.next(scoringAs: option, points: points.total)
            turnAnalyzer = TurnAnalyzer(
                diceStore: diceStore,
                turnValues: turnValues,
                turnState: turnState
            )
            rollsLeft = Dice.extraRolls
            
            // Roll the dice for the next turn if necessary
            if !gameOver { rollDice() }
            
        case .rollDice(let selection):
            assert(rollsLeft > 0)
            rollsLeft -= 1
            rollDice(keep: selection)
        }
    }
    
    func newGame() {
        optionPoints = [Int?](repeating: nil, count: ScoringOption.allCases.count)
        derivedPoints = [Int?](repeating: nil, count: DerivedScore.allCases.count)
        turnState = TurnState()
        turnAnalyzer = TurnAnalyzer(
            diceStore: diceStore,
            turnValues: turnValues,
            turnState: turnState
        )
        rollsLeft = Dice.extraRolls
        rollDice()
    }
    
    // Subset of the object's state that needs to be persisted.
    struct CodableState: Codable {
        let optionPoints: [Int?]
        let derivedPoints: [Int?]
        let turnState: TurnState
        let rollsLeft: Int
        let playerDice: [Int]
    }
    
    func encode() -> Data {
        let state = CodableState(
            optionPoints: optionPoints,
            derivedPoints: derivedPoints,
            turnState: turnState,
            rollsLeft: rollsLeft,
            playerDice: playerDice
        )
        return try! JSONEncoder().encode(state)
    }
    
    private func rollDice(keep: DiceSelection = DiceSelection()) {
        playerDice.indices.filter({ !keep.isSet($0) }).forEach {
            playerDice[$0] = Self.rollDie()
            rollCount[$0] += 1
        }
        canonicalDice = diceStore.find(byValue: playerDice)
        analysis = turnAnalyzer.analyze(dice: canonicalDice, rollsLeft: rollsLeft)
    }
    
    private func setOptionPoints(_ option: ScoringOption, _ points: Int) {
        optionPoints[option.rawValue] = points
    }
    
    private func setDerivedPoints(_ type: DerivedScore, _ points: Int) {
        derivedPoints[type.rawValue] = points
    }
    
    private func updateScoreCard(option: ScoringOption, points: Points.ByType) {
        setOptionPoints(option, points.forOption)
        if (points.upperBonus > 0) {
            setDerivedPoints(.upperBonus, points.upperBonus)
        }
        if points.yahtzeeBonus > 0 {
            // If we earned the bonus, yahtzee can't be nil
            optionPoints[ScoringOption.yahtzee.rawValue]! += points.yahtzeeBonus
        }
        
        if option.isUpper {
            let upperRange = (0..<Dice.numDieValues)
            setDerivedPoints(
                .upperTotalBeforeBonus,
                optionPoints[upperRange].compactMap({ $0 }).reduce(0, +)
            )
            
            // If upperBonus is still nil, see if we have a chance of earning it.
            if derivedPoints(.upperBonus) == nil && !upperBonusPossible {
                setDerivedPoints(.upperBonus, 0)
            }
            
            // upperTotalBeforeBonus must be non-nil since we just scored an upper option
            setDerivedPoints(
                .upperTotal,
                Self.addOptionals(
                    derivedPoints(.upperTotalBeforeBonus),
                    derivedPoints(.upperBonus)
                )!
            )
        } else {
            let lowerRange = (Dice.numDieValues..<ScoringOption.allCases.count)
            setDerivedPoints(
                .lowerTotal,
                optionPoints[lowerRange].compactMap({ $0 }).reduce(0, +)
            )
        }
        
        setDerivedPoints(
            .grandTotal,
            Self.addOptionals(
                derivedPoints(.upperTotal),
                derivedPoints(.lowerTotal)
            )!
        )
    }
    
    private init(turnValues: TurnValues, diceStore: DiceStore, state: CodableState) {
        // Construct derived objects
        let turnAnalyzer = TurnAnalyzer(
            diceStore: diceStore,
            turnValues: turnValues,
            turnState: state.turnState
        )
        let canonicalDice = diceStore.find(byValue: state.playerDice)
        
        self.turnValues = turnValues
        self.diceStore = diceStore
        self.optionPoints = state.optionPoints
        self.derivedPoints = state.derivedPoints
        self.turnState = state.turnState
        self.turnAnalyzer = turnAnalyzer
        self.rollsLeft = state.rollsLeft
        self.playerDice = state.playerDice
        self.rollCount = [Int](repeating: 0, count: Dice.maxCount)
        self.canonicalDice = canonicalDice
        self.analysis = turnAnalyzer.analyze(dice: canonicalDice, rollsLeft: state.rollsLeft)
    }
    
    convenience init(turnValues: TurnValues, diceStore: DiceStore) {
        // Initialize a default CodableState
        let state = CodableState(
            optionPoints: [Int?](repeating: nil, count: ScoringOption.allCases.count),
            derivedPoints: [Int?](repeating: nil, count: DerivedScore.allCases.count),
            turnState: TurnState(),
            rollsLeft: Dice.extraRolls,
            playerDice: (0..<Dice.maxCount).map { _ in Self.rollDie() }
        )
        self.init(turnValues: turnValues, diceStore: diceStore, state: state)
    }
    
    convenience init?(turnValues: TurnValues, diceStore: DiceStore, data: Data) {
        guard let state = try? JSONDecoder().decode(CodableState.self, from: data) else {
            return nil
        }
        self.init(turnValues: turnValues, diceStore: diceStore, state: state)
    }
    
    private static func addOptionals(_ lhs: Int?, _ rhs: Int?) -> Int? {
        switch (lhs != nil, rhs != nil) {
        case (false, false):
            return nil
        case (false, true):
            return rhs
        case (true, false):
            return lhs
        case (true, true):
            return lhs! + rhs!
        }
    }
    
    private static func rollDie() -> Int {
        Int.random(in: Dice.minDieValue...Dice.maxDieValue)
    }
}
