//
//  ContentView.swift
//  Test
//
//  Created by Stephen Bensley on 7/12/24.
//

import SwiftUI

struct ContentView: View {
    @State var progress = 0.0
    
    var body: some View {
        VStack {
            ProgressView("Solving", value: progress, total: 100.0)
            Button("Solve") {
                Task {
                    await Solver(reportProgress: { progress = Double($0)}).solve()
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
