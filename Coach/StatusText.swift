//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YatzyCoach/blob/main/LICENSE.
//

import SwiftUI

// Displays a line of status.
struct StatusText: View {
    @Environment(\.appModel) private var appModel
    @Environment(\.scaleFactor) private var scaleFactor: Double
    
    private var text: String {
        if appModel.gameModel.gameOver {
            return "Game Over!"
        }
        
        switch appModel.gameModel.rollsLeft {
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
            .foregroundStyle(Palette.statusText)
            .font(.custom(Fonts.scoreCard, size: 18.0 * scaleFactor))
            .yatzyShadow()
            .frame(height: 30.0 * scaleFactor)
    }
}

#Preview {
    struct StatusTextPreview: View {
        var body: some View {
            StatusText()
        }
    }
    return StatusTextPreview()
}
