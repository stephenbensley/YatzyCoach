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
    
    // These control the various alerts and sheets activated from the toolbar menu.
    @State private var confirmNewGame = false
    @State private var showAbout = false
    @State private var showAnalysis = false
    @State private var showHelp = false
    @State private var showSettings = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Palette.background
                    .ignoresSafeArea()
                GeometryReader { proxy in
                    GameView()
                        .frame(width: proxy.size.width, height: proxy.size.height)
                        .background(Palette.background)
                        .toolbar {
                            Menu {
                                Button {
                                    confirmNewGame = true
                                } label: {
                                    Label("New Game", systemImage: "arrow.clockwise.circle")
                                }
                                Button {
                                    showAnalysis = true
                                } label: {
                                    Label("Show Analysis", systemImage: "list.bullet.circle")
                                }
                                Button {
                                    showAbout = true
                                } label: {
                                    Label("About", systemImage: "info.circle")
                                }
                                Button {
                                    showHelp = true
                                } label: {
                                    Label("Help", systemImage: "questionmark.circle")
                                }
                                Button {
                                    showSettings = true
                                } label: {
                                    Label("Settings", systemImage: "gearshape")
                                }
                            } label: {
                                Label("Menu", systemImage: "ellipsis.circle")
                                    .foregroundStyle(Palette.toolbar, Palette.toolbar)
                            }
                        }
                        .alert("Start a new game?", isPresented: $confirmNewGame) {
                            Button("New Game") { appModel.newGame() }
                            Button("Cancel") { }
                        }
                        .sheet(isPresented: $showAbout) { InfoView(title: "About") }
                        .sheet(isPresented: $showAnalysis) { AnalysisView() }
                        .sheet(isPresented: $showHelp) { InfoView(title: "Help") }
                        .sheet(isPresented: $showSettings) { SettingsView() }
                        .onChange(of: scenePhase) { _, phase in
                            if phase == .inactive { appModel.save() }
                        }
                        .scaleView(design: GameView.designSize, actual: proxy.size)
                        .appModel(appModel)
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
