//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import SwiftUI

// Displays an info file.
struct InfoView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scaleFactor) private var scaleFactor: Double
    private let title: String
    private let contents: Text
    
    init(title: String) {
        self.title = title
        self.contents = Self.load(fromResource: title)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                contents
            }
            .padding(20.0)
            .navigationTitle(title)
            .toolbar {
                Button("Done") { dismiss() }
            }
        }
    }
    
    static func load(fromResource name: String) -> Text {
        guard let path = Bundle.main.path(forResource: name, ofType: "md") else {
            fatalError("Failed to locate \(name).md in bundle.")
        }
        
        guard let contents = try? String(contentsOfFile: path) else {
            fatalError("Failed to load \(name).md from bundle.")
        }
        
        // Since Swift doesn't support images in markdown, we implement our own logic where
        // we replace |systemName| with the corresponding SF Symbol.
        return contents.split(separator: "|").enumerated().reduce(Text("")) { result, token in
            if token.offset % 2 == 0 {
                // Even tokens are markdown
                result + Text(LocalizedStringKey(String(token.element)))
            } else {
                // Odd tokens are SF Symbol names
                result + Text(Image(systemName: "\(token.element)"))
            }
        }
    }
}

#Preview {
    struct InfoPreview: View {
        var body: some View {
            InfoView(title: "About")
        }
    }
    
    return InfoPreview()
}
