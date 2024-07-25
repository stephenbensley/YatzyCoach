//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import SwiftUI

// Displays an individual die
struct DieView: View {
    @Environment(\.scaleFactor) private var scaleFactor: Double
    private let index: Int
    private let value: Int
    private let rollCount: Int
    @Binding private var action: Action
    // Used to animate the die when it's rolled.
    @State private var rotation = 0.0

    private var selected: Bool {
        if case .rollDice(let selection) = action {
            return selection.isSet(index)
        } else {
            return false
        }
    }
    
    init(index: Int, value: Int, rollCount: Int, action: Binding<Action>) {
        self.index = index
        self.value = value
        self.rollCount = rollCount
        self._action = action
    }
    
    var body: some View {
        Image(systemName: "die.face.\(value).fill")
            .resizable()
            .frame(width: 45.0 * scaleFactor, height: 45.0 * scaleFactor)
            .symbolRenderingMode(.palette)
            .foregroundStyle(Palette.dicePips, Palette.diceFill)
            .yahtzeeShadow()
            .contentShape(Rectangle())
            .overlay(
                // cornerRadius was determined through experiment to match the corner radius of
                // the SF Symbol
                RoundedRectangle(cornerRadius: 7.0 * scaleFactor)
                    .stroke(
                        selected ? Palette.selected : .clear,
                        lineWidth: Lengths.selectionWidth * scaleFactor
                    )
            )
            .onTapGesture(perform: onTap)
            .rotationEffect(.degrees(rotation))
            .onChange(of: rollCount) {
                withAnimation(.linear(duration: 0.4)) {
                    rotation += 360.0
                }
            }
    }
    
    private func onTap() {
        var newSelection: DiceSelection
        // If we already have a roll action, start with the existing selection; otherwise, use an
        // empty selection.
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
    @Environment(\.appModel) private var appModel
    @Environment(\.scaleFactor) private var scaleFactor: Double
    
    var body: some View {
        @Bindable var appModel = appModel
        HStack(spacing: 10.0 * scaleFactor) {
            ForEach(0..<5) {
                DieView(
                    index: $0,
                    value: appModel.gameModel.playerDice[$0],
                    rollCount: appModel.gameModel.rollCount[$0],
                    action: $appModel.action
                )
            }
        }
    }
}

#Preview {
    struct DicePreview: View {
        var body: some View {
            DiceView()
        }
    }
    return DicePreview()
}
