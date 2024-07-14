//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import Foundation

// Patterns formed by a set of five dice when order doesn't matter.
enum DicePattern: Int, CaseIterable {
    case none
    case pair
    case twoPair
    case threeOfAKind
    case fullHouse
    case fourOfAKind
    case fiveOfAKind
    
    var canonicalExample: [Int] {
        switch self {
        case .none:
            return [5, 4, 3, 2, 1]
        case .pair:
            return [4, 4, 3, 2, 1]
        case .twoPair:
            return [3, 3, 2, 2, 1]
        case .threeOfAKind:
            return [3, 3, 3, 2, 1]
        case .fullHouse:
            return [2, 2, 2, 1, 1]
        case .fourOfAKind:
            return [2, 2, 2, 2, 1]
        case .fiveOfAKind:
            return [1, 1, 1, 1, 1]
        }
    }
}
