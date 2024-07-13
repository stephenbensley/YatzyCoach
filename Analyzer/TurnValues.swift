//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import Foundation

// Used to cache the value of each value.
class TurnValues: Codable {
    private var values = [Double](repeating: 0.0, count: TurnState.maxId + 1)
    
    func find(turnState: TurnState) -> Double {
        return values[turnState.id]
    }
    
    func insert(turnState: TurnState, value: Double) {
        values[turnState.id] = value
    }
}
