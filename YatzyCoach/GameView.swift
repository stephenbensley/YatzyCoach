//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YatzyCoach/blob/main/LICENSE.
//

import SwiftUI

// Displays the game of Yatzy.
struct GameView: View {
    // GameView was designed assuming this screen resolution.
    static let designSize = CGSize(width: 390.0, height: 667.0)

    @Environment(\.scaleFactor) private var scaleFactor: Double
    
    var body: some View {
        VStack(spacing: 15.0 * scaleFactor) {
            ScoreCardView()
            DiceView()
            StatusText()
            GameControlsView()
        }
        .padding(10.0 * scaleFactor)
    }
}

#Preview {
    struct GamePreview: View {
        var body: some View {
            GameView()
                .background(Palette.background)
        }
    }
    return GamePreview()
}
