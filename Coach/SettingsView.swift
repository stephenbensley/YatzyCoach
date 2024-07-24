//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.appModel) private var appModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        @Bindable var appModel = appModel
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
        var body: some View {
            SettingsView()
        }
    }
    
    return SettingsPreview()
}
