//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YatzyCoach/blob/main/LICENSE.
//

import SwiftUI
import UniformTypeIdentifiers

// FileDocument for the save solution
struct SolutionFile: FileDocument {
    var data = Data()
    
    init(configuration: ReadConfiguration) throws {
        if let newData = configuration.file.regularFileContents {
            data = newData
        }
    }
    
    // Implementation of FileDocument protocol follows:
    
    init(initialData: Data = Data()) {
        self.data = initialData
    }
    
    static var readableContentTypes = [UTType.json]
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: data)
    }
    
    static var writableContentTypes = [UTType.json]
}

struct ContentView: View {

    enum SolverState {
        case readyToSolve
        case solving
        case solutionReady
    }
    
    @State private var solverState: SolverState = .readyToSolve
    @State private var progress = 0.0
    @State private var task: Task<Void, Never>?
    @State private var expectedValue = 0.0
    @State private var solution: SolutionFile?
    @State private var showingExporter = false
    @State private var writeError = ""
    @State private var showingWriteError = false
    
    var body: some View {
        VStack {
            switch solverState {
            case .readyToSolve:
                ProgressView("Ready to solve", value: 0.0, total: 100.0)
                Button("Solve") {
                    solverState = .solving
                    progress = 0.0
                    task = Task {
                        let turnValues = await Solver.solve() { progress = Double($0) }
                        if Task.isCancelled {
                            solverState = .readyToSolve
                        } else {
                            expectedValue = turnValues.find(turnState: TurnState())
                            solution = SolutionFile(initialData: turnValues.encode())
                            solverState = .solutionReady
                        }
                    }
                }
            case .solving:
                ProgressView("Solving ...", value: progress, total: 100.0)
                Button("Cancel") {
                    task?.cancel()
                }
            case .solutionReady:
                ProgressView(
                    "Solution ready: expected value = \(expectedValue, specifier: "%.2f")",
                    value: 100.0,
                    total: 100.0
                )
                Button("Export") {
                    showingExporter = true
                }
            }
        }
        .fileExporter(
            isPresented: $showingExporter,
            document: solution,
            contentType: .json,
            defaultFilename: "YatzySolution.json"
            
        ) { result in
            switch result {
            case .success:
                solution = nil
                solverState = .readyToSolve
            case .failure(let error):
                writeError = error.localizedDescription
                showingWriteError = true
            }
        }
        .alert("Error Exporting File", isPresented: $showingWriteError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(writeError)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
