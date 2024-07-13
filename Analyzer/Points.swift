//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import Foundation

// Implements the scoring rules for Yahtzee
class Points {
    // Points scored for various scoring options
    static let toEarnUpperBonus = 63
    static let upperBonus = 35
    static let fullHouse = 25
    static let smStraight = 30
    static let lgStraight = 40
    static let yahtzee = 50
    static let yahtzeeBonus = 100
    
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
            points = dice.reduce(0) { ($1 == dieValue) ? ($0 + dieValue) : $0 }
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
    
    // Updates basePoints to account for current turn state.
    static func computeFinal(state: TurnState, dice: Dice, option: ScoringOption) -> Int {
        // Can't use a scoring option twice
        guard !state.used.isSet(option) else {
            return 0
        }
        
        let basePoints = dice.basePoints(scoredAs: option)
        var points = basePoints
        
        // Are the joker rules in effect?
        if dice.pattern == .fiveOfAKind && state.used.isSet(.yahtzee) {
            // Upper option for this roll
            let upperOption = ScoringOption(rawValue: dice.value[0] - 1)!
            if state.used.isSet(upperOption) {
                // Upper option already used, so Yahtzee can be scored as a full house or straight.
                switch option {
                case .fullHouse:
                    points = Points.fullHouse
                case .smStraight:
                    points = Points.smStraight
                case .lgStraight:
                    points = Points.lgStraight
                default:
                    break
                }
            } else {
                // Player must use upper option
                if option != upperOption {
                    points = 0
                }
            }
            
            // Add in the Yahtzee bonus
            if state.yahtzeeScored {
                points += Points.yahtzeeBonus
            }
        }
        
        // Did we earn the upper bonus?
        if option.isUpper &&
            (state.upperTotal < Points.toEarnUpperBonus) &&
            ((state.upperTotal + basePoints) >= Points.toEarnUpperBonus) {
            points += Points.upperBonus
        }
        
        return points
    }
}

