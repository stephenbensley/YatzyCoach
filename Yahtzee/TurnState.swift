//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import Foundation

// Represents the minimal state needed to evaluate a turn in Yahtzee.
struct TurnState: Codable {
    private(set) var used: ScoringOptions = ScoringOptions()
    private(set) var upperTotal: Int = 0
    private(set) var yahtzeeScored: Bool = false
    
    var id: Int {
        // Take all the option bits except Yahtzee (12 bits).
        var result = used.flags & 0x7ff
        if used.isSet(.chance) {
            result |= 0x800
        }
        
        // OR in the upperTotal (6 bits).
        result |= upperTotal << 12
        
        // Yahtzee is tristate
        if yahtzeeScored {
            // Bit 19 means Yahtzee scored.
            result |= 1 << 19
        } else if used.isSet(.yahtzee) {
            // Bit 18 means Yahtzee zero'd.
            result |= 1 << 18
        }
        
        return result
    }
    
    // Returns the next TurnState assuming the player makes the given score.
    func next(scoringAs option: ScoringOption, points: Int) -> TurnState {
        // Use current state as the starting point
        var used = self.used
        var upperTotal = self.upperTotal
        var yahtzeeScored = self.yahtzeeScored
        
        // Mark the new option as being used
        used.set(option)
        
        // If it's an upper option, update the upper total.
        if option.isUpper {
            var upperPoints = points
            // Don't include Yahtzee bonus in upper total.
            if upperPoints >= Points.yahtzeeBonus {
                upperPoints -= Points.yahtzeeBonus
            }
            // Cap the total at the number of points needed to earn the bonus.
            upperTotal = min(Points.toEarnUpperBonus, upperTotal + upperPoints)
        } else if option == .yahtzee && points > 0 {
            // Non-zero Yahtzee, so mark Yahtzee as scored.
            yahtzeeScored = true
        }
        
        return TurnState(used: used, upperTotal: upperTotal, yahtzeeScored: yahtzeeScored)
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
                    yahtzeeScored: false
                ))
                if used.isSet(.yahtzee) {
                    // If the Yahtzee option is in use, the player may have scored a Yahtzee, but
                    // it isn't guaranteed, so we add two TurnStates one without and one with.
                    result.append(TurnState(
                        used: used,
                        upperTotal: upperTotal,
                        yahtzeeScored: true
                    ))
                }
            }
        }
        return result
    }
    
    static let upperTotals = UpperTotals()
}
