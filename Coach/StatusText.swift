//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import SwiftUI

// Displays a line of status.
struct StatusText: View {
    @ObservedObject private var model: GameModel
    
    init(model: GameModel) {
        self.model = model
    }

    private var text: String {
        if model.gameOver {
            return "Game Over!"
        }
        
        switch model.rollsLeft {
        case 2:
            return "You have two rolls left."
        case 1:
            return "You have one roll left."
        default:
            return "You have no rolls left \u{2014} you must score."
        }
    }
    
    var body: some View {
        Text(text)
            .foregroundStyle(.white)
            .font(.custom(Fonts.scoreCard, size: 20.0))
            .yahtzeeShadow()
    }
}

#Preview {
    StatusText(model: GameModel())
}
