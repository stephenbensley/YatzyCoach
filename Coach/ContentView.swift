//
//  ContentView.swift
//  Coach
//
//  Created by Stephen Bensley on 7/21/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var model = GameModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Palette.background
                    .ignoresSafeArea()
                GeometryReader { proxy in
                    GameView(model: model, size: proxy.size)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .background(Palette.background)
                        .toolbar {
                            Button {
                                
                            } label: {
                                Image(systemName: "arrow.clockwise.circle")
                            }
                            Button {
                                
                            } label: {
                                Image(systemName: "info.circle")
                            }
                            Button {
                                
                            } label: {
                                Image(systemName: "questionmark.circle")
                            }
                            Button {
                                
                            } label: {
                                Image(systemName: "gearshape")
                            }
                        }
                        .accentColor(Palette.toolbar)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
