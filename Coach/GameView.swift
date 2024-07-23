//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import SwiftUI

struct GameView: View {
    // GameView was designed assuming this screen resolution.
    static let designSize = CGSize(width: 390.0, height: 667.0)

    @Environment(\.scaleFactor) private var scaleFactor: Double
    private var appModel: Coach
    
    init(appModel: Coach) {
        self.appModel = appModel
    }
    
    var body: some View {
        VStack(spacing: 15.0 * scaleFactor) {
            ScoreCard(appModel: appModel)
            DiceView(appModel: appModel)
            StatusText(appModel: appModel)
            GameControlsView(appModel: appModel)
        }
        .padding(10.0 * scaleFactor)
    }
}

#Preview {
    struct GamePreview: View {
        @State var appModel = Coach.create()
        
        var body: some View {
            GameView(appModel: appModel)
                .background(Palette.background)
        }
    }
    
    return GamePreview()
}
