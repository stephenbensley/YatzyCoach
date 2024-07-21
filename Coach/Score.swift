//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import SwiftUI

struct Score: View {
    private let title: LocalizedStringKey
    private let points: Int?
    private let selected: Bool
    private let onTap: () -> Void
    static let columnWidths = [0.7, 0.3]
    private static let paddingLength = 10.0
    
    private var pointsString: String { points?.description ?? "" }
    
    private func fontSize(_ size: CGSize) -> Double { size.width * 0.1 }
    
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
        GeometryReader { geo in
            HStack(spacing: 0) {
                Text(title)
                    .font(.custom(Fonts.scoreCard, size: fontSize(geo.size)))
                    .foregroundStyle(Palette.scoreCard)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .padding(.horizontal, Self.paddingLength)
                    .frame(
                        width: geo.size.width * Self.columnWidths[0],
                        height: geo.size.height,
                        alignment: .leading
                    )
                Text(pointsString)
                    .font(.custom(Fonts.score, size: fontSize(geo.size)))
                    .foregroundStyle(Palette.score)
                    .padding(.horizontal, Self.paddingLength)
                    .frame(
                        width: geo.size.width * Self.columnWidths[1],
                        height: geo.size.height,
                        alignment: .trailing
                    )
                    .border(
                        selected ? Palette.selected : .clear,
                        width: Lengths.selectionWidth
                    )
            }
            .contentShape(Rectangle())
            .onTapGesture { onTap() }
        }
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
            .frame(width: 200, height: 100)
        }
    }
    return ScorePreview()
}

