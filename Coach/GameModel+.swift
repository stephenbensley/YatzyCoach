//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import Foundation

extension GameModel {
    // It's a pain using StateObjects without a default initializer.
    convenience init() {
        guard let turnValues = TurnValues(
            forResource: "yahtzeeSolution",
            withExtension: "json"
        ) else {
            fatalError("Unable to load solution file.")
        }
        self.init(turnValues: turnValues, diceStore: DiceStore())
    }
}
