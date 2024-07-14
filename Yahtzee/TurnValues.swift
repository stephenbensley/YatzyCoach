//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import Foundation

// Used to cache the value of each value.
class TurnValues {
    private var values: [Double]
    
    func find(turnState: TurnState) -> Double {
        return values[turnState.id]
    }
    
    func insert(turnState: TurnState, value: Double) {
        values[turnState.id] = value
    }
    
    func encode() -> Data {
        // Float is ample precision and it keeps the file smaller
        return try! JSONEncoder().encode(values.map { Float($0) })
    }
    
    init() {
        self.values = [Double](repeating: 0.0, count: TurnState.maxId + 1)
    }
    
    init(_ values: [Double]) {
        self.values = values
    }
    
    static func decode(data: Data) -> TurnValues? {
        guard let floatValues = try? JSONDecoder().decode([Float].self, from: data) else {
            return nil
        }

        return TurnValues(floatValues.map { Double($0) })
    }
}
