/// Result builder for composing hologram layers declaratively.
///
/// Supports `if/else`, `for` loops, and optionals:
/// ```swift
/// HologramCard {
///     HologramLayer.base(.blue)
///
///     for name in imageNames {
///         HologramLayer.image(Image(name)).parallax(0.3)
///     }
///
///     if showHolo {
///         HologramLayer.holographicFoil()
///     }
/// }
/// ```
@resultBuilder
public struct HologramLayerBuilder {
    public static func buildBlock(_ components: [HologramLayer]...) -> [HologramLayer] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: HologramLayer) -> [HologramLayer] {
        [expression]
    }

    public static func buildOptional(_ component: [HologramLayer]?) -> [HologramLayer] {
        component ?? []
    }

    public static func buildEither(first component: [HologramLayer]) -> [HologramLayer] {
        component
    }

    public static func buildEither(second component: [HologramLayer]) -> [HologramLayer] {
        component
    }

    public static func buildArray(_ components: [[HologramLayer]]) -> [HologramLayer] {
        components.flatMap { $0 }
    }
}
