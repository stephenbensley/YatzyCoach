//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import SwiftUI

// Displays an individual die
struct DieView: View {
    private let index: Int
    private let value: Int
    @Binding private var action: Action
    
    private var selected: Bool {
        if case .rollDice(let selection) = action {
            return selection.isSet(index)
        } else {
            return false
        }
    }
    
    init(index: Int, value: Int, action: Binding<Action>) {
        self.index = index
        self.value = value
        self._action = action
    }
    
    var body: some View {
        Image(systemName: "die.face.\(value).fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .symbolRenderingMode(.palette)
            .foregroundStyle(Palette.dicePips, Palette.diceFill)
            .yahtzeeShadow()
            .contentShape(Rectangle())
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        selected ? Palette.selected : .clear,
                        lineWidth: Lengths.selectionWidth
                    )
            )
            .onTapGesture(perform: onTap)
    }
    
    private func onTap() {
        var newSelection: DiceSelection
        if case .rollDice(let selection) = action {
            newSelection = selection
        } else {
            newSelection = DiceSelection()
        }
        newSelection.toggle(index)
        action = .rollDice(newSelection)
    }
}

// Displays all the dice
struct DiceView: View {
    @ObservedObject private var model: GameModel
    @Binding private var action: Action
    
    init(model: GameModel, action: Binding<Action>) {
        self.model = model
        self._action = action
    }
    
    var body: some View {
        HStack(spacing: Lengths.diceSpacing) {
            ForEach(0..<5) {
                DieView(index: $0, value: model.playerDice[$0], action: $action)
            }
        }
    }
}

#Preview {
    struct DicePreview: View {
        @StateObject private var model = GameModel()
        @State private var action: Action = .rollDice(DiceSelection())
        
        var body: some View {
            DiceView(model: model, action: $action)
        }
    }
    
    return DicePreview()
}

