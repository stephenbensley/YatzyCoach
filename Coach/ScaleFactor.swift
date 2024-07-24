//
// Copyright 2024 Stephen E. Bensley
//
// This file is licensed under the MIT License. You may obtain a copy of the
// license at https://github.com/stephenbensley/YahtzeeCoach/blob/main/LICENSE.
//

import SwiftUI

extension CGSize {
    var aspectRatio: CGFloat {
        return height / width
    }
}

private struct ScaleFactorKey: EnvironmentKey {
    static let defaultValue = 1.0
}

extension EnvironmentValues {
    var scaleFactor: Double {
        get { self[ScaleFactorKey.self] }
        set { self[ScaleFactorKey.self] = newValue }
    }
}

extension View {
    func scaleFactor(_ value: Double) -> some View {
        environment(\.scaleFactor, value)
    }
    
    func scaleView(design: CGSize, actual: CGSize) -> some View {
        var value: Double
        if actual.aspectRatio > design.aspectRatio {
            // View is skinnier that design, so width is bottleneck
            value = actual.width / design.width
        } else {
            // View is fatter, so height is bottleneck
            value = actual.height / design.height
        }
        return scaleFactor(value)
    }
}
