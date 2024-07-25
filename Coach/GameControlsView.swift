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

// Presents the ControlButtons and implements most of the behavior of the app.
struct GameControlsView: View {
    @Environment(\.appModel) private var appModel
    @Environment(\.scaleFactor) private var scaleFactor: Double
    
    // Prompt the player to confirm their move.
    @State private var confirmMove = false
    @State private var confirmMoveMsg: LocalizedStringKey = ""
    
    // Alert the player that the game is over.
    @State private var showGameOver = false
    @State private var gameOverMsg: LocalizedStringKey = ""
    
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
            Button("Play again", action: appModel.newGame)
            Button("Admire my scorecard") { }
        } message: {
            Text(gameOverMsg)
        }
        .alert("Better Move Available", isPresented: $confirmMove) {
            Button("Yes, show me the best move", action: appModel.showBestAction)
            Button("No, I'll stick with my choice", action: takeAction)
            Button("Let me try again") { }
        } message: {
            Text(confirmMoveMsg)
        }
    }
    
    private func tryAction() {
        if appModel.isActionApproved {
            takeAction()
        } else {
            confirmMove = true
            confirmMoveMsg = """
                There is a better move that would score an average of \
                \(appModel.actionCost, specifier: "%.1f") more points \
                over the course of the game. Do you want to see it?
                """
        }
    }
    
    private func takeAction() {
        appModel.takeAction()
        if appModel.gameModel.gameOver {
            Task {
                // Introduce a slight delay, so the game over alert isn't quite so jarring.
                try await Task.sleep(nanoseconds: 250_000_000)
                showGameOver = true
                gameOverMsg = """
                    You scored \(appModel.gameModel.derivedPoints(.grandTotal) ?? 0) points.
                    """
            }
        }
    }
}

#Preview  {
    struct GameControlsPreview: View {
        var body: some View {
            GameControlsView()
        }
    }    
    return GameControlsPreview()
}
