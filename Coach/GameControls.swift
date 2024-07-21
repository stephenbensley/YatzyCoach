//
//  ButtonsView.swift
//  Coach
//
//  Created by Stephen Bensley on 7/20/24.
//

import SwiftUI

struct YahtzeeButton: View {
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
                .font(.custom(Fonts.scoreCard, size: 16.0))
                .foregroundStyle(.black)
                .frame(width: 90)
        })
        .buttonStyle(.bordered)
        .background(disabled ? Palette.buttonDisabled : Palette.buttonEnabled)
        .clipShape(Capsule())
        .disabled(disabled)
        .yahtzeeShadow()
    }
}

struct GameControls: View {
    @ObservedObject private var model: GameModel
    @Binding private var action: Action
    @State private var showingConfirmMove = false
    @State private var confirmMoveMessage: LocalizedStringKey = ""
    @State private var showingGameOver = false
    
    init(model: GameModel, action: Binding<Action>) {
        self.model = model
        self._action = action
    }
    
    var body: some View {
        HStack {
            YahtzeeButton("Roll", disabled: action.isScore || model.rollsLeft == 0, action: takeAction)
            YahtzeeButton("Score", disabled: action.isRoll || model.gameOver, action: takeAction)
            YahtzeeButton("New Game", action: model.newGame)
         }
        .alert("Game Over", isPresented: $showingGameOver) {
            Button("New Game") { model.newGame() }
            Button("Dismiss") { }
        }
        .alert("Better Move Available", isPresented: $showingConfirmMove) {
            Button("Make my move anyway") {
                //takeAction()
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
    
    func takeAction() {
        let value = model.actionValue(action: action)
        guard value >= -0.05 else {
            confirmMoveMessage = """
There is a better move that would score an average of \(-value, specifier: "%.1f") more points \
over the course of the game.
"""
            showingConfirmMove = true
            return
        }
        
        model.takeAction(action: action)
        if action.isScore {
            action = .rollDice(DiceSelection())
        }
        showingGameOver = model.gameOver
    }
}


#Preview  {
    struct ButtonsPreview: View {
        @StateObject private var model = GameModel()
        @State private var action: Action = .rollDice(DiceSelection())
        
        var body: some View {
            GameControls(model: model, action: $action)
        }
    }
    
    return ButtonsPreview()
}
