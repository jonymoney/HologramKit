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
    var plasticFoilConfig: PlasticFoilConfig = PlasticFoilConfig()

    enum Kind {
        case base(Color)
        case image(Image)
        case content(AnyView)
        case holographicFoil(Color)
        case specularHighlight
        case sparkle
        case brushedMetal(Color)
        case anisotropicLight
        case plasticFoil
        case group([HologramLayer], String?)
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
        HologramLayer(kind: .holographicFoil(baseColor))
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

    /// A transparent plastic foil overlay with visible edge rims and a sliding specular sheen.
    public static func plasticFoil() -> HologramLayer {
        HologramLayer(kind: .plasticFoil)
    }

    /// A compositing group that isolates blend modes within its sublayers.
    /// Sublayer parallax is relative within the group's local coordinate space.
    public static func group(
        _ name: String? = nil,
        @HologramLayerBuilder content: () -> [HologramLayer]
    ) -> HologramLayer {
        HologramLayer(kind: .group(content(), name))
    }

    // MARK: - Universal Modifiers

    /// How much this layer shifts in response to device tilt, creating a depth illusion.
    ///
    /// - Parameter factor: Movement amount. **Range: `0.0 ... 1.0`**.
    ///   `0` = fixed (background feel), `1` = maximum movement (foreground feel).
    ///   Default: `0`.
    public func parallax(_ factor: Double) -> HologramLayer {
        var copy = self
        copy.parallaxFactor = factor
        return copy
    }

    /// Blend mode for compositing this layer onto the layers below it.
    ///
    /// - Parameter mode: Any SwiftUI `BlendMode` (e.g. `.overlay`, `.screen`, `.plusLighter`).
    ///   Default: layer-type dependent (`.overlay` for holographic foil, `.screen` for specular, etc.).
    public func blendMode(_ mode: BlendMode) -> HologramLayer {
        var copy = self
        copy.layerBlendMode = mode
        return copy
    }

    /// Opacity of the entire layer.
    ///
    /// - Parameter value: **Range: `0.0 ... 1.0`**. `0` = invisible, `1` = fully opaque. Default: `1.0`.
    public func opacity(_ value: Double) -> HologramLayer {
        var copy = self
        copy.layerOpacity = value
        return copy
    }

    // MARK: - Shared Effect Modifiers

    /// Effect intensity / brightness.
    ///
    /// Applies to: `holographicFoil`, `specularHighlight`, `brushedMetal`, `anisotropicLight`, `plasticFoil`.
    /// No-op on other layer types.
    ///
    /// - Parameter value: **Range: `0.0 ... 1.0`**. `0` = invisible, `1` = full strength.
    ///   Defaults: foil `0.8`, specular `0.7`, brushedMetal `0.6`, anisotropicLight `0.7`, plasticFoil `0.6`.
    public func intensity(_ value: Float) -> HologramLayer {
        var copy = self
        switch copy.kind {
        case .holographicFoil: copy.foilConfig.intensity = value
        case .specularHighlight: copy.specularConfig.intensity = value
        case .brushedMetal: copy.brushedMetalConfig.reflectivity = value
        case .anisotropicLight: copy.anisotropicLightConfig.intensity = value
        case .plasticFoil: copy.plasticFoilConfig.intensity = value
        default: break
        }
        return copy
    }

    /// Scale of the holographic pattern or brushed-metal grain.
    ///
    /// Applies to: `holographicFoil`, `sparkle`, `brushedMetal`. No-op on other layer types.
    ///
    /// - Parameter value: **Range: `0.1 ... 5.0`**. `1.0` = natural size.
    ///   Lower = tighter/finer, higher = larger/coarser. Default: `1.0`.
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

    /// Animation speed for time-driven effects.
    ///
    /// Applies to: `holographicFoil` (color shift speed), `sparkle` (twinkle rate).
    /// No-op on other layer types.
    ///
    /// - Parameter value: **Range: `0.0 ... 10.0`**. `0` = frozen, higher = faster animation.
    ///   Defaults: foil `0.5`, sparkle `3.0`.
    public func speed(_ value: Float) -> HologramLayer {
        var copy = self
        switch copy.kind {
        case .holographicFoil: copy.foilConfig.speed = value
        case .sparkle: copy.sparkleConfig.speed = value
        default: break
        }
        return copy
    }

    /// Color saturation of the holographic rainbow.
    ///
    /// Applies to: `holographicFoil`. No-op on other layer types.
    ///
    /// - Parameter value: **Range: `0.0 ... 1.0`**. `0` = monochrome, `1` = vivid rainbow. Default: `0.9`.
    public func saturation(_ value: Float) -> HologramLayer {
        var copy = self
        if case .holographicFoil = copy.kind {
            copy.foilConfig.saturation = value
        }
        return copy
    }

    /// How see-through the holographic foil is.
    ///
    /// Applies to: `holographicFoil`. No-op on other layer types.
    ///
    /// - Parameter value: **Range: `0.0 ... 1.0`**. `0` = fully opaque, `1` = fully transparent. Default: `0.5`.
    public func transparency(_ value: Float) -> HologramLayer {
        var copy = self
        if case .holographicFoil = copy.kind {
            copy.foilConfig.transparency = value
        }
        return copy
    }

    /// Holographic foil pattern style.
    ///
    /// Applies to: `holographicFoil`. No-op on other layer types.
    ///
    /// - Parameter pattern: Default: `.diagonal`. Options:
    ///   - `.diagonal` — classic angled rainbow bands
    ///   - `.diamond` — concentric diamond shapes from center
    ///   - `.radial` — circular rings radiating outward
    ///   - `.linear` — horizontal color bands
    ///   - `.crisscross` — grid of intersecting sine waves
    ///   - `.fluid` — organic marble/oil-slick swirls (domain-warped noise)
    ///   - `.microFacet` — tiny pyramid cells, each catching light at a different angle
    ///   - `.waves` — overlapping fine-line interference fringes (credit card hologram style)
    public func pattern(_ pattern: HolographicPattern) -> HologramLayer {
        var copy = self
        if case .holographicFoil = copy.kind {
            copy.foilConfig.pattern = pattern
        }
        return copy
    }

    /// Size of the highlight spot or sheen spread.
    ///
    /// Applies to: `specularHighlight`, `sparkle`, `anisotropicLight`, `plasticFoil`.
    /// No-op on other layer types.
    ///
    /// - Parameter value: **Range: `0.05 ... 1.0`**.
    ///   Lower = tighter/smaller spot, higher = broader/softer.
    ///   Defaults: specular `0.35`, sparkle `1.0`, anisotropicLight `0.35`, plasticFoil `0.5`.
    public func size(_ value: Float) -> HologramLayer {
        var copy = self
        switch copy.kind {
        case .specularHighlight: copy.specularConfig.size = value
        case .sparkle: copy.sparkleConfig.size = value
        case .anisotropicLight: copy.anisotropicLightConfig.size = value
        case .plasticFoil: copy.plasticFoilConfig.shineSize = value
        default: break
        }
        return copy
    }

    /// Falloff curve that controls how sharply the highlight fades at its edges.
    ///
    /// Applies to: `specularHighlight`, `anisotropicLight`. No-op on other layer types.
    ///
    /// - Parameter value: **Range: `0.1 ... 5.0`**.
    ///   Lower = softer gradient, higher = sharper cutoff.
    ///   Defaults: specular `1.2`, anisotropicLight `2.0`.
    public func falloff(_ value: Float) -> HologramLayer {
        var copy = self
        switch copy.kind {
        case .specularHighlight: copy.specularConfig.falloff = value
        case .anisotropicLight: copy.anisotropicLightConfig.softness = value
        default: break
        }
        return copy
    }

    /// Tint color of the light or highlight.
    ///
    /// Applies to: `specularHighlight`, `anisotropicLight`. No-op on other layer types.
    ///
    /// - Parameter value: Any SwiftUI `Color`. Default: `.white`.
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

    /// Sparkle particle density — how many glitter points are visible.
    ///
    /// Applies to: `sparkle`. No-op on other layer types.
    ///
    /// - Parameter value: **Range: `0.0 ... 1.0`**. `0` = very few, `1` = dense glitter. Default: `0.5`.
    public func density(_ value: Float) -> HologramLayer {
        var copy = self
        if case .sparkle = copy.kind {
            copy.sparkleConfig.density = value
        }
        return copy
    }

    // MARK: - Brushed Metal / Anisotropic Modifiers

    /// Direction of the brush grain.
    ///
    /// Applies to: `brushedMetal`, `anisotropicLight`. No-op on other layer types.
    ///
    /// - Parameter radians: Angle in radians. **Range: `0 ... 2π`**.
    ///   `0` = horizontal, `π/2` = vertical. Default: `0`.
    public func brushAngle(_ radians: Float) -> HologramLayer {
        var copy = self
        switch copy.kind {
        case .brushedMetal: copy.brushedMetalConfig.brushAngle = radians
        case .anisotropicLight: copy.anisotropicLightConfig.brushAngle = radians
        default: break
        }
        return copy
    }

    /// Anisotropic stretch ratio — how elongated the light streak is along the brush direction.
    ///
    /// Applies to: `anisotropicLight`. No-op on other layer types.
    ///
    /// - Parameter value: **Range: `1.0 ... 20.0`**.
    ///   `1` = circular, higher = longer streak. Default: `8.0`.
    public func stretch(_ value: Float) -> HologramLayer {
        var copy = self
        if case .anisotropicLight = copy.kind {
            copy.anisotropicLightConfig.stretch = value
        }
        return copy
    }

    // MARK: - Plastic Foil Modifiers

    /// Width of the edge rim glow on the plastic foil.
    ///
    /// Applies to: `plasticFoil`. No-op on other layer types.
    ///
    /// - Parameter value: **Range: `0.01 ... 0.2`** (fraction of card width).
    ///   Lower = thinner rim, higher = wider glow. Default: `0.06`.
    public func edgeWidth(_ value: Float) -> HologramLayer {
        var copy = self
        if case .plasticFoil = copy.kind {
            copy.plasticFoilConfig.edgeWidth = value
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
    var transparency: Float = 0.5
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

struct PlasticFoilConfig {
    var edgeWidth: Float = 0.06
    var intensity: Float = 0.6
    var shineSize: Float = 0.5
}
