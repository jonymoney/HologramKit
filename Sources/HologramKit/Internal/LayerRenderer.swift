import SwiftUI

struct LayerRenderer {
    let cardSize: CGSize
    let cornerRadius: CGFloat
    let isExploded: Bool

    @ViewBuilder
    func render(
        layer: HologramLayer,
        tiltR: Float,
        tiltP: Float,
        time: Float
    ) -> some View {
        switch layer.kind {
        case .base(let color):
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(color)
                .applyBlendMode(layer.layerBlendMode, isExploded: isExploded)

        case .image(let image):
            Color.clear
                .frame(width: cardSize.width, height: cardSize.height)
                .overlay {
                    image
                        .resizable()
                        .scaledToFill()
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                .opacity(layer.layerOpacity)
                .applyBlendMode(layer.layerBlendMode, isExploded: isExploded)

        case .content(let view):
            view
                .applyBlendMode(layer.layerBlendMode, isExploded: isExploded)

        case .holographicFoil(let baseColor):
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(baseColor)
                .colorEffect(
                    HologramShaderLibrary.holographicFoil(
                        .float2(Float(cardSize.width), Float(cardSize.height)),
                        .float2(tiltR, tiltP),
                        .float(layer.foilConfig.intensity),
                        .float(layer.foilConfig.scale),
                        .float(layer.foilConfig.speed),
                        .float(layer.foilConfig.saturation),
                        .float(Float(layer.foilConfig.pattern.rawValue))
                    )
                )
                .applyBlendMode(layer.layerBlendMode ?? .overlay, isExploded: isExploded, defaultBlend: .overlay)

        case .specularHighlight:
            ZStack {
                if isExploded {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color(white: 0.1))
                }
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.black)
                    .colorEffect(
                        HologramShaderLibrary.specularHighlight(
                            .float2(Float(cardSize.width), Float(cardSize.height)),
                            .float2(tiltR, tiltP),
                            .float(layer.specularConfig.intensity),
                            .float(layer.specularConfig.size),
                            .float(layer.specularConfig.falloff),
                            .color(layer.specularConfig.color)
                        )
                    )
                    .blendMode(.screen)
            }
            .applyBlendMode(layer.layerBlendMode, isExploded: isExploded)

        case .sparkle:
            ZStack {
                if isExploded {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color(white: 0.1))
                }
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.black)
                    .colorEffect(
                        HologramShaderLibrary.sparkle(
                            .float2(Float(cardSize.width), Float(cardSize.height)),
                            .float2(tiltR, tiltP),
                            .float(time),
                            .float(layer.sparkleConfig.density),
                            .float(layer.sparkleConfig.speed),
                            .float(layer.sparkleConfig.size)
                        )
                    )
                    .blendMode(.plusLighter)
            }
            .applyBlendMode(layer.layerBlendMode, isExploded: isExploded)

        case .brushedMetal(let baseColor):
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(baseColor)
                .colorEffect(
                    HologramShaderLibrary.brushedMetal(
                        .float2(Float(cardSize.width), Float(cardSize.height)),
                        .float2(tiltR, tiltP),
                        .float(layer.brushedMetalConfig.grainScale),
                        .float(layer.brushedMetalConfig.reflectivity),
                        .float(layer.brushedMetalConfig.brushAngle)
                    )
                )
                .applyBlendMode(layer.layerBlendMode, isExploded: isExploded)

        case .anisotropicLight:
            ZStack {
                if isExploded {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(Color(white: 0.1))
                }
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.black)
                    .colorEffect(
                        HologramShaderLibrary.anisotropicLight(
                            .float2(Float(cardSize.width), Float(cardSize.height)),
                            .float2(tiltR, tiltP),
                            .float(layer.anisotropicLightConfig.intensity),
                            .float(layer.anisotropicLightConfig.size),
                            .float(layer.anisotropicLightConfig.stretch),
                            .float(layer.anisotropicLightConfig.brushAngle),
                            .float(layer.anisotropicLightConfig.softness),
                            .color(layer.anisotropicLightConfig.color)
                        )
                    )
                    .blendMode(.screen)
            }
            .applyBlendMode(layer.layerBlendMode, isExploded: isExploded)
        }
    }
}

private extension View {
    @ViewBuilder
    func applyBlendMode(_ mode: BlendMode?, isExploded: Bool, defaultBlend: BlendMode? = nil) -> some View {
        if let mode {
            self.blendMode(isExploded ? .normal : mode)
        } else if let defaultBlend {
            self.blendMode(isExploded ? .normal : defaultBlend)
        } else {
            self
        }
    }
}
