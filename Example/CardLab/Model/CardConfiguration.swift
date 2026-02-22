import SwiftUI

@Observable
class CardConfiguration {
    // MARK: - Card Geometry
    var cornerRadius: CGFloat = 20
    var cardWidth: CGFloat = 300
    var cardHeight: CGFloat = 420

    // MARK: - Parallax
    var parallaxIntensity: CGFloat = 50

    // MARK: - Motion
    var sensitivity: Float = 2.20
    var smoothingFactor: Float = 0.15
    var tiltIntensity: Double = 15

    // MARK: - Colors
    var backgroundColor: Color = .white
    var cardBaseColor: Color = Color(red: 0.85, green: 0.65, blue: 0.13)

    // MARK: - Anisotropic Light
    var anisoLightIntensity: Float = 0.4
    var anisoLightSize: Float = 0.3
    var anisoLightStretch: Float = 8.0
    var anisoLightSoftness: Float = 2.0

    // MARK: - Holographic Foil
    var foilIntensity: Float = 0.8
    var foilSpeed: Float = 0.5
    var foilSaturation: Float = 0.9
    var foilTransparency: Float = 0.5

    // MARK: - Smoke Glass
    var glassRefraction: Float = 0.5
    var glassAberration: Float = 0.3
    var glassClarity: Float = 0.8
    var glassIntensity: Float = 0.7
    var glassSpeed: Float = 0.8
    var glassEdgeWidth: Float = 0.04

    init(
        backgroundColor: Color = .white,
        cardBaseColor: Color = Color(red: 0.85, green: 0.65, blue: 0.13),
        cornerRadius: CGFloat = 20,
        cardWidth: CGFloat = 300,
        cardHeight: CGFloat = 420
    ) {
        self.backgroundColor = backgroundColor
        self.cardBaseColor = cardBaseColor
        self.cornerRadius = cornerRadius
        self.cardWidth = cardWidth
        self.cardHeight = cardHeight
    }
}

// MARK: - Preset Snapshot

extension CardConfiguration {
    struct Snapshot: Codable {
        var cornerRadius: Double
        var cardWidth: Double
        var cardHeight: Double
        var parallaxIntensity: Double
        var sensitivity: Float
        var smoothingFactor: Float
        var tiltIntensity: Double
        var backgroundColorRGBA: [Double]
        var cardBaseColorRGBA: [Double]
        var anisoLightIntensity: Float
        var anisoLightSize: Float
        var anisoLightStretch: Float
        var anisoLightSoftness: Float
        var foilIntensity: Float?
        var foilSpeed: Float?
        var foilSaturation: Float?
        var foilTransparency: Float?
    }

    func makeSnapshot() -> Snapshot {
        Snapshot(
            cornerRadius: cornerRadius,
            cardWidth: cardWidth,
            cardHeight: cardHeight,
            parallaxIntensity: parallaxIntensity,
            sensitivity: sensitivity,
            smoothingFactor: smoothingFactor,
            tiltIntensity: tiltIntensity,
            backgroundColorRGBA: Self.colorToComponents(backgroundColor),
            cardBaseColorRGBA: Self.colorToComponents(cardBaseColor),
            anisoLightIntensity: anisoLightIntensity,
            anisoLightSize: anisoLightSize,
            anisoLightStretch: anisoLightStretch,
            anisoLightSoftness: anisoLightSoftness,
            foilIntensity: foilIntensity,
            foilSpeed: foilSpeed,
            foilSaturation: foilSaturation,
            foilTransparency: foilTransparency
        )
    }

    func apply(_ snapshot: Snapshot) {
        cornerRadius = snapshot.cornerRadius
        cardWidth = snapshot.cardWidth
        cardHeight = snapshot.cardHeight
        parallaxIntensity = snapshot.parallaxIntensity
        sensitivity = snapshot.sensitivity
        smoothingFactor = snapshot.smoothingFactor
        tiltIntensity = snapshot.tiltIntensity
        backgroundColor = Self.componentsToColor(snapshot.backgroundColorRGBA)
        cardBaseColor = Self.componentsToColor(snapshot.cardBaseColorRGBA)
        anisoLightIntensity = snapshot.anisoLightIntensity
        anisoLightSize = snapshot.anisoLightSize
        anisoLightStretch = snapshot.anisoLightStretch
        anisoLightSoftness = snapshot.anisoLightSoftness
        if let v = snapshot.foilIntensity { foilIntensity = v }
        if let v = snapshot.foilSpeed { foilSpeed = v }
        if let v = snapshot.foilSaturation { foilSaturation = v }
        if let v = snapshot.foilTransparency { foilTransparency = v }
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
