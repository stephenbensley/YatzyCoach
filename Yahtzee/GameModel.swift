//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import Foundation

// Models a game of Yahtzee and provides coaching to the player.
class GameModel: ObservableObject {
    // Precomputed solution for the game of Yahtzee.
    private let turnValues: TurnValues
    // DiceStore used for manipulating and evaluating dice rolls.
    private let diceStore: DiceStore
    // Points scored for each ScoringOption
    private var optionPoints: [Int]
    // State of the current turn
    private var turnState = TurnState()
    // Analyzer used to coach the player
    private var turnAnalyzer: TurnAnalyzer
    // Number of rolls left this turn.
    var rollsLeft: Int
    // Dice values as displayed to the player, i.e., not in canonical order.
    var playerDice: [Int]
    // Canonical represetation of the dice
    private var canonicalDice: Dice
    // Analysis of the current roll state
    private var analysis: [ActionValue]

    var gameOver: Bool { turnState.used.allSet }

    subscript(index: ScoringOption) -> Int? {
        turnState.used.isSet(index) ? optionPoints[index.rawValue] : nil
    }
    var upperTotalBeforeBonus: Int? {
        let upperRange = (0..<Dice.numDieValues)
        return turnState.used.upper.anySet ? optionPoints[upperRange].reduce(0, +) : nil
    }
    var upperBonus: Int? {
        var upper = upperTotalBeforeBonus ?? 0
        // If we've already earned the bonus, return it
        if upper >= Points.toEarnUpperBonus {
            return Points.upperBonus
        }
        // Do we still have a chance of earning it? Stride backwards to improve chances of
        // early termination.
        for i in stride(from: Dice.maxDieValue, through: Dice.minDieValue, by: -1) {
            if (!turnState.used.isSet(dieValue: i)) {
                upper += i * Dice.maxCount
                if upper >= Points.toEarnUpperBonus {
                    // It's still in play, so leave it blank for now.
                    return nil
                }
            }
        }
        // Upper bonus is impossible, so return 0
        return 0
    }
    var upperTotal: Int? {
        Self.addOptionals(upperTotalBeforeBonus, upperBonus)
    }
    var lowerTotal: Int? {
        let lowerRange = (Dice.numDieValues..<ScoringOption.allCases.count)
        return turnState.used.lower.anySet ? optionPoints[lowerRange].reduce(0, +) : nil
    }
    var grandTotal: Int? {
        Self.addOptionals(upperTotal, lowerTotal)
    }
    
    // Returns the best action the player could take.
    var bestAction: Action {
        analysis[0].action.uncanonize(from: canonicalDice, to: playerDice)
    }
    
    // Returns the value of a proposed action. Value is given relative to the value of the
    // best action, so highest value is 0.0.
    func actionValue(action: Action) -> Double {
        let canonicalAction = action.canonize(from: playerDice, to: canonicalDice)
        let match = analysis.first(where: { $0.action == canonicalAction })!
        return match.value - analysis[0].value
    }
    
    // Updates the game state based on the player taking the specified action.
    func takeAction(action: Action) {
        assert(!gameOver)
        
        // This is the only method that triggers changes to the object. All others are read-only.
        objectWillChange.send()
        
        switch action {
        case .scoreDice(let option):
            assert(!turnState.used.isSet(option))
            
            // Compute points scored.
            let points = Points.computeByType(
                state: turnState,
                dice: canonicalDice,
                option: option
            )
            
            // Update the scorecard.
            optionPoints[option.rawValue] = points.forOption
            optionPoints[ScoringOption.yahtzee.rawValue] += points.yahtzeeBonus
            
            // Advance to the next turnState
            turnState = turnState.next(scoringAs: option, points: points.total)
            turnAnalyzer = TurnAnalyzer(
                diceStore: diceStore,
                turnValues: turnValues,
                turnState: turnState
            )
            rollsLeft = Dice.extraRolls
            
            // Roll the dice for the next turn
            rollDice()

        case .rollDice(let selection):
            assert(rollsLeft > 0)
            rollsLeft -= 1
            rollDice(keep: selection)
        }
    }
    
    private func rollDice(keep: DiceSelection = DiceSelection(flags: 0)) {
        playerDice.indices.filter({ !keep.isSet($0) }).forEach {
            playerDice[$0] = Self.rollDie()
        }
        canonicalDice = diceStore.find(byValue: playerDice)
        analysis = turnAnalyzer.analyze(dice: canonicalDice, rollsLeft: rollsLeft)
    }
         
    init(turnValues: TurnValues, diceStore: DiceStore) {
        self.turnValues = turnValues
        self.diceStore = diceStore
        self.optionPoints = [Int](repeating: 0, count: ScoringOption.allCases.count)
        self.turnState = TurnState()
        self.turnAnalyzer = TurnAnalyzer(
            diceStore: diceStore,
            turnValues: turnValues,
            turnState: turnState
        )
        self.rollsLeft = Dice.extraRolls
        self.playerDice = (0..<Dice.maxCount).map { _ in Self.rollDie() }
        self.canonicalDice = diceStore.find(byValue: playerDice)
        self.analysis = turnAnalyzer.analyze(dice: canonicalDice, rollsLeft: rollsLeft)
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
