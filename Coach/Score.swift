//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import SwiftUI

struct Score: View {
    @Environment(\.scaleFactor) private var scaleFactor: Double
    private let title: LocalizedStringKey
    private let points: Int?
    private let selected: Bool
    private let onTap: () -> Void
    
    private static let rowHeight = 45.0
    static let columnWidths = [117.0, 50.0]
    private static let paddingLength = 6.0
    
    private var pointsString: String { points?.description ?? "" }
    
    init(
        _ title: LocalizedStringKey,
        points: Int? = nil,
        selected: Bool = false,
        onTap: @escaping () -> Void = { }
    ) {
        self.title = title
        self.points = points
        self.selected = selected
        self.onTap = onTap
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .font(.custom(Fonts.scoreCard, size: 18.0 * scaleFactor))
                .foregroundStyle(Palette.scoreCard)
                .lineLimit(1)
                .minimumScaleFactor(0.1)
                .padding(.horizontal, Self.paddingLength * scaleFactor)
                .frame(
                    width: Self.columnWidths[0] * scaleFactor,
                    height: Self.rowHeight * scaleFactor,
                    alignment: .leading
                )
            Text(pointsString)
                .font(.custom(Fonts.score, size: 25.0 * scaleFactor))
                .baselineOffset(3.0 * scaleFactor)
                .foregroundStyle(Palette.score)
                .minimumScaleFactor(0.1)
                .padding(.horizontal, Self.paddingLength * scaleFactor)
                .frame(
                    width: Self.columnWidths[1] * scaleFactor,
                    height: Self.rowHeight * scaleFactor,
                    alignment: .trailing
                )
                .border(
                    selected ? Palette.selected : .clear,
                    width: Lengths.selectionWidth * scaleFactor
                )
        }
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
        
    }
}

#Preview {
    struct ScorePreview: View {
        @State private var selected = false
        
        var body: some View {
            VStack(spacing: 0) {
                Score("Sm. Straight", points: 30, selected: selected, onTap: { selected.toggle() })
                Score("Lg. Straight", points: nil, selected: false)
            }
            .background(
                GridLines(rowCount: 2, columnWidths: Score.columnWidths)
                    .stroke()
            )
        }
    }
    
    return ScorePreview()
}

