import SwiftUI

/// A single layer in a holographic card composition.
///
/// Create layers using static factory methods and configure them with chained modifiers:
/// ```swift
/// HologramLayer.holographicFoil()
///     .intensity(0.8)
///     .pattern(.diagonal)
///     .parallax(0.5)
/// ```
public struct HologramLayer: Identifiable {
    public let id = UUID()

    var kind: Kind
    var parallaxFactor: Double = 0
    var layerBlendMode: BlendMode? = nil
    var layerOpacity: Double = 1.0
    var foilConfig: HoloFoilConfig = HoloFoilConfig()
    var specularConfig: SpecularConfig = SpecularConfig()
    var sparkleConfig: SparkleConfig = SparkleConfig()
    var brushedMetalConfig: BrushedMetalConfig = BrushedMetalConfig()
    var anisotropicLightConfig: AnisotropicLightConfig = AnisotropicLightConfig()

    enum Kind {
        case base(Color)
        case image(Image)
        case content(AnyView)
        case holographicFoil(Color)
        case specularHighlight
        case sparkle
        case brushedMetal(Color)
        case anisotropicLight
    }

    // MARK: - Factory Methods

    /// A solid-color base layer.
    public static func base(_ color: Color) -> HologramLayer {
        HologramLayer(kind: .base(color))
    }

    /// An image layer that fills the card.
    public static func image(_ image: Image) -> HologramLayer {
        HologramLayer(kind: .image(image))
    }

    /// A custom SwiftUI content layer.
    public static func content<C: View>(@ViewBuilder _ content: () -> C) -> HologramLayer {
        HologramLayer(kind: .content(AnyView(content())))
    }

    /// A rainbow holographic foil effect driven by device tilt.
    public static func holographicFoil(_ baseColor: Color = Color(red: 0.85, green: 0.65, blue: 0.13)) -> HologramLayer {
        var layer = HologramLayer(kind: .holographicFoil(baseColor))
        layer.parallaxFactor = 0.5
        return layer
    }

    /// A tilt-tracking specular highlight.
    public static func specularHighlight() -> HologramLayer {
        var layer = HologramLayer(kind: .specularHighlight)
        layer.parallaxFactor = 0.8
        return layer
    }

    /// Animated glitter particles that catch light based on tilt angle.
    public static func sparkle() -> HologramLayer {
        var layer = HologramLayer(kind: .sparkle)
        layer.parallaxFactor = 1.0
        return layer
    }

    /// A brushed-metal surface with directional grain and anisotropic reflection.
    public static func brushedMetal(_ baseColor: Color = Color(white: 0.78)) -> HologramLayer {
        HologramLayer(kind: .brushedMetal(baseColor))
    }

    /// A tilt-tracking light reflection that stretches along a surface grain direction.
    /// Reusable on any card — pair with brushedMetal or use standalone.
    public static func anisotropicLight() -> HologramLayer {
        HologramLayer(kind: .anisotropicLight)
    }

    // MARK: - Universal Modifiers

    /// Parallax movement factor relative to device tilt. 0 = no movement, 1 = maximum.
    public func parallax(_ factor: Double) -> HologramLayer {
        var copy = self
        copy.parallaxFactor = factor
        return copy
    }

    /// Blend mode for compositing this layer.
    public func blendMode(_ mode: BlendMode) -> HologramLayer {
        var copy = self
        copy.layerBlendMode = mode
        return copy
    }

    /// Opacity of the layer.
    public func opacity(_ value: Double) -> HologramLayer {
        var copy = self
        copy.layerOpacity = value
        return copy
    }

    // MARK: - Holographic Foil Modifiers

    /// Holographic foil intensity (0...1). No-op on other layer types.
    public func intensity(_ value: Float) -> HologramLayer {
        var copy = self
        switch copy.kind {
        case .holographicFoil: copy.foilConfig.intensity = value
        case .specularHighlight: copy.specularConfig.intensity = value
        case .brushedMetal: copy.brushedMetalConfig.reflectivity = value
        case .anisotropicLight: copy.anisotropicLightConfig.intensity = value
        default: break
        }
        return copy
    }

