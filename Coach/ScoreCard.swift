//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import SwiftUI

// Displays the title above the scorecard
struct ScoreCardTitle: View {
    @Environment(\.scaleFactor) private var scaleFactor: Double
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            Text("Yatzy")
                .font(.custom(Fonts.yahtzeeBrand, size: 30.0 * scaleFactor))
            Text("SCORECARD")
                .font(.custom(Fonts.scoreCard, size: 20.0 * scaleFactor))
        }
        .frame(height: 45.0 * scaleFactor)
    }
}

// Displays a column of scores
struct ScoreColumn<Content>: View where Content: View {
    @Environment(\.scaleFactor) private var scaleFactor: Double
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
                .stroke(lineWidth: scaleFactor)
        )
    }
}

// Displays a Yahtzee scorecard
struct ScoreCard: View {
    @Environment(\.appModel) private var appModel
    @Environment(\.scaleFactor) private var scaleFactor: Double
    
    var gameModel: GameModel { appModel.gameModel }
    
    var body: some View {
        @Bindable var appModel = appModel
        VStack(spacing: 15.0 * scaleFactor) {
            ScoreCardTitle()
            
            HStack(spacing: 16.0 * scaleFactor) {
                ScoreColumn(rowCount: 9) {
                    ScoringOptionView(
                        "Aces",
                        option: .aces,
                        gameModel: gameModel,
                        action: $appModel.action
                    )
                    ScoringOptionView(
                        "Twos",
                        option: .twos,
                        gameModel: gameModel,
                        action: $appModel.action
                    )
                    ScoringOptionView(
                        "Threes",
                        option: .threes,
                        gameModel: gameModel,
                        action: $appModel.action
                    )
                    ScoringOptionView(
                        "Fours",
                        option: .fours,
                        gameModel: gameModel,
                        action: $appModel.action
                    )
                    ScoringOptionView(
                        "Fives",
                        option: .fives,
                        gameModel: gameModel,
                        action: $appModel.action
                    )
                    ScoringOptionView(
                        "Sixes",
                        option: .sixes,
                        gameModel: gameModel,
                        action: $appModel.action
                    )
                    DerivedScoreView(
                        "**Total**",
                        type: .upperTotalBeforeBonus,
                        gameModel: gameModel
                    )
                    DerivedScoreView(
                        "**Bonus**",
                        type: .upperBonus,
                        gameModel: gameModel
                    )
                    DerivedScoreView(
                        "**Upper Total**",
                        type: .upperTotal,
                        gameModel: gameModel
                    )
                }
                ScoreColumn(rowCount: 9) {
                    ScoringOptionView(
                        "3 of a kind",
                        option: .threeOfAKind,
                        gameModel: gameModel,
                        action: $appModel.action
                    )
                    ScoringOptionView(
                        "4 of a kind",
                        option: .fourOfAKind,
                        gameModel: gameModel,
                        action: $appModel.action
                    )
                    ScoringOptionView(
                        "Full House",
                        option: .fullHouse,
                        gameModel: gameModel,
                        action: $appModel.action
                    )
                    ScoringOptionView(
                        "Sm. Straight",
                        option: .smStraight,
                        gameModel: gameModel,
                        action: $appModel.action
                    )
                    ScoringOptionView(
                        "Lg. Straight",
                        option: .lgStraight,
                        gameModel: gameModel,
                        action: $appModel.action
                    )
                    ScoringOptionView(
                        "Yatzy",
                        option: .yahtzee,
                        gameModel: gameModel,
                        action: $appModel.action
                    )
                    ScoringOptionView(
                        "Chance",
                        option: .chance,
                        gameModel: gameModel,
                        action: $appModel.action
                    )
                    DerivedScoreView(
                        "**Lower Total**",
                        type: .lowerTotal,
                        gameModel: gameModel
                    )
                    DerivedScoreView(
                        "**GRAND TOTAL**",
                        type: .grandTotal,
                        gameModel: gameModel
                    )
                }
            }
        }
        .padding(10.0 * scaleFactor)
        .background(Palette.scoreCardBackground)
    }
}

#Preview {
    struct ScoreCardPreview: View {
        var body: some View {
            ScoreCard()
        }
    }
    
    return ScoreCardPreview()
}
