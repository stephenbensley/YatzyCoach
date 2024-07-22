//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import SwiftUI

// Button used as part of GameControls.
struct ControlButton: View {
    @Environment(\.scaleFactor) private var scaleFactor: Double
    
    private var label: LocalizedStringKey
    private var disabled: Bool
    private var action: () -> Void
    
    init(_ label: LocalizedStringKey, disabled: Bool = false, action: @escaping () -> Void = { }) {
        self.label = label
        self.disabled = disabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action, label: {
            Text(label)
                .font(.custom(Fonts.scoreCard, size: 20.0 * scaleFactor))
                .foregroundStyle(Palette.buttonText)
                .frame(minWidth: 85 * scaleFactor)
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

struct GameControls: View {
    @Environment(\.scaleFactor) private var scaleFactor: Double
    
    @ObservedObject private var model: GameModel
    @Binding private var action: Action
    @State private var showingConfirmMove = false
    @State private var confirmMoveMessage: LocalizedStringKey = ""
    @State private var showingGameOver = false
    
    private var isRollDisabled: Bool {
        if case .rollDice(let selection) = action {
            return selection.allSet || model.rollsLeft == 0 || model.gameOver
        } else {
            return true
        }
    }
    private var isScoreDisabled: Bool { action.isRoll || model.gameOver }
    
    init(model: GameModel, action: Binding<Action>) {
        self.model = model
        self._action = action
    }
    
    var body: some View {
        HStack(spacing: 20 * scaleFactor) {
            if model.gameOver {
                ControlButton("New Game", action: model.newGame)

            } else {
                ControlButton("Roll", disabled: isRollDisabled, action: takeAction)
                ControlButton("Score", disabled: isScoreDisabled, action: takeAction)
            }
          }
         .alert("Game Over", isPresented: $showingGameOver) {
            Button("New Game") { model.newGame() }
            Button("Dismiss") { }
        }
        .alert("Better Move Available", isPresented: $showingConfirmMove) {
            Button("Make my move anyway") {
                takeActionAlways()
            }
            Button("Let me try again", role: .cancel) {
                
            }
            Button("Show me the best") {
                action = model.bestAction
            }
        } message: {
            Text(confirmMoveMessage)
        }

    }
    
    private func takeAction() {
        let value = model.actionValue(action: action)
        guard value >= -0.05 else {
            confirmMoveMessage = """
There is a better move that would score an average of \(-value, specifier: "%.1f") more points \
over the course of the game.
"""
            showingConfirmMove = true
            return
        }
        
        takeActionAlways()
    }
    
    private func takeActionAlways() {
        model.takeAction(action: action)
        if action.isScore {
            action = .rollDice(DiceSelection())
        }
        showingGameOver = model.gameOver
    }
}


#Preview  {
    struct GameControlsPreview: View {
        @StateObject private var model = GameModel()
        @State private var action: Action = .rollDice(DiceSelection())
        
        var body: some View {
            GameControls(model: model, action: $action)
        }
    }
    
    return GameControlsPreview()
}
