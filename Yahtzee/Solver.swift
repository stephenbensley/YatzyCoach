//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import Foundation

// Solves all turn states for the game of Yahtzee.
final class Solver {
    private let tracker: ProgressTracker
    private let workerCount: Int
    private let diceStores: [DiceStore]
    private let turnValues = TurnValues()

    // Main entry point to solve the game of Yahtzee.
    private func solve() async {
        // Retrograde solution starting from the end and working back to the beginning.
        for turn in stride(from: ScoringOption.allCases.count, through: 0, by: -1) {
            await solveTurn(turn)
            if Task.isCancelled {
                break
            }
        }
    }
    
    private func solveTurn(_ turn: Int) async {
        let turnStates = TurnState.all(forTurn: turn)
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<workerCount {
                group.addTask(priority: .low) {
                    await self.solveTurnStates(workerIndex: i, turnStates: turnStates)
                }
            }
            await group.waitForAll()
        }
    }
    
    private func solveTurnStates(workerIndex: Int, turnStates: [TurnState]) async {
        // Each worker uses there own DiceStore to avoid ARC thrashing.
        let diceStore = diceStores[workerIndex]
        // Since each worker starts from a different index, they won't collide.
        for i in stride(from: workerIndex, to: turnStates.count, by: workerCount) {
            let turnState = turnStates[i]
            let analyzer = TurnAnalyzer(
                diceStore: diceStore,
                turnValues: turnValues,
                turnState: turnState
            )
            let value = analyzer.evaluate()
            turnValues.insert(turnState: turnState, value: value)
            await tracker.increment()
            if Task.isCancelled {
                break;
            }
        }
    }
    
    private init(reportProgress: @escaping ReportProgress) {
        self.tracker = ProgressTracker(totalCount: TurnState.stateCount, onUpdate: reportProgress)
        self.workerCount = ProcessInfo.processInfo.activeProcessorCount
        // Create a separate DiceStore for each worker. Retaining and releasing the same object
        // concurrently from multiple threads degrades rapidly as the number of threads increases
        // due to repeatedly evicting the cache line containing the refcount from peer CPU caches.
        self.diceStores = (0..<workerCount).map( { _ in DiceStore() })
    }
    
    static func solve(reportProgress: @escaping ReportProgress) async -> TurnValues {
        let solver = Solver(reportProgress: reportProgress)
        await solver.solve()
        return solver.turnValues
    }
}
