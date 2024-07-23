//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import SwiftUI

// Button used as part of GameControlsView.
struct ControlButton: View {
    @Environment(\.scaleFactor) private var scaleFactor: Double
    private var label: LocalizedStringKey
    private var disabled: Bool
    private var action: () -> Void
    
    init(_ label: LocalizedStringKey, disabled: Bool = false, action: @escaping () -> Void) {
        self.label = label
        self.disabled = disabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action, label: {
            Text(label)
                .font(.custom(Fonts.scoreCard, size: 20.0 * scaleFactor))
                .foregroundStyle(Palette.buttonText)
                .frame(minWidth: 85.0 * scaleFactor)
                .frame(height: 30.0 * scaleFactor)
                .padding(.horizontal, 5.0 * scaleFactor)
        })
        .buttonStyle(.bordered)
        .background(disabled ? Palette.buttonDisabled : Palette.buttonEnabled)
        .clipShape(Capsule())
        .disabled(disabled)
        .yahtzeeShadow()
    }
}

struct GameControlsView: View {
    @Environment(\.scaleFactor) private var scaleFactor: Double
    private var appModel: Coach
    
    // Prompt the player to confirm their move.
    @State private var confirmMove = false
    @State private var confirmMoveMsg: LocalizedStringKey = ""
    
    // Alert the player that the game is over.
    @State private var showGameOver = false
    @State private var gameOverMsg: LocalizedStringKey = ""
    
    init(appModel: Coach) {
        self.appModel = appModel
    }
    
    var body: some View {
        HStack(spacing: 20.0 * scaleFactor) {
            if appModel.gameModel.gameOver {
                ControlButton("New Game", action: appModel.newGame)
            } else {
                ControlButton("Roll", disabled: !appModel.isValidRoll, action: tryAction)
                ControlButton("Score", disabled: !appModel.isValidScore, action: tryAction)
            }
        }
        .alert("Game Over", isPresented: $showGameOver) {
            Button("New Game", action: appModel.newGame)
            Button("Dismiss") { }
        } message: {
            Text(gameOverMsg)
        }
        .alert("Better Move Available", isPresented: $confirmMove) {
            Button("Make my move anyway", action: takeAction)
            Button("Let me try again") { }
            Button("Show me the best", action: appModel.showBestAction)
        } message: {
            Text(confirmMoveMsg)
        }
    }
    
    private func tryAction() {
        if appModel.isActionApproved {
            takeAction()
        } else {
            confirmMove = true
            confirmMoveMsg =
                    """
                    There is a better move that would score an average of \
                    \(appModel.actionCost, specifier: "%.1f") more points \
                    over the course of the game.
                    """
        }
    }
    
    private func takeAction() {
        appModel.takeAction()
        showGameOver = appModel.gameModel.gameOver
        if showGameOver {
            gameOverMsg = "You scored \(appModel.gameModel.derivedPoints(.grandTotal) ?? 0) points."
        }
    }
}

#Preview  {
    struct GameControlsPreview: View {
        @State private var appModel = Coach.create()
        
        var body: some View {
            GameControlsView(appModel: appModel)
        }
    }
    
    return GameControlsPreview()
}
