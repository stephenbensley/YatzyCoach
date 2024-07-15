//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import Foundation

// Represents an action that a player can take in the game of Yahtzee
enum Action: Equatable {
    case scoreDice(ScoringOption)
    case rollDice(DiceSelection)
    
    // Convert from player space to canonical space.
    func canonize(from player: [Int], to canonical: Dice) -> Action {
        switch self {
        case .scoreDice:
            return self
        case .rollDice(let selection):
            let key = Dice.computeKey(for: selection.apply(to: player))
            for (option, result) in zip(canonical.keepOptions, canonical.keepResults) {
                if key == result.key {
                    return .rollDice(option)
                }
            }
            assert(false)
            return self
        }
    }
    
    // Convert from canonical space to player space
    func uncanonize(from canonical: Dice, to player: [Int]) -> Action {
        switch self {
        case .scoreDice:
            return self
        case .rollDice(let selection):
            let key = Dice.computeKey(for: selection.apply(to: canonical.value))
            for option in DiceSelection.all {
                if key == Dice.computeKey(for: option.apply(to: player)) {
                    return .rollDice(option)
                }
            }
            assert(false)
            return self
        }
    }
}

// Combines an Action with its expected value.
struct ActionValue {
    var action: Action
    var value: Double
}
