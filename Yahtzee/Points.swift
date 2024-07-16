//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import Foundation

// Implements the scoring rules for Yahtzee
final class Points {
    // Points scored for various scoring options
    static let toEarnUpperBonus = 63
    static let upperBonus = 35
    static let fullHouse = 25
    static let smStraight = 30
    static let lgStraight = 40
    static let yahtzee = 50
    static let yahtzeeBonus = 100
    
    // Breaks down points scored according to where they're tallied on the score card.
    struct ByType {
        var forOption = 0
        var upperBonus = 0
        var yahtzeeBonus = 0
        
        var total: Int { forOption + upperBonus + yahtzeeBonus }
    }
    
    // Computes points scored without regard to game state, e.g., no bonuses or jokers.
    static func computeBase(
        for dice: [Int],
        scoredAs opt: ScoringOption,
        pattern: DicePattern,
        longestRun: Int
    ) -> Int {
        var points = 0
        
        switch opt {
        case .aces, .twos, .threes, .fours, .fives, .sixes:
            let dieValue = opt.rawValue + 1
            points = dice.filter({ $0 == dieValue }).reduce(0, +)
        case .threeOfAKind:
            switch pattern {
            case .threeOfAKind, .fullHouse, .fourOfAKind, .fiveOfAKind:
                points = dice.reduce(0, +)
            default:
                break
            }
        case .fourOfAKind:
            switch pattern {
            case .fourOfAKind, .fiveOfAKind:
                points = dice.reduce(0, +)
            default:
                break
            }
        case .fullHouse:
            if (pattern == .fullHouse) {
                points = Self.fullHouse
            }
        case .smStraight:
            if longestRun >= 4 {
                points = Self.smStraight
            }
        case .lgStraight:
            if longestRun == 5 {
                points = Self.lgStraight
            }
        case .yahtzee:
            if pattern == .fiveOfAKind {
                points = Self.yahtzee
            }
        case .chance:
            points = dice.reduce(0, +)
        }
        
        return points
    }
    
    // Actual points scored accounting for game state and broken down by type.
    static func computeByType(state: TurnState, dice: Dice, option: ScoringOption) -> ByType {
        var result = ByType()
        
        // Can't use a scoring option twice
        guard !state.used.isSet(option) else {
            return result
        }
        
        result.forOption = dice.basePoints(scoredAs: option)
        
        // Are the joker rules in effect?
        if dice.pattern == .fiveOfAKind && state.used.isSet(.yahtzee) {
            // Upper option for this roll
            let upperOption = ScoringOption.fromDieValue(dice.value[0])
            if state.used.isSet(upperOption) {
                // Upper option already used, so Yahtzee can be scored as a full house or straight.
                switch option {
                case .fullHouse:
                    result.forOption = Points.fullHouse
                case .smStraight:
                    result.forOption = Points.smStraight
                case .lgStraight:
                    result.forOption = Points.lgStraight
                default:
                    break
                }
            } else {
                // Player must use upper option
                if option != upperOption {
                    result.forOption = 0
                }
            }
            
            // Did we earn the Yahtzee bonus?
            if state.yahtzeeScored {
                result.yahtzeeBonus = Points.yahtzeeBonus
            }
        }
        
        // Did we earn the upper bonus?
        if option.isUpper &&
            (state.upperTotal < Points.toEarnUpperBonus) &&
            ((state.upperTotal + result.forOption) >= Points.toEarnUpperBonus) {
            result.upperBonus = Points.upperBonus
        }
        
        return result
    }
    
    // Total points scored accounting for game state.
    static func compute(state: TurnState, dice: Dice, option: ScoringOption) -> Int {
        return computeByType(state: state, dice: dice, option: option).total
    }
}
