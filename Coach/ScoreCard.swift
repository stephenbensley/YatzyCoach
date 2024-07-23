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
            Text("SCORE CARD")
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
    @Environment(\.scaleFactor) private var scaleFactor: Double
    @Bindable private var appModel: Coach
    
    init(appModel: Coach) {
        self.appModel = appModel
    }
    
    var body: some View {
        VStack(spacing: 15.0 * scaleFactor) {
            ScoreCardTitle()
            
            HStack(spacing: 16.0 * scaleFactor) {
                ScoreColumn(rowCount: 9) {
                    ScoringOptionView(
                        "Aces",
                        option: .aces,
                        gameModel: appModel.gameModel,
                        action: $appModel.action
                    )
                    ScoringOptionView(
                        "Twos",
                        option: .twos,
                        gameModel: appModel.gameModel,
                        action: $appModel.action
                    )
                    ScoringOptionView(
                        "Threes",
                        option: .threes,
                        gameModel: appModel.gameModel,
                        action: $appModel.action
                    )
                    ScoringOptionView(
                        "Fours",
                        option: .fours,
                        gameModel: appModel.gameModel,
                        action: $appModel.action
                    )
                    ScoringOptionView(
                        "Fives",
                        option: .fives,
                        gameModel: appModel.gameModel,
                        action: $appModel.action
                    )
                    ScoringOptionView(
                        "Sixes",
                        option: .sixes,
                        gameModel: appModel.gameModel,
                        action: $appModel.action
                    )
                    DerivedScoreView(
                        "**Total**",
                        type: .upperTotalBeforeBonus,
                        gameModel: appModel.gameModel
                    )
                    DerivedScoreView(
                        "**Bonus**",
                        type: .upperBonus,
                        gameModel: appModel.gameModel
                    )
                    DerivedScoreView(
                        "**Upper Total**",
                        type: .upperTotal,
                        gameModel: appModel.gameModel
                    )
                }
                ScoreColumn(rowCount: 9) {
                    ScoringOptionView(
                        "3 of a kind",
                        option: .threeOfAKind,
                        gameModel: appModel.gameModel,
                        action: $appModel.action
                    )
                    ScoringOptionView(
                        "4 of a kind",
                        option: .fourOfAKind,
                        gameModel: appModel.gameModel,
                        action: $appModel.action
                    )
                    ScoringOptionView(
                        "Full House",
                        option: .fullHouse,
                        gameModel: appModel.gameModel,
                        action: $appModel.action
                    )
                    ScoringOptionView(
                        "Sm. Straight",
                        option: .smStraight,
                        gameModel: appModel.gameModel,
                        action: $appModel.action
                    )
                    ScoringOptionView(
                        "Lg. Straight",
                        option: .lgStraight,
                        gameModel: appModel.gameModel,
                        action: $appModel.action
                    )
                    ScoringOptionView(
                        "Yatzy",
                        option: .yahtzee,
                        gameModel: appModel.gameModel,
                        action: $appModel.action
                    )
                    ScoringOptionView(
                        "Chance",
                        option: .chance,
                        gameModel: appModel.gameModel,
                        action: $appModel.action
                    )
                    DerivedScoreView(
                        "**Lower Total**",
                        type: .lowerTotal,
                        gameModel: appModel.gameModel
                    )
                    DerivedScoreView(
                        "**GRAND TOTAL**",
                        type: .grandTotal,
                        gameModel: appModel.gameModel
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
        @State private var appModel = Coach.create()
        
        var body: some View {
            ScoreCard(appModel: appModel)
        }
    }
    
    return ScoreCardPreview()
}
