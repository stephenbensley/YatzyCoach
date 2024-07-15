//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import Foundation

// Analyzes the various roll states that occur during a turn.
class TurnAnalyzer {
    private let diceStore: DiceStore
    private let turnValues: TurnValues
    private let state: TurnState
    private var rollValues = [[Double]]()
    
    // Returns all possible action values for the given state
    func analyze(dice: Dice, rollsLeft: Int) -> [ActionValue] {
        var analysis = ScoringOption.allCases.filter({ !state.used.isSet($0) }).map { option in
            let value = evaluateScoreAction(dice: dice, option: option)
            return ActionValue(action: .scoreDice(option), value: value)
        }
        
        if rollsLeft > 0 {
            zip(dice.keepOptions, dice.keepResults).forEach { option, result in
                let value = evaluateRollAction(dice: dice, rollsLeft: rollsLeft, kept: result)
                analysis.append(ActionValue(action: .rollDice(option), value: value))
            }
        }
        
        return analysis.sorted(by: { $0.value > $1.value })
    }
    
    // Returns the expected number of points scored during the remainder of the game from the
    // current state assuming optimal play.
    func evaluate() -> Double {
        // Expected score is just the weighted sum of the expected score for each possible roll.
        diceStore.all(withCount: Dice.maxCount).reduce(0.0) { result, dice in
            result + evaluate(dice: dice, rollsLeft: Dice.extraRolls) * dice.probability
        }
    }
    
    func evaluate(dice: Dice, rollsLeft: Int) -> Double {
        guard rollsLeft > 0 else {
            // No rolls left, so our only option is to score.
            return ScoringOption.allCases.reduce(0.0) { result, option in
                if (!state.used.isSet(option)) {
                    let value = evaluateScoreAction(dice: dice, option: option)
                    return max(result, value)
                } else {
                    return result
                }
            }
        }
        
        // We can always score and scoring doesn't depend on how many rolls are left, so use the
        // cached value for rollsLeft == 0.
        let result = rollValues[0][dice.ordinal]
        
        // Now see if any of the roll actions give a better result.
        return dice.keepResults.reduce(result) { result, kept in
            let value = evaluateRollAction(dice: dice, rollsLeft: rollsLeft, kept: kept)
            return max(result, value)
        }
    }
    
    private func evaluateScoreAction(dice: Dice, option: ScoringOption) -> Double {
        // This is how many points we'll score right now
        let points = Points.compute(state: state, dice: dice, option: option)
        // Next turn state in the game tree assuming we make this play
        let nextTurn = state.next(scoringAs: option, points: points)
        // Add the expected points we'll score for the rest of the game.
        return Double(points) + turnValues.find(turnState: nextTurn)
    }
    
    private func evaluateRollAction(dice: Dice, rollsLeft: Int, kept: Dice) -> Double {
        let numToRoll = Dice.maxCount - kept.count
        return diceStore.all(withCount: numToRoll).reduce(0.0) { result, rolled in
            let nextRoll = diceStore.concatenate(kept, rolled)
            let value = rollValues[rollsLeft - 1][nextRoll.ordinal]
            return result + value * rolled.probability
        }
    }
    
    init(diceStore: DiceStore, turnValues: TurnValues, turnState: TurnState) {
        self.diceStore = diceStore
        self.turnValues = turnValues
        self.state = turnState
        
        let combos = diceStore.all(withCount: Dice.maxCount)
        for rollsLeft in 0..<Dice.extraRolls {
            rollValues.append(combos.map { evaluate(dice: $0, rollsLeft: rollsLeft) })
        }
    }
}
