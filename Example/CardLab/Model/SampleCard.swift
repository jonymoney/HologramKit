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
    let customSections: [ControlSection]
    let content: (CardConfiguration) -> [HologramLayer]

    init(
        name: String,
        subtitle: String,
        backgroundColor: Color,
        cardBaseColor: Color,
        cornerRadius: CGFloat = 20,
        cardWidth: CGFloat = 300,
        cardHeight: CGFloat = 420,
        customSections: [ControlSection] = [],
        @HologramLayerBuilder content: @escaping (CardConfiguration) -> [HologramLayer]
    ) {
        self.name = name
        self.subtitle = subtitle
        self.backgroundColor = backgroundColor
        self.cardBaseColor = cardBaseColor
        self.cornerRadius = cornerRadius
        self.cardWidth = cardWidth
        self.cardHeight = cardHeight
        self.customSections = customSections
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
            cardBaseColor: Color(red: 82/255, green: 214/255, blue: 252/255),
            customSections: [
                ControlSection(title: "Holographic Foil", items: [
                    .floatSlider(label: "Intensity", keyPath: \.foilIntensity, range: 0...1),
                    .floatSlider(label: "Speed", keyPath: \.foilSpeed, range: 0...2),
                    .floatSlider(label: "Saturation", keyPath: \.foilSaturation, range: 0...1),
                    .floatSlider(label: "Transparency", keyPath: \.foilTransparency, range: 0...1),
                ]),
            ]
        ) { config in

            HologramLayer.group("Sun") {
                HologramLayer.base(config.cardBaseColor)
                HologramLayer.holographicFoil(config.cardBaseColor)
                    .intensity(config.foilIntensity)
                    .transparency(config.foilTransparency)
                    .scale(1.0)
                    .speed(config.foilSpeed)
                    .saturation(config.foilSaturation)
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
            customSections: [
                ControlSection(title: "Anisotropic Light", items: [
                    .floatSlider(label: "Intensity", keyPath: \.anisoLightIntensity, range: 0...1),
                    .floatSlider(label: "Size", keyPath: \.anisoLightSize, range: 0.05...1),
                    .floatSlider(label: "Stretch", keyPath: \.anisoLightStretch, range: 1...20),
                    .floatSlider(label: "Softness", keyPath: \.anisoLightSoftness, range: 0.5...5),
                ]),
                ControlSection(title: "Metal", items: [
                    .colorGrid(keyPath: \.cardBaseColor, options: MetalPreset.gridOptions),
                ]),
            ]
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

        // MARK: Aqua – Smoke Glass

        SampleCard(
            name: "Aqua",
            subtitle: "Smoke Glass",
            backgroundColor: Color(red: 0.04, green: 0.08, blue: 0.16),
            cardBaseColor: Color(red: 0.10, green: 0.18, blue: 0.28),
            customSections: [
                ControlSection(title: "Smoke Glass", items: [
                    .floatSlider(label: "Refraction", keyPath: \.glassRefraction, range: 0...1),
                    .floatSlider(label: "Aberration", keyPath: \.glassAberration, range: 0...1),
                    .floatSlider(label: "Clarity", keyPath: \.glassClarity, range: 0...1),
                    .floatSlider(label: "Intensity", keyPath: \.glassIntensity, range: 0...1),
                    .floatSlider(label: "Speed", keyPath: \.glassSpeed, range: 0...2),
                    .floatSlider(label: "Edge Width", keyPath: \.glassEdgeWidth, range: 0.01...0.2),
                ]),
            ]
        ) { config in
            HologramLayer.base(config.cardBaseColor)

            HologramLayer.group {
                HologramLayer.smokeGlass()
                    .refraction(config.glassRefraction)
                    .aberration(config.glassAberration)
                    .clarity(config.glassClarity)
                    .intensity(config.glassIntensity)
                    .speed(config.glassSpeed)
                    .edgeWidth(config.glassEdgeWidth)
                HologramLayer.content {
                    VStack(spacing: 0) {
                        Spacer()
                        
                        Image(systemName: "drop.fill")
                            .font(.system(size: 48, weight: .ultraLight))
                            .foregroundStyle(
                                .linearGradient(
                                    colors: [
                                        Color(red: 0.4, green: 0.8, blue: 1.0),
                                        Color(red: 0.6, green: 0.5, blue: 1.0),
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        
                        Spacer()
                            .frame(height: 16)
                        
                        Text("AQUA")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .tracking(8)
                            .foregroundStyle(Color(white: 0.85))
                        
                        Text("smoke glass")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .tracking(4)
                            .foregroundStyle(Color(white: 0.45))
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .parallax(0.3)
            
            HologramLayer.specularHighlight()
                .parallax(0)
                .intensity(0.2)
                .size(0.4)
        },
    ]
}
