import SwiftUI

/// A layered, motion-reactive holographic card view.
///
/// Build cards declaratively using ``HologramLayer`` factory methods:
/// ```swift
/// HologramCard {
///     HologramLayer.base(Color.gold)
///     HologramLayer.image(Image("sun"))
///         .parallax(0.1)
///     HologramLayer.holographicFoil()
///         .intensity(0.8)
///         .pattern(.diagonal)
///     HologramLayer.specularHighlight()
///         .size(0.35)
///     HologramLayer.sparkle()
///         .density(0.5)
/// }
/// .cardSize(width: 300, height: 420)
/// .hologramCornerRadius(20)
/// .tiltIntensity(15)
/// ```
public struct HologramCard: View {
    @Environment(\.hologramCardSize) private var cardSize
    @Environment(\.hologramCornerRadius) private var cornerRadius
    @Environment(\.hologramTiltIntensity) private var tiltIntensity
    @Environment(\.hologramParallaxIntensity) private var parallaxIntensity
    @Environment(\.hologramMotionSource) private var motionSource
    @Environment(\.hologramMotionSensitivity) private var motionSensitivity
    @Environment(\.hologramMotionSmoothing) private var motionSmoothing
    @Environment(\.hologramInspectorPresented) private var isExploded

    private let layers: [HologramLayer]

    @State private var motionManager = MotionManager()
    @State private var startDate = Date()

    private let zSpacing: CGFloat = 140

    public init(@HologramLayerBuilder content: () -> [HologramLayer]) {
        self.layers = content()
    }

    public var body: some View {
        TimelineView(.animation) { context in
            let time = Float(context.date.timeIntervalSince(startDate))
            let (tiltR, tiltP) = currentTilt
            let r: Float = isExploded ? 0 : tiltR
            let p: Float = isExploded ? 0 : tiltP

            let totalLayers = CGFloat(layers.count)
            let center = (totalLayers - 1) / 2

            let renderer = LayerRenderer(
                cardSize: cardSize,
                cornerRadius: cornerRadius,
                isExploded: isExploded,
                parallaxIntensity: parallaxIntensity
            )

            ZStack {
                ForEach(Array(layers.enumerated()), id: \.element.id) { index, layer in
                    renderer.render(layer: layer, tiltR: tiltR, tiltP: tiltP, time: time)
                        .shadow(color: .black.opacity(isExploded ? 0.3 : 0), radius: 8, x: 0, y: 4)
                        .inspectorLabel(layerName(for: layer), isExploded: isExploded)
                        .offset(parallaxOffset(r: r, p: p, factor: layer.parallaxFactor))
                        .explodeDepth(
                            isExploded: isExploded,
                            layerIndex: CGFloat(index),
                            center: center,
                            zSpacing: zSpacing
                        )
                }
            }
            .frame(width: cardSize.width, height: cardSize.height)
            .scaleEffect(isExploded ? 0.6 : 1.0)
            .rotation3DEffect(
                .degrees(isExploded ? 0 : Double(-p) * tiltIntensity),
                axis: (x: 1, y: 0, z: 0),
                perspective: 0.4
            )
            .rotation3DEffect(
                .degrees(isExploded ? 0 : -Double(r) * tiltIntensity),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.4
            )
            .shadow(
                color: .black.opacity(isExploded ? 0 : 0.3),
                radius: isExploded ? 0 : 20 + CGFloat(abs(p) + abs(r)) * 10,
                x: isExploded ? 0 : CGFloat(-r) * 10,
                y: isExploded ? 0 : CGFloat(p) * 10
            )
        }
        .onAppear {
            configureMotion()
            motionManager.start()
        }
        .onChange(of: motionSensitivity) { _, val in motionManager.sensitivity = val }
        .onChange(of: motionSmoothing) { _, val in motionManager.smoothingFactor = val }
    }

    // MARK: - Private

    private var currentTilt: (Float, Float) {
        switch motionSource {
        case .device:
            return (motionManager.roll, motionManager.pitch)
        case .manual(let pitch, let roll):
            return (roll, pitch)
        case .custom(let provider):
            return (provider.roll, provider.pitch)
        }
    }

    private func configureMotion() {
        motionManager.sensitivity = motionSensitivity
        motionManager.smoothingFactor = motionSmoothing
    }

    private func parallaxOffset(r: Float, p: Float, factor: Double) -> CGSize {
        CGSize(
            width: CGFloat(r) * parallaxIntensity * factor,
            height: CGFloat(p) * parallaxIntensity * factor
        )
    }

    private func layerName(for layer: HologramLayer) -> String {
        switch layer.kind {
        case .base: return "Base"
        case .image: return "Image"
        case .content: return "Content"
        case .holographicFoil: return "Holo Foil"
        case .specularHighlight: return "Specular"
        case .sparkle: return "Sparkle"
        case .brushedMetal: return "Brushed Metal"
        case .anisotropicLight: return "Aniso Light"
        case .plasticFoil: return "Plastic Foil"
        case .group(_, let name): return name ?? "Group"
        }
    }
}
