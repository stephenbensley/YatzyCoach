//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import Foundation
import XCTest

class GameModelTests: XCTestCase {
    
    func testGamePlay() async throws {
        guard let turnValues = TurnValues(fileURLWithPath: "./yahtzeeSolution.json") else {
            XCTFail()
            return
        }
        
        // Let the test run for 15 seconds.
        let deadline = DispatchTime.now().uptimeNanoseconds + (15 * 1_000_000_000)
        var total = 0
        var count = 0

        await withTaskGroup(of: (total: Int, count: Int).self) { group in
            for _ in 0..<ProcessInfo.processInfo.activeProcessorCount {
                group.addTask(priority: .low) {
                    let diceStore = DiceStore()
                    var total = 0
                    var count = 0
                    while DispatchTime.now().uptimeNanoseconds < deadline {
                        let model = GameModel(turnValues: turnValues, diceStore: diceStore)
                        repeat {
                            let action = model.bestAction
                            model.takeAction(action: action)
                        } while !model.gameOver
                        
                        total += model.derivedPoints(.grandTotal)!
                        count += 1
                    }
                    return (total, count)
                }
                
                for await result in group {
                    total += result.total
                    count += result.count
                }
            }
        }
        
        // From "An Optimal Strategy for Yahtzee" by James Glenn.
        let mean = 254.59
        let stdDev = 59.64 / sqrt(Double(count))
        
        let avgScore = Double(total)/Double(count)
        XCTAssertEqual(avgScore, mean, accuracy: 3.0 * stdDev)
    }
    
    func testEncode() throws {
        // Create a GameModel
        guard let turnValues = TurnValues(fileURLWithPath: "./yahtzeeSolution.json") else {
            XCTFail()
            return
        }
        let diceStore = DiceStore()
        let model = GameModel(turnValues: turnValues, diceStore: diceStore)
        
        // Make a move
        model.takeAction(action: model.bestAction)
        
        // Save some state
        let beforeRollsLeft = model.rollsLeft
        let beforePlayerDice = model.playerDice
        
        // Encode/decode the model
        let data = model.encode()
        guard let restoredModel = GameModel(
            turnValues: turnValues,
            diceStore: diceStore,
            data: data
        ) else {
            XCTFail()
            return
        }
        
        // Make sure the state was preserved.
        XCTAssert(beforeRollsLeft == restoredModel.rollsLeft)
        XCTAssert(beforePlayerDice == restoredModel.playerDice)
    }
}

