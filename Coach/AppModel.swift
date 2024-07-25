//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import SwiftUI

// The Coach class is our app model. This file provides some additional functionality to make it
// easier to use the Coach as the app model.

// Allow GameModel to be saved and restored from UserDefaults
extension GameModel {
    static func create() -> GameModel {
        guard let turnValues = TurnValues(
            forResource: "yahtzeeSolution",
            withExtension: "json"
        ) else {
            // There's no possible recovery if the app bundle is corrupt.
            fatalError("Unable to load solution file.")
        }
        
        let diceStore = DiceStore()
        
        if let data = UserDefaults.standard.data(forKey: "GameModel"),
           let model = GameModel(turnValues: turnValues, diceStore: diceStore, data: data) {
            return model
        }
        
        // If we can't restore the game model, just create a new default one.
        return GameModel(turnValues: turnValues, diceStore: diceStore)
    }
    
    func save() {
        UserDefaults.standard.set(encode(), forKey: "GameModel")
    }
}

// Allow Action to be saved and restored from UserDefaults
extension Action {
    static func create() -> Action {
        if let data = UserDefaults.standard.data(forKey: "Action"),
           let action = try? JSONDecoder().decode(Action.self, from: data) {
            return action
        }
        
        // If we can't restore the action, create a default one.
        return .rollDice(DiceSelection())
    }
    
    func save() {
        let data = try! JSONEncoder().encode(self)
        UserDefaults.standard.set(data, forKey: "Action")
    }
}

// Allow Coach to be saved and restored from UserDefaults
extension Coach {
    static func create() -> Coach {
        let coach = Coach(gameModel: GameModel.create())
        coach.action = Action.create()
        let defaults = UserDefaults.standard
        if let enabled = defaults.value(forKey: "Enabled") as? Bool {
            coach.enabled = enabled
        }
        if let feedbackThreshold = defaults.value(forKey: "FeedbackThreshold") as? Double {
            coach.feedbackThreshold = feedbackThreshold
        }
        if let alwaysShowBest = defaults.value(forKey: "AlwaysShowBest") as? Bool {
            coach.alwaysShowBest = alwaysShowBest
        }
        return coach
    }
    
    func save() {
        gameModel.save()
        action.save()
        let defaults = UserDefaults.standard
        defaults.set(enabled, forKey: "Enabled")
        defaults.set(feedbackThreshold, forKey: "FeedbackThreshold")
        defaults.set(alwaysShowBest, forKey: "AlwaysShowBest")
    }
}

// Allow app model to be passed through the environment

private struct AppModelKey: EnvironmentKey {
    static let defaultValue = Coach.create()
}

extension EnvironmentValues {
    var appModel: Coach {
        get { self[AppModelKey.self] }
        set { self[AppModelKey.self] = newValue }
    }
}

extension View {
    func appModel(_ value: Coach) -> some View {
        environment(\.appModel, value)
    }
}
