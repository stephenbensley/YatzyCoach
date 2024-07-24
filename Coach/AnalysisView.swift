//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import SwiftUI

// Displays a detailed analysis of the current game state.
struct AnalysisView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scaleFactor) private var scaleFactor: Double
    
    var body: some View {
        NavigationStack {
            Text("Hello, World!")
                .navigationTitle("Analysis")
                .toolbar {
                    Button("Done") { dismiss() }
                }
        }
    }
}

#Preview {
    struct AnalysisPreview: View {
        var body: some View {
            AnalysisView()
        }
    }
    
    return AnalysisPreview()
}
