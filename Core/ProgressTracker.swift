//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YatzyCoach/blob/main/LICENSE.
//

import Foundation

// Callback to report progress. The Int parameter is in range 0...100.
typealias ReportProgress = (Int) -> Void

// Tracks progress towards a count and reports progress every 1%.
actor ProgressTracker {
    private let totalCount: Int
    private let reportProgress: ReportProgress
    private var count = 0
    private var progress = 0
    
    func increment() {
        assert(count < totalCount)
        count += 1
        let newProgress = (count * 100) / totalCount
        if newProgress > progress {
            progress = newProgress
            reportProgress(newProgress)
        }
    }
    
    init(totalCount: Int, onUpdate: @escaping ReportProgress) {
        self.totalCount = totalCount
        self.reportProgress = onUpdate
    }
}
