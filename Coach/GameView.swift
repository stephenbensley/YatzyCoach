//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import SwiftUI

struct GameView: View {
    @StateObject private var model = GameModel()
    @State private var action: Action = .rollDice(DiceSelection())
    
    var body: some View {
        NavigationStack {
            VStack {
                ScoreCard(model: model, action: $action)
                    .padding()
                DiceView(model: model, action: $action)
                    .padding()
                StatusText(model: model)
                GameControls(model: model, action: $action)
                    .padding()
            }
            .background(Palette.background)
            .toolbar {
                Button {
                    
                } label: {
                    Image(systemName: "info.circle")
                }
                Button {
                    
                } label: {
                    Image(systemName: "questionmark.circle")
                }
                Button {
                    
                } label: {
                    Image(systemName: "gearshape")
                }
            }
            .accentColor(Palette.toolbar)
        }
    }
}

#Preview {
    GameView()
}
