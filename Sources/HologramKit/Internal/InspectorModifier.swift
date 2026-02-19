import SwiftUI

extension View {
    /// Places each layer at a different Z-depth using `anchorZ`, then rotates
    /// around a compound axis to view from the bottom-right.
    func explodeDepth(
        isExploded: Bool,
        layerIndex: CGFloat,
        center: CGFloat,
        zSpacing: CGFloat
    ) -> some View {
        let z = (layerIndex - center) * zSpacing
        return self
            .rotation3DEffect(
                .degrees(isExploded ? 58 : 0),
                axis: (x: 1, y: -0.36, z: 0),
                anchor: .center,
                anchorZ: isExploded ? z : 0,
                perspective: 0.15
            )
    }

    @ViewBuilder
    func inspectorLabel(_ text: String, isExploded: Bool) -> some View {
        self.overlay(alignment: .topLeading) {
            if isExploded {
                Text(text)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.ultraThinMaterial, in: Capsule())
                    .offset(x: 4, y: 4)
            }
        }
    }
}