    /// Scale of the holographic pattern or sparkle size. No-op on other layer types.
    public func scale(_ value: Float) -> HologramLayer {
        var copy = self
        switch copy.kind {
        case .holographicFoil: copy.foilConfig.scale = value
        case .sparkle: copy.sparkleConfig.size = value
        case .brushedMetal: copy.brushedMetalConfig.grainScale = value
        default: break
        }
        return copy
    }

    /// Animation speed for holographic shift, sparkle twinkle. No-op on other layer types.
    public func speed(_ value: Float) -> HologramLayer {
        var copy = self
        switch copy.kind {
        case .holographicFoil: copy.foilConfig.speed = value
        case .sparkle: copy.sparkleConfig.speed = value
        default: break
        }
        return copy
    }

    /// Color saturation of the holographic rainbow (0...1). No-op on other layer types.
    public func saturation(_ value: Float) -> HologramLayer {
        var copy = self
        if case .holographicFoil = copy.kind {
            copy.foilConfig.saturation = value
        }
        return copy
    }

    /// Holographic foil pattern style. No-op on other layer types.
    public func pattern(_ pattern: HolographicPattern) -> HologramLayer {
        var copy = self
        if case .holographicFoil = copy.kind {
            copy.foilConfig.pattern = pattern
        }
        return copy
    }

    // MARK: - Specular Modifiers

    /// Specular highlight spot size (0.05...1). No-op on other layer types.
    public func size(_ value: Float) -> HologramLayer {
        var copy = self
        switch copy.kind {
        case .specularHighlight: copy.specularConfig.size = value
        case .sparkle: copy.sparkleConfig.size = value
        case .anisotropicLight: copy.anisotropicLightConfig.size = value
        default: break
        }
        return copy
    }

    /// Falloff curve for specular highlight or anisotropic light. No-op on other layer types.
    public func falloff(_ value: Float) -> HologramLayer {
        var copy = self
        switch copy.kind {
        case .specularHighlight: copy.specularConfig.falloff = value
        case .anisotropicLight: copy.anisotropicLightConfig.softness = value
        default: break
        }
        return copy
    }

    /// Light/highlight color. No-op on other layer types.
    public func color(_ value: Color) -> HologramLayer {
        var copy = self
        switch copy.kind {
        case .specularHighlight: copy.specularConfig.color = value
        case .anisotropicLight: copy.anisotropicLightConfig.color = value
        default: break
        }
        return copy
    }

    // MARK: - Sparkle Modifiers

    /// Sparkle particle density (0...1). No-op on other layer types.
    public func density(_ value: Float) -> HologramLayer {
        var copy = self
        if case .sparkle = copy.kind {
            copy.sparkleConfig.density = value
        }
        return copy
    }

    // MARK: - Brushed Metal Modifiers

    /// Direction of the brush grain in radians (0 = horizontal). No-op on other layer types.
    public func brushAngle(_ radians: Float) -> HologramLayer {
        var copy = self
        switch copy.kind {
        case .brushedMetal: copy.brushedMetalConfig.brushAngle = radians
        case .anisotropicLight: copy.anisotropicLightConfig.brushAngle = radians
        default: break
        }
        return copy
    }

    // MARK: - Anisotropic Light Modifiers

    /// Anisotropic stretch ratio (1 = circular, higher = more elongated streak). No-op on other layer types.
    public func stretch(_ value: Float) -> HologramLayer {
        var copy = self
        if case .anisotropicLight = copy.kind {
            copy.anisotropicLightConfig.stretch = value
        }
        return copy
    }
}

// MARK: - Per-Layer Configs

struct HoloFoilConfig {
    var intensity: Float = 0.8
    var scale: Float = 1.0
    var speed: Float = 0.5
    var saturation: Float = 0.9
    var pattern: HolographicPattern = .diagonal
}

struct SpecularConfig {
    var intensity: Float = 0.7
    var size: Float = 0.35
    var falloff: Float = 1.2
    var color: Color = .white
}

struct SparkleConfig {
    var density: Float = 0.5
    var speed: Float = 3.0
    var size: Float = 1.0
}

struct BrushedMetalConfig {
    var grainScale: Float = 1.0
    var reflectivity: Float = 0.6
    var brushAngle: Float = 0.0
}

struct AnisotropicLightConfig {
    var intensity: Float = 0.7
    var size: Float = 0.35
    var stretch: Float = 8.0
    var brushAngle: Float = 0.0
    var softness: Float = 2.0
    var color: Color = .white
}
