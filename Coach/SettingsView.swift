//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable private var appModel: Coach
    
    init(appModel: Coach) {
        self.appModel = appModel
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Toggle("Enable coach", isOn: $appModel.enabled)
                Text("Feedback threshold: \(appModel.feedbackThreshold, specifier: "%.1f") points")
                    .listRowSeparator(.hidden, edges: [.bottom])
                Slider(value: $appModel.feedbackThreshold, in: 0.1...5.0, step: 0.1)
                    .disabled(!appModel.enabled)
                Toggle("Always show best move", isOn: $appModel.alwaysShowBest)
                    .disabled(!appModel.enabled)
            }
            .navigationTitle("Settings")
            .toolbar {
                Button("Done") { dismiss() }
            }
            
        }
    }
}

#Preview {
    struct SettingsPreview: View {
        @State private var appModel = Coach.create()
        
        var body: some View {
            SettingsView(appModel: appModel)
        }
    }
    
    return SettingsPreview()
}
