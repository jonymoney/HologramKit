import Testing
@testable import HologramKit
import SwiftUI

@Suite("HologramLayerBuilder")
struct HologramLayerBuilderTests {

    @Test("Single layer builds correctly")
    func singleLayer() {
        let layers = buildLayers {
            HologramLayer.base(.blue)
        }
        #expect(layers.count == 1)
    }

    @Test("Multiple layers build in order")
    func multipleLayers() {
        let layers = buildLayers {
            HologramLayer.base(.red)
            HologramLayer.holographicFoil()
            HologramLayer.specularHighlight()
            HologramLayer.sparkle()
        }
        #expect(layers.count == 4)
    }

    @Test("if/else — true branch")
    func conditionalTrue() {
        let show = true
        let layers = buildLayers {
            HologramLayer.base(.white)
            if show {
                HologramLayer.holographicFoil()
            }
        }
        #expect(layers.count == 2)
    }

    @Test("if/else — false branch")
    func conditionalFalse() {
        let show = false
        let layers = buildLayers {
            HologramLayer.base(.white)
            if show {
                HologramLayer.holographicFoil()
            }
        }
        #expect(layers.count == 1)
    }

    @Test("if/else branches")
    func ifElse() {
        let useSpecular = false
        let layers = buildLayers {
            HologramLayer.base(.white)
            if useSpecular {
                HologramLayer.specularHighlight()
            } else {
                HologramLayer.sparkle()
            }
        }
        #expect(layers.count == 2)
    }

    @Test("for loop builds array of layers")
    func forLoop() {
        let names = ["a", "b", "c"]
        let layers = buildLayers {
            HologramLayer.base(.black)
            for _ in names {
                HologramLayer.sparkle()
            }
        }
        #expect(layers.count == 4) // 1 base + 3 sparkles
    }

    @Test("Layer modifiers return modified copies")
    func modifiers() {
        let layer = HologramLayer.holographicFoil()
            .parallax(0.7)
            .intensity(0.5)
            .pattern(.diamond)
            .scale(2.0)
            .speed(1.5)
            .saturation(0.6)

        #expect(layer.parallaxFactor == 0.7)
        #expect(layer.foilConfig.intensity == 0.5)
        #expect(layer.foilConfig.pattern == .diamond)
        #expect(layer.foilConfig.scale == 2.0)
        #expect(layer.foilConfig.speed == 1.5)
        #expect(layer.foilConfig.saturation == 0.6)
    }

    @Test("Specular modifiers")
    func specularModifiers() {
        let layer = HologramLayer.specularHighlight()
            .intensity(0.9)
            .size(0.5)
            .falloff(2.0)

        #expect(layer.specularConfig.intensity == 0.9)
        #expect(layer.specularConfig.size == 0.5)
        #expect(layer.specularConfig.falloff == 2.0)
    }

    @Test("Sparkle modifiers")
    func sparkleModifiers() {
        let layer = HologramLayer.sparkle()
            .density(0.8)
            .speed(5.0)
            .size(2.0)

        #expect(layer.sparkleConfig.density == 0.8)
        #expect(layer.sparkleConfig.speed == 5.0)
        #expect(layer.sparkleConfig.size == 2.0)
    }

    @Test("Wrong-type modifiers are no-ops")
    func noOpModifiers() {
        let layer = HologramLayer.base(.red)
            .intensity(0.5)
            .pattern(.radial)
            .density(0.8)

        // These should remain at defaults since base doesn't support them
        #expect(layer.foilConfig.intensity == 0.8) // default
        #expect(layer.foilConfig.pattern == .diagonal) // default
        #expect(layer.sparkleConfig.density == 0.5) // default
    }

    @Test("Universal modifiers work on all types")
    func universalModifiers() {
        let layer = HologramLayer.sparkle()
            .parallax(0.3)
            .blendMode(.multiply)
            .opacity(0.5)

        #expect(layer.parallaxFactor == 0.3)
        #expect(layer.layerBlendMode == .multiply)
        #expect(layer.layerOpacity == 0.5)
    }

    @Test("Default parallax values for effect layers")
    func defaultParallax() {
        let foil = HologramLayer.holographicFoil()
        let spec = HologramLayer.specularHighlight()
        let spark = HologramLayer.sparkle()
        let base = HologramLayer.base(.red)

        #expect(foil.parallaxFactor == 0.5)
        #expect(spec.parallaxFactor == 0.8)
        #expect(spark.parallaxFactor == 1.0)
        #expect(base.parallaxFactor == 0)
    }

    // MARK: - Helpers

    private func buildLayers(@HologramLayerBuilder content: () -> [HologramLayer]) -> [HologramLayer] {
        content()
    }
}
