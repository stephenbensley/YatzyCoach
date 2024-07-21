//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import SwiftUI

// Displays the title above the scorecard
struct ScoreCardTitle: View {
    private var scale: Double
    
    init(width: Double) {
        scale = width / 300.0
    }
    
    var body: some View {
        HStack {
            Text("Yatzy")
                .font(.custom(Fonts.yahtzeeBrand, size: 30 * scale))
                .baselineOffset(9 * scale)
             Text("SCORE CARD")
                .font(.custom(Fonts.scoreCard, size: 20 * scale))
         }
    }
}

// Displays a column of scores
struct ScoreColumn<Content>: View where Content: View {
    private let rowCount: Int
    private let content: Content
    
    init(rowCount: Int, @ViewBuilder content: () -> Content) {
        self.rowCount = rowCount
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(
            GridLines(rowCount: rowCount, columnWidths: Score.columnWidths)
                .stroke()
        )
    }
}

// Displays a Yahtzee scorecard
struct ScoreCard: View {
    @ObservedObject private var model: GameModel
    @Binding private var action: Action
    
    init(model: GameModel, action: Binding<Action>) {
        self.model = model
        self._action = action
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                ScoreCardTitle(width: geo.size.width)
                
                HStack {
                    ScoreColumn(rowCount: 9) {
                        ScoringOptionView(
                            "Aces",
                            option: .aces,
                            model: model,
                            action: $action
                        )
                        ScoringOptionView(
                            "Twos",
                            option: .twos,
                            model: model,
                            action: $action
                        )
                        ScoringOptionView(
                            "Threes",
                            option: .threes,
                            model: model,
                            action: $action
                        )
                        ScoringOptionView(
                            "Fours",
                            option: .fours,
                            model: model,
                            action: $action
                        )
                        ScoringOptionView(
                            "Fives",
                            option: .fives,
                            model: model,
                            action: $action
                        )
                        ScoringOptionView(
                            "Sixes",
                            option: .sixes,
                            model: model,
                            action: $action
                        )
                        DerivedScoreView(
                            "*Total*",
                            type: .upperTotalBeforeBonus,
                            model: model
                        )
                        DerivedScoreView(
                            "*Bonus*",
                            type: .upperBonus,
                            model: model
                        )
                        DerivedScoreView(
                            "*Upper Total*",
                            type: .upperTotal,
                            model: model
                        )
                    }
                    ScoreColumn(rowCount: 9) {
                        ScoringOptionView(
                            "3 of a kind",
                            option: .threeOfAKind,
                            model: model,
                            action: $action
                        )
                        ScoringOptionView(
                            "4 of a kind",
                            option: .fourOfAKind,
                            model: model,
                            action: $action
                        )
                        ScoringOptionView(
                            "Full House",
                            option: .fullHouse,
                            model: model,
                            action: $action
                        )
                        ScoringOptionView(
                            "Sm. Straight",
                            option: .smStraight,
                            model: model,
                            action: $action
                        )
                        ScoringOptionView(
                            "Lg. Straight",
                            option: .lgStraight,
                            model: model,
                            action: $action
                        )
                        ScoringOptionView(
                            "Yatzy",
                            option: .yahtzee,
                            model: model,
                            action: $action
                        )
                        ScoringOptionView(
                            "Chance",
                            option: .chance,
                            model: model,
                            action: $action
                        )
                        DerivedScoreView(
                            "*Lower Total*",
                            type: .lowerTotal,
                            model: model
                        )
                        DerivedScoreView(
                            "**GRAND TOTAL**",
                            type: .grandTotal,
                            model: model
                        )
                    }
                }
            }
            .padding()
            .background(Palette.scoreCardBackground)
        }
    }
    
}

#Preview {
    struct ScoreCardPreview: View {
        @StateObject private var model = GameModel()
        @State private var action: Action = .rollDice(DiceSelection())
        
        var body: some View {
            ScoreCard(model: model, action: $action)
                .frame(width: 350, height: 550)
        }
    }
    
    return ScoreCardPreview()
}
