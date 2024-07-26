//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YatzyCoach/blob/main/LICENSE.
//

import Foundation

// Represents an action that a player can take in the game of Yatzy
enum Action: Codable, Equatable, Identifiable {
    case rollDice(DiceSelection)
    case scoreDice(ScoringOption)
    
    var id: Int {
        // Use low-order bit to differentiate cases.
        switch self {
        case .rollDice(let selection):
            return (selection.flags << 1) | 0
        case .scoreDice(let option):
            return (option.rawValue << 1) | 1
        }
    }
    
    var isRoll: Bool { if case .rollDice = self { true } else { false } }
    var isScore: Bool { !isRoll }
    
    // Convert from player space to canonical space.
    func canonize(from player: [Int], to canonical: Dice) -> Action {
        switch self {
        case .rollDice(let selection):
            // Keys don't depend on order, so if the keys match, we have equivalent selections.
            let key = Dice.computeKey(for: selection.apply(to: player))
            
            // keepOptions are exhaustive, so there's guaranteed to be a match.
            let (option, _) = zip(
                canonical.keepOptions,
                canonical.keepResults
            ).first(where: { (_, result) in
                result.key == key
            })!
            
            return .rollDice(option)
            
        case .scoreDice:
            // Scoring doesn't depend on order.
            return self
        }
    }
    
    // Convert from canonical space to player space
    func uncanonize(from canonical: Dice, to player: [Int]) -> Action {
        switch self {
        case .rollDice(let selection):
            // Keys don't depend on order, so if the keys match, we have equivalent selections.
            let key = Dice.computeKey(for: selection.apply(to: canonical.value))
            let option = DiceSelection.all.first { selection in
                Dice.computeKey(for: selection.apply(to: player)) == key
            }
            // We tried all DiceSelection, so there's guaranteed to be a match.
            return .rollDice(option!)
            
        case .scoreDice:
            // Scoring doesn't depend on order.
            return self
        }
    }
}

// Combines an Action with its expected value.
struct ActionValue: Identifiable {
    var action: Action
    var value: Double
    
    var id: Int { action.id }
}
