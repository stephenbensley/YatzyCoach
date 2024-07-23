//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import SwiftUI

// Main app view
struct ContentView: View {
    // Used to trigger saving state when app goes inactive.
    @Environment(\.scenePhase) private var scenePhase
    
    // Persistent app model.
    @State private var appModel = Coach.create()
    
    // These control the various alerts and sheets activated from the toolbar.
    @State private var confirmNewGame = false
    @State private var showAbout = false
    @State private var showHelp = false
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Palette.background
                    .ignoresSafeArea()
                GeometryReader { proxy in
                    GameView(appModel: appModel)
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .background(Palette.background)
                        .toolbar {
                            Button {
                                confirmNewGame = true
                            } label: {
                                Image(systemName: "arrow.clockwise.circle")
                            }
                            Button {
                                showAbout = true
                            } label: {
                                Image(systemName: "info.circle")
                            }
                            Button {
                                showHelp = true
                            } label: {
                                Image(systemName: "questionmark.circle")
                            }
                            Button {
                                showSettings = true
                            } label: {
                                Image(systemName: "gearshape")
                            }
                        }
                        .accentColor(Palette.toolbar)
                        .alert("Start a new game?", isPresented: $confirmNewGame) {
                            Button("New Game") { appModel.newGame() }
                            Button("Cancel") { }
                        }
                        .sheet(isPresented: $showAbout) {
                            AboutView()
                        }
                        .sheet(isPresented: $showHelp) {
                            HelpView()
                        }
                        .sheet(isPresented: $showSettings) {
                            SettingsView(appModel: appModel)
                        }
                        .onChange(of: scenePhase) { _, phase in
                            if phase == .inactive { appModel.save() }
                        }
                        .scaleView(design: GameView.designSize, actual: proxy.size)
                }
            }
        }
    }
}

#Preview {
    struct ContentPreview: View {
        var body: some View {
            ContentView()
        }
    }
    
    return ContentPreview()
}
