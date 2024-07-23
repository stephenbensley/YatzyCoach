//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//


import Foundation

// Wraps GameModel to provide coaching
@Observable
class Coach {
    let gameModel: GameModel
    // Action being considered
    var action: Action = .rollDice(DiceSelection())
    // Indicates whether coaching is enabled
    var enabled: Bool = true
    // Minimum cost of an action to trigger coaching feedback
    var feedbackThreshold: Double = 0.2
    // Indicates whether coach should always show best move, rather than letting the player try
    // first
    var alwaysShowBest: Bool = false {
        didSet { if alwaysShowBest { action = gameModel.bestAction } }
    }
    
    // Cost of an action relative to the best action and rounded to the nearest tenth of a point.
    var actionCost: Double { 0.1 * round(-10.0 * gameModel.actionValue(action: action)) }
    
    // Indicates whether the coach approves of the current action.
    var isActionApproved: Bool { !enabled || actionCost < feedbackThreshold }
    
    // Indicates whether the current action is a valid roll action.
    var isValidRoll: Bool {
        if case .rollDice(let selection) = action {
            return !selection.allSet && gameModel.rollsLeft > 0 && !gameModel.gameOver
        } else {
            return false
        }
    }
    
    // Indicates whether the current action is a valid score action.
    var isValidScore: Bool { action.isScore && !gameModel.gameOver }

    init(gameModel: GameModel) {
        self.gameModel = gameModel
    }
    
    func newGame() {
        gameModel.newGame()
        if alwaysShowBest { showBestAction() }
    }
    
    func showBestAction() {
        if !gameModel.gameOver {
            action = gameModel.bestAction
        } else {
            action = .rollDice(DiceSelection())
        }
    }
    
    // Takes the current action unconditionally.
    func takeAction() {
        gameModel.takeAction(action: action)
        if alwaysShowBest {
            showBestAction()
        } else if gameModel.gameOver || action.isScore {
            action = .rollDice(DiceSelection())
        }
        // Otherwise, leave the current roll action in place.
    }
}
