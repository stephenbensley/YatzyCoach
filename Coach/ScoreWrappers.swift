//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import SwiftUI

struct DerivedScoreView: View {
    private let title: LocalizedStringKey
    private let type: DerivedScore
    private let points: Int?

    init(
        _ title: LocalizedStringKey,
        type: DerivedScore,
        model: GameModel
    ) {
        self.title = title
        self.type = type
        self.points = model.derivedPoints(type)
    }
    
    var body: some View {
        Score(title, points: points)
    }
}

// Display a ScoringOption
struct ScoringOptionView: View {
    private let title: LocalizedStringKey
    private let option: ScoringOption
    private let points: Int?
    @Binding private var action: Action
    
    private var selected: Bool { action == .scoreDice(option) }

    init(
        _ title: LocalizedStringKey,
        option: ScoringOption,
        model: GameModel,
        action: Binding<Action>
    ) {
        self.title = title
        self.option = option
        self.points = model.optionPoints(option)
        self._action = action
    }
    
    var body: some View {
        Score(title, points: points, selected: selected, onTap: onTap)
    }

    private func onTap() {
        if selected {
            action = .rollDice(DiceSelection())
        } else  if points == nil {
            action = .scoreDice(option)
        }
    }
}
