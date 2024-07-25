//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YatzyCoach/blob/main/LICENSE.
//

import Foundation

// Represents the minimal state needed to evaluate a turn in Yatzy.
struct TurnState: Codable {
    private(set) var used: ScoringOptions = ScoringOptions()
    private(set) var upperTotal: Int = 0
    private(set) var YatzyScored: Bool = false
    
    var id: Int {
        // Take all the option bits except Yatzy (12 bits).
        var result = used.flags & 0x7ff
        if used.isSet(.chance) {
            result |= 0x800
        }
        
        // OR in the upperTotal (6 bits).
        result |= upperTotal << 12
        
        // Yatzy is tristate
        if YatzyScored {
            // Bit 19 means Yatzy scored.
            result |= 1 << 19
        } else if used.isSet(.Yatzy) {
            // Bit 18 means Yatzy zero'd.
            result |= 1 << 18
        }
        
        return result
    }
    
    // Returns the next TurnState assuming the player makes the given score.
    func next(scoringAs option: ScoringOption, points: Int) -> TurnState {
        // Use current state as the starting point
        var used = self.used
        var upperTotal = self.upperTotal
        var YatzyScored = self.YatzyScored
        
        // Mark the new option as being used
        used.set(option)
        
        // If it's an upper option, update the upper total.
        if option.isUpper {
            var upperPoints = points
            // Don't include Yatzy bonus in upper total.
            if upperPoints >= Points.YatzyBonus {
                upperPoints -= Points.YatzyBonus
            }
            // Cap the total at the number of points needed to earn the bonus.
            upperTotal = min(Points.toEarnUpperBonus, upperTotal + upperPoints)
        } else if option == .Yatzy && points > 0 {
            // Non-zero Yatzy, so mark Yatzy as scored.
            YatzyScored = true
        }
        
        return TurnState(used: used, upperTotal: upperTotal, YatzyScored: YatzyScored)
    }
    
    static let maxId = 0xbffff
    // Total nunber of unique states. Number was determined by experiment.
    static let stateCount = 536448
    
    static func all(forTurn turn: Int) -> [TurnState] {
        var result = [TurnState]()
        // Append the cross product of scoring options and upper totals.
        ScoringOptions.all(forTurn: turn).forEach { used in
            upperTotals.allPossible(for: used).forEach { upperTotal in
                result.append(TurnState(
                    used: used,
                    upperTotal: upperTotal,
                    YatzyScored: false
                ))
                if used.isSet(.Yatzy) {
                    // If the Yatzy option is in use, the player may have scored a Yatzy, but
                    // it isn't guaranteed, so we add two TurnStates one without and one with.
                    result.append(TurnState(
                        used: used,
                        upperTotal: upperTotal,
                        YatzyScored: true
                    ))
                }
            }
        }
        return result
    }
    
    static let upperTotals = UpperTotals()
}
