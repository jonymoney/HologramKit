import SwiftUI
import HologramKit

struct SampleCard: Identifiable {
    let id = UUID()
    let name: String
    let subtitle: String
    let backgroundColor: Color
    let cardBaseColor: Color
    let cornerRadius: CGFloat
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let hasMetal: Bool
    let content: (CardConfiguration) -> [HologramLayer]

    init(
        name: String,
        subtitle: String,
        backgroundColor: Color,
        cardBaseColor: Color,
        cornerRadius: CGFloat = 20,
        cardWidth: CGFloat = 300,
        cardHeight: CGFloat = 420,
        hasMetal: Bool = false,
        @HologramLayerBuilder content: @escaping (CardConfiguration) -> [HologramLayer]
    ) {
        self.name = name
        self.subtitle = subtitle
        self.backgroundColor = backgroundColor
        self.cardBaseColor = cardBaseColor
        self.cornerRadius = cornerRadius
        self.cardWidth = cardWidth
        self.cardHeight = cardHeight
        self.hasMetal = hasMetal
        self.content = content
    }

    func makeDefaultConfig() -> CardConfiguration {
        CardConfiguration(
            backgroundColor: backgroundColor,
            cardBaseColor: cardBaseColor,
            cornerRadius: cornerRadius,
            cardWidth: cardWidth,
            cardHeight: cardHeight
        )
    }
}

// MARK: - Catalog

extension SampleCard {
    static let catalog: [SampleCard] = [
        SampleCard(
            name: "Mount Fuji",
            subtitle: "JAPAN 2026",
            backgroundColor: .white,
            cardBaseColor: Color(red: 82/255, green: 214/255, blue: 252/255)
        ) { config in

            HologramLayer.group("Sun") {
                HologramLayer.base(config.cardBaseColor)
                HologramLayer.holographicFoil(config.cardBaseColor)
                    .intensity(0.8)
                    .transparency(0.7)
                    .scale(1.0)
                    .speed(0.5)
                    .saturation(0.9)
                    .pattern(.waves)
                HologramLayer.image(Image("sun"))
                    .parallax(0.1)
                HologramLayer.image(Image("mount"))
                    .parallax(0.3)
            }
            
            HologramLayer.group("Flowers") {
                HologramLayer.image(Image("flower"))
                HologramLayer.sparkle()
                    .density(0.5)
                    .speed(3.0)
                    .size(1.0)
                HologramLayer.specularHighlight()
                    .parallax(0.8)
                    .intensity(0.3)
                    .size(0.35)
                    .falloff(1.2)
                    .color(.white)
                HologramLayer.plasticFoil()
            }
            .parallax(0.7)
        },

        // MARK: Nova – Brushed Silver Credit Card

        SampleCard(
            name: "Nova",
            subtitle: "Brushed Metal",
            backgroundColor: Color(white: 0.12),
            cardBaseColor: Color(red: 0.78, green: 0.80, blue: 0.83),
            cornerRadius: 16,
            cardWidth: 340,
            cardHeight: 214,
            hasMetal: true
        ) { config in
            HologramLayer.brushedMetal(config.cardBaseColor)
                .scale(1.0)
                .intensity(0.6)
                .brushAngle(0)

            HologramLayer.anisotropicLight()
                .intensity(config.anisoLightIntensity)
                .size(config.anisoLightSize)
                .stretch(config.anisoLightStretch)
                .brushAngle(0)
                .falloff(config.anisoLightSoftness)
                .color(.white)

            HologramLayer.content {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Spacer()
                        Text("NOVA")
                            .font(.system(size: 16, weight: .heavy))
                            .tracking(6)
                    }

                    Spacer()

                    // Chip
                    Image(systemName: "cpu")
                        .font(.system(size: 32, weight: .thin))
                        .foregroundStyle(
                            Color(red: 0.82, green: 0.75, blue: 0.52)
                        )

                    Spacer()

                    Text("4829  ••••  ••••  3841")
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .tracking(1)

                    Spacer()
                }
                .padding(24)
                .foregroundStyle(Color(white: 0.2))
            }
        },
    ]
}
