//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YatzyCoach/blob/main/LICENSE.
//

import SwiftUI

// Displays the Settings sheet.
struct SettingsView: View {
    @Environment(Coach.self) private var appModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        @Bindable var appModel = appModel
        NavigationStack {
            Form {
                Section {
                    Toggle("Enable coaching", isOn: $appModel.enabled)
                } footer: {
                    if appModel.enabled {
                        Text("Notify the player when a better move is available.")
                    } else {
                        Text("Do not provide coaching to the player.")
                    }
                }
                
                Section {
                    Text("""
                        Feedback threshold: \(appModel.feedbackThreshold, specifier: "%.1f") points
                        """)
                        .listRowSeparator(.hidden, edges: [.bottom])
                    Slider(value: $appModel.feedbackThreshold, in: 0.1...5.0, step: 0.1)
                        .disabled(!appModel.enabled)
                } footer: {
                    Text("""
                        Notify the player only if a better move would score at least this many \
                        additional points.
                        """)
                }
                
                Section {
                    Toggle("Always show best move", isOn: $appModel.alwaysShowBest)
                        .disabled(!appModel.enabled)
                } footer: {
                    if appModel.alwaysShowBest {
                        Text("Show the best move automatically.")
                    } else {
                        Text("Show the best move when the player requests it.")
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar { Button("Done") { dismiss() } }
        }
    }
}

#Preview {
    struct SettingsPreview: View {
        var body: some View {
            SettingsView()
                .environment(Coach.create())
        }
    }
    return SettingsPreview()
}
