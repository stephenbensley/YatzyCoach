//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Text("Hello, World!")
                .navigationTitle("Help")
                .toolbar {
                    Button("Done") { dismiss() }
                }
            
        }
    }
}

#Preview {
    struct HelpPreview: View {
        var body: some View {
            HelpView()
        }
    }
    
    return HelpPreview()
}
