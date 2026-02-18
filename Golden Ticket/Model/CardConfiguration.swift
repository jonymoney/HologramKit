import SwiftUI

struct ImageLayer: Identifiable, Codable {
    var id = UUID()
    var name: String
    var assetName: String
    var isVisible: Bool = true
    var parallaxFactor: Double = 0.3
    var opacity: Double = 1.0
}

@Observable
class CardConfiguration {
    // MARK: - Layer Visibility
    var showBase = true
    var showContent = true
    var showHolographic = true
    var showSpecular = true
    var showSparkle = true

    // MARK: - Image Layers
    var imageLayers: [ImageLayer] = [
        ImageLayer(name: "Sun", assetName: "sun", parallaxFactor: 0.1),
        ImageLayer(name: "Mountain", assetName: "mount", parallaxFactor: 0.25),
        ImageLayer(name: "Flowers", assetName: "flower", parallaxFactor: 0.4),
    ]

    // MARK: - Parallax
    var parallaxIntensity: CGFloat = 20
    var baseParallaxFactor: Double = 0
    var contentParallaxFactor: Double = 0.2
    var holoParallaxFactor: Double = 0.5
    var specularParallaxFactor: Double = 0.8
    var sparkleParallaxFactor: Double = 1.0

    // MARK: - Holographic
    var holoIntensity: Float = 0.8
    var holoScale: Float = 1.0
    var holoSpeed: Float = 0.5
    var holoSaturation: Float = 0.9
    var holoPattern: HoloPattern = .diagonal

    // MARK: - Specular
    var specularIntensity: Float = 0.7
    var specularSize: Float = 0.35
    var specularFalloff: Float = 1.2
    var specularColor: Color = .white

    // MARK: - Sparkle
    var sparkleDensity: Float = 0.5
    var sparkleSpeed: Float = 3.0
    var sparkleSize: Float = 1.0

    // MARK: - Card Geometry
    var cornerRadius: CGFloat = 20
    var cardWidth: CGFloat = 300
    var cardHeight: CGFloat = 420

    // MARK: - Motion
    var sensitivity: Float = 1.0
    var smoothingFactor: Float = 0.15
    var tiltIntensity: Double = 15

    // MARK: - Colors
    var backgroundColor: Color = .white
    var cardBaseColor: Color = Color(red: 0.85, green: 0.65, blue: 0.13)

    enum HoloPattern: Int, CaseIterable, Identifiable, Codable {
        case diagonal = 0
        case diamond = 1
        case radial = 2
        case linear = 3
        case crisscross = 4

        var id: Int { rawValue }

        var name: String {
            switch self {
            case .diagonal: "Diagonal"
            case .diamond: "Diamond"
            case .radial: "Radial"
            case .linear: "Linear"
            case .crisscross: "Crisscross"
            }
        }
    }
}

// MARK: - Preset Snapshot

extension CardConfiguration {
    struct Snapshot: Codable {
        var showBase: Bool
        var showContent: Bool
        var showHolographic: Bool
        var showSpecular: Bool
        var showSparkle: Bool

        var imageLayers: [ImageLayer]

        var parallaxIntensity: Double
        var baseParallaxFactor: Double
        var contentParallaxFactor: Double
        var holoParallaxFactor: Double
        var specularParallaxFactor: Double
        var sparkleParallaxFactor: Double

        var holoIntensity: Float
        var holoScale: Float
        var holoSpeed: Float
        var holoSaturation: Float
        var holoPattern: HoloPattern

        var specularIntensity: Float
        var specularSize: Float
        var specularFalloff: Float
        var specularColorRGBA: [Double]

        var sparkleDensity: Float
        var sparkleSpeed: Float
        var sparkleSize: Float

        var cornerRadius: Double
        var cardWidth: Double
        var cardHeight: Double

        var sensitivity: Float
        var smoothingFactor: Float
        var tiltIntensity: Double

        var backgroundColorRGBA: [Double]
        var cardBaseColorRGBA: [Double]
    }

    func makeSnapshot() -> Snapshot {
        Snapshot(
            showBase: showBase,
            showContent: showContent,
            showHolographic: showHolographic,
            showSpecular: showSpecular,
            showSparkle: showSparkle,
            imageLayers: imageLayers,
            parallaxIntensity: parallaxIntensity,
            baseParallaxFactor: baseParallaxFactor,
            contentParallaxFactor: contentParallaxFactor,
            holoParallaxFactor: holoParallaxFactor,
            specularParallaxFactor: specularParallaxFactor,
            sparkleParallaxFactor: sparkleParallaxFactor,
            holoIntensity: holoIntensity,
            holoScale: holoScale,
            holoSpeed: holoSpeed,
            holoSaturation: holoSaturation,
            holoPattern: holoPattern,
            specularIntensity: specularIntensity,
            specularSize: specularSize,
            specularFalloff: specularFalloff,
            specularColorRGBA: Self.colorToComponents(specularColor),
            sparkleDensity: sparkleDensity,
            sparkleSpeed: sparkleSpeed,
            sparkleSize: sparkleSize,
            cornerRadius: cornerRadius,
            cardWidth: cardWidth,
            cardHeight: cardHeight,
            sensitivity: sensitivity,
            smoothingFactor: smoothingFactor,
            tiltIntensity: tiltIntensity,
            backgroundColorRGBA: Self.colorToComponents(backgroundColor),
            cardBaseColorRGBA: Self.colorToComponents(cardBaseColor)
        )
    }

    func apply(_ snapshot: Snapshot) {
        showBase = snapshot.showBase
        showContent = snapshot.showContent
        showHolographic = snapshot.showHolographic
        showSpecular = snapshot.showSpecular
        showSparkle = snapshot.showSparkle
        imageLayers = snapshot.imageLayers
        parallaxIntensity = snapshot.parallaxIntensity
        baseParallaxFactor = snapshot.baseParallaxFactor
        contentParallaxFactor = snapshot.contentParallaxFactor
        holoParallaxFactor = snapshot.holoParallaxFactor
        specularParallaxFactor = snapshot.specularParallaxFactor
        sparkleParallaxFactor = snapshot.sparkleParallaxFactor
        holoIntensity = snapshot.holoIntensity
        holoScale = snapshot.holoScale
        holoSpeed = snapshot.holoSpeed
        holoSaturation = snapshot.holoSaturation
        holoPattern = snapshot.holoPattern
        specularIntensity = snapshot.specularIntensity
        specularSize = snapshot.specularSize
        specularFalloff = snapshot.specularFalloff
        specularColor = Self.componentsToColor(snapshot.specularColorRGBA)
        sparkleDensity = snapshot.sparkleDensity
        sparkleSpeed = snapshot.sparkleSpeed
        sparkleSize = snapshot.sparkleSize
        cornerRadius = snapshot.cornerRadius
        cardWidth = snapshot.cardWidth
        cardHeight = snapshot.cardHeight
        sensitivity = snapshot.sensitivity
        smoothingFactor = snapshot.smoothingFactor
        tiltIntensity = snapshot.tiltIntensity
        backgroundColor = Self.componentsToColor(snapshot.backgroundColorRGBA)
        cardBaseColor = Self.componentsToColor(snapshot.cardBaseColorRGBA)
    }

    static func colorToComponents(_ color: Color) -> [Double] {
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return [Double(r), Double(g), Double(b), Double(a)]
    }

    static func componentsToColor(_ c: [Double]) -> Color {
        guard c.count >= 4 else { return .black }
        return Color(red: c[0], green: c[1], blue: c[2], opacity: c[3])
    }
}
