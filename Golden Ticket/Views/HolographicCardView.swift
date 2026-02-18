import SwiftUI

struct HolographicCardView: View {
    var config: CardConfiguration
    var motionManager: MotionManager
    var isExploded: Bool

    @State private var startDate = Date()

    // Z-spacing between layers in the exploded 3D view
    private let zSpacing: CGFloat = 140

    var body: some View {
        TimelineView(.animation) { context in
            let time = Float(context.date.timeIntervalSince(startDate))
            let tiltR = motionManager.roll
            let tiltP = motionManager.pitch
            let p: Float = isExploded ? 0 : tiltP
            let r: Float = isExploded ? 0 : tiltR

            // Layer index bookkeeping for Z-depth
            let imgCount = CGFloat(config.imageLayers.count)
            let totalPositions = 5 + imgCount
            let center = (totalPositions - 1) / 2

            ZStack {
                // Layer 1: Base
                if config.showBase {
                    RoundedRectangle(cornerRadius: config.cornerRadius)
                        .fill(config.cardBaseColor)
                        .shadow(color: .black.opacity(isExploded ? 0.3 : 0), radius: 8, x: 0, y: 4)
                        .overlay(alignment: .topLeading) { layerLabel("Base") }
                        .offset(parallaxOffset(r: r, p: p, factor: config.baseParallaxFactor))
                        .explodeDepth(isExploded: isExploded, layerIndex: 0, center: center, zSpacing: zSpacing)
                }

                // Image Layers (between base and content)
                ForEach(Array(config.imageLayers.enumerated()), id: \.element.id) { index, layer in
                    if layer.isVisible {
                        Color.clear
                            .frame(width: config.cardWidth, height: config.cardHeight)
                            .overlay {
                                Image(layer.assetName)
                                    .resizable()
                                    .scaledToFill()
                            }
                            .clipShape(RoundedRectangle(cornerRadius: config.cornerRadius))
                            .opacity(layer.opacity)
                            .shadow(color: .black.opacity(isExploded ? 0.3 : 0), radius: 8, x: 0, y: 4)
                            .overlay(alignment: .topLeading) { layerLabel(layer.name) }
                            .offset(parallaxOffset(r: r, p: p, factor: layer.parallaxFactor))
                            .explodeDepth(isExploded: isExploded, layerIndex: CGFloat(index) + 1, center: center, zSpacing: zSpacing)
                    }
                }

                // Content
                if config.showContent {
                    contentLayer
                        .shadow(color: .black.opacity(isExploded ? 0.3 : 0), radius: 8, x: 0, y: 4)
                        .overlay(alignment: .topLeading) { layerLabel("Content") }
                        .offset(parallaxOffset(r: r, p: p, factor: config.contentParallaxFactor))
                        .explodeDepth(isExploded: isExploded, layerIndex: 1 + imgCount, center: center, zSpacing: zSpacing)
                }

                // Holographic Foil
                if config.showHolographic {
                    RoundedRectangle(cornerRadius: config.cornerRadius)
                        .fill(config.cardBaseColor)
                        .colorEffect(
                            ShaderLibrary.holographicFoil(
                                .float2(Float(config.cardWidth), Float(config.cardHeight)),
                                .float2(tiltR, tiltP),
                                .float(config.holoIntensity),
                                .float(config.holoScale),
                                .float(config.holoSpeed),
                                .float(config.holoSaturation),
                                .float(Float(config.holoPattern.rawValue))
                            )
                        )
                        .blendMode(isExploded ? .normal : .overlay)
                        .shadow(color: .black.opacity(isExploded ? 0.3 : 0), radius: 8, x: 0, y: 4)
                        .overlay(alignment: .topLeading) { layerLabel("Holo Foil") }
                        .offset(parallaxOffset(r: r, p: p, factor: config.holoParallaxFactor))
                        .explodeDepth(isExploded: isExploded, layerIndex: 2 + imgCount, center: center, zSpacing: zSpacing)
                }

                // Specular Highlight
                if config.showSpecular {
                    ZStack {
                        if isExploded {
                            RoundedRectangle(cornerRadius: config.cornerRadius)
                                .fill(Color(white: 0.1))
                        }
                        RoundedRectangle(cornerRadius: config.cornerRadius)
                            .fill(.black)
                            .colorEffect(
                                ShaderLibrary.specularHighlight(
                                    .float2(Float(config.cardWidth), Float(config.cardHeight)),
                                    .float2(tiltR, tiltP),
                                    .float(config.specularIntensity),
                                    .float(config.specularSize),
                                    .float(config.specularFalloff),
                                    .color(config.specularColor)
                                )
                            )
                            .blendMode(.screen)
                    }
                    .shadow(color: .black.opacity(isExploded ? 0.3 : 0), radius: 8, x: 0, y: 4)
                    .overlay(alignment: .topLeading) { layerLabel("Specular") }
                    .offset(parallaxOffset(r: r, p: p, factor: config.specularParallaxFactor))
                    .explodeDepth(isExploded: isExploded, layerIndex: 3 + imgCount, center: center, zSpacing: zSpacing)
                }

                // Sparkle
                if config.showSparkle {
                    ZStack {
                        if isExploded {
                            RoundedRectangle(cornerRadius: config.cornerRadius)
                                .fill(Color(white: 0.1))
                        }
                        RoundedRectangle(cornerRadius: config.cornerRadius)
                            .fill(.black)
                            .colorEffect(
                                ShaderLibrary.sparkle(
                                    .float2(Float(config.cardWidth), Float(config.cardHeight)),
                                    .float2(tiltR, tiltP),
                                    .float(time),
                                    .float(config.sparkleDensity),
                                    .float(config.sparkleSpeed),
                                    .float(config.sparkleSize)
                                )
                            )
                            .blendMode(.plusLighter)
                    }
                    .shadow(color: .black.opacity(isExploded ? 0.3 : 0), radius: 8, x: 0, y: 4)
                    .overlay(alignment: .topLeading) { layerLabel("Sparkle") }
                    .offset(parallaxOffset(r: r, p: p, factor: config.sparkleParallaxFactor))
                    .explodeDepth(isExploded: isExploded, layerIndex: 4 + imgCount, center: center, zSpacing: zSpacing)
                }
            }
            .frame(width: config.cardWidth, height: config.cardHeight)
            .scaleEffect(isExploded ? 0.6 : 1.0)
            // ZStack-level rotation only when NOT exploded (per-layer handles exploded)
            .rotation3DEffect(
                .degrees(isExploded ? 0 : Double(-p) * config.tiltIntensity),
                axis: (x: 1, y: 0, z: 0),
                perspective: 0.4
            )
            .rotation3DEffect(
                .degrees(isExploded ? 0 : -Double(r) * config.tiltIntensity),
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
    }

    @ViewBuilder
    private func layerLabel(_ text: String) -> some View {
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

    private var contentLayer: some View {
        VStack(spacing: 8) {
            Text("Mount Fuji")
                .font(.system(size: 30, weight: .bold))
            Text("JAPAN 2026")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .tracking(4)
            Spacer()
        }
        .padding(.top)
        .foregroundStyle(.white.opacity(0.9))
    }

    private func parallaxOffset(r: Float, p: Float, factor: Double) -> CGSize {
        CGSize(
            width: CGFloat(r) * config.parallaxIntensity * factor,
            height: CGFloat(p) * config.parallaxIntensity * factor
        )
    }
}

// MARK: - Explode 3D Depth

private extension View {
    /// Places each layer at a different Z-depth using `anchorZ`, then rotates
    /// around a compound axis to view from the bottom-right.
    /// A single rotation3DEffect keeps the Z-depth coherent — no flattening.
    func explodeDepth(
        isExploded: Bool,
        layerIndex: CGFloat,
        center: CGFloat,
        zSpacing: CGFloat
    ) -> some View {
        let z = (layerIndex - center) * zSpacing
        // Compound axis ≈ 55° X tilt + 20° Y turn
        // Axis (1, -0.36, 0) at 58° produces this combination
        return self
            .rotation3DEffect(
                .degrees(isExploded ? 58 : 0),
                axis: (x: 1, y: -0.36, z: 0),
                anchor: .center,
                anchorZ: isExploded ? z : 0,
                perspective: 0.15
            )
    }
}
