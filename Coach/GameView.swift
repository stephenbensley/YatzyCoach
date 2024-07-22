//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import SwiftUI

extension CGSize {
    var aspectRatio: CGFloat {
        return height / width
    }
}

struct ScaleFactorKey: EnvironmentKey {
    static let defaultValue = 1.0
}

extension EnvironmentValues {
    var scaleFactor: Double {
        get { self[ScaleFactorKey.self] }
        set { self[ScaleFactorKey.self] = newValue }
    }
}

extension View {
    func scaleFactor(_ value: Double) -> some View {
        environment(\.scaleFactor, value)
    }
}
struct GameView: View {
    @ObservedObject private var model: GameModel
    @State private var action: Action = .rollDice(DiceSelection())
    let scaleFactor: Double
    
    init(model: GameModel, size actual: CGSize) {
        self.model = model
        
        // Size GameView was designed for
        let design = CGSize(width: 390, height: 667)
        if actual.aspectRatio > design.aspectRatio {
            // View is skinnier that design, so width is bottleneck
            scaleFactor = actual.width / design.width
        } else {
            // Frame is fatter, so height is bottleneck
            scaleFactor = actual.height / design.height
        }
    }
    
    var body: some View {
        VStack(spacing: 15.0 * scaleFactor) {
            ScoreCard(model: model, action: $action)
            DiceView(model: model, action: $action)
            StatusText(model: model)
            GameControls(model: model, action: $action)
         }
        .padding(10.0 * scaleFactor)
        .environment(\.scaleFactor, scaleFactor)
    }
}


#Preview {
    GameView(model: GameModel(), size: CGSize(width: 390, height: 667))
        .background(Palette.background)
}
