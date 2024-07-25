//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import SwiftUI

// Displays a detailed analysis of the current game state.
struct AnalysisView: View {
    @Environment(\.appModel) private var appModel
    @Environment(\.dismiss) private var dismiss
    
    var gameModel: GameModel { appModel.gameModel }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("""
                The computer analyzes each legal play for the current position and  computes \
                the expected final score assuming optimal play for the remainder of the game.
                """)
                .font(.footnote)
                .padding(.bottom)
                ScrollView {
                    Grid(alignment: .leading) {
                        GridRow {
                            Text("Play")
                            Text("Score")
                        }
                        .font(.title2)
                        
                        // Divider to separate headings from items
                        Divider()
                        ForEach(gameModel.analysis) { item in
                            GridRow {
                                toText(item.action)
                                toText(item.value)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .navigationTitle("Analysis")
            .toolbar {
                Button("Done") { dismiss() }
            }
        }
    }
    
    func toString(_ option: ScoringOption) -> String {
        switch option {
        case .aces:
            return "Aces"
        case .twos:
            return "Twos"
        case .threes:
            return "Threes"
        case .fours:
            return "Fours"
        case .fives:
            return "Fives"
        case .sixes:
            return "Sixes"
        case .threeOfAKind:
            return "3 of a kind"
        case .fourOfAKind:
            return "4 of a kind"
        case .fullHouse:
            return "Full House"
        case .smStraight:
            return "Sm. Straight"
        case .lgStraight:
            return "Lg. Straight"
        case .yahtzee:
            return "Yatzy"
        case .chance:
            return "Chance"
        }
    }
    
    func toText(_ action: Action) -> Text {
        switch action {
        case .rollDice(let selection):
            guard selection.count > 0 else {
                return Text("Roll all dice")
            }
            let values = gameModel.canonicalDice.value
            return selection.apply(to: values).sorted().reduce(Text("Keep ")) { result, value in
                result + Text(Image(systemName: "die.face.\(value)"))
            }
            
        case .scoreDice(let option):
            let points = gameModel.computePoints(option: option).forOption
            return Text("Play **\(toString(option))** for \(points) points")
        }
    }
    
    func toText(_ value: Double) -> Text {
        let grandTotal = gameModel.derivedPoints(.grandTotal) ?? 0
        let totalValue = value + Double(grandTotal)
        return Text("\(totalValue, specifier: "%.1f")")
    }
}

#Preview {
    struct AnalysisPreview: View {
        var body: some View {
            AnalysisView()
        }
    }
    
    return AnalysisPreview()
}
