//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import Foundation
import SwiftUI

struct GridLines: Shape {
    var rowCount: Int
    var columnWidths: [Double]
    var totalWidth: Double { columnWidths.reduce(0.0, +) }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // Draw outer border
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))

        // Draw row dividers
        let rowHeight = rect.height / Double(rowCount)
        for i in 1..<rowCount {
            let y = rect.minY + Double(i) * rowHeight
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
        }

        // Draw columns dividers
        let columnWidth = rect.width / totalWidth
        for i in 1..<columnWidths.count {
            let x = rect.minY + Double(i) * columnWidth * columnWidths[i - 1]
            path.move(to: CGPoint(x: x, y: rect.minY))
            path.addLine(to: CGPoint(x: x, y: rect.maxY))
        }

        return path
    }
}


