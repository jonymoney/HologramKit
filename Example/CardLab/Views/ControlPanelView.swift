import SwiftUI

enum MetalPreset: String, CaseIterable, Identifiable {
    case silver, gold, roseGold, copper, gunmetal, platinum

    var id: String { rawValue }

    var name: String {
        switch self {
        case .silver:    return "Silver"
        case .gold:      return "Gold"
        case .roseGold:  return "Rose Gold"
        case .copper:    return "Copper"
        case .gunmetal:  return "Gunmetal"
        case .platinum:  return "Platinum"
        }
    }

    var color: Color {
        switch self {
        case .silver:    return Color(red: 0.78, green: 0.80, blue: 0.83)
        case .gold:      return Color(red: 0.85, green: 0.65, blue: 0.13)
        case .roseGold:  return Color(red: 0.72, green: 0.43, blue: 0.47)
        case .copper:    return Color(red: 0.72, green: 0.45, blue: 0.20)
        case .gunmetal:  return Color(red: 0.35, green: 0.38, blue: 0.42)
        case .platinum:  return Color(red: 0.90, green: 0.89, blue: 0.87)
        }
    }
}

struct ControlPanelView: View {
    @Bindable var config: CardConfiguration
    var presetStore: PresetStore
    var showMetalControls: Bool = false

    @State private var showingSaveAlert = false
    @State private var presetName = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Presets") {
                    Button("Save Current") {
                        showingSaveAlert = true
                    }

                    if presetStore.presets.isEmpty {
                        Text("No saved presets")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(presetStore.presets) { preset in
                            Button {
                                presetStore.apply(preset, to: config)
                            } label: {
                                HStack {
                                    Text(preset.name)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Image(systemName: "arrow.turn.down.left")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .onDelete { indices in
                            for index in indices {
                                presetStore.delete(presetStore.presets[index])
                            }
                        }
                    }
                }

                Section("Card") {
                    SliderRow(label: "Corner Radius", value: $config.cornerRadius, range: 0...60)
                    SliderRow(label: "Width", value: $config.cardWidth, range: 200...380, format: "%.0f")
                    SliderRow(label: "Height", value: $config.cardHeight, range: 280...560, format: "%.0f")
                }

                Section("Parallax") {
                    SliderRow(label: "Intensity", value: $config.parallaxIntensity, range: 0...60)
                }

                Section("Motion") {
                    SliderRow(label: "Sensitivity", value: $config.sensitivity, range: 0.1...3)
                    SliderRow(label: "Smoothing", value: $config.smoothingFactor, range: 0.01...1)
                    SliderRow(label: "Tilt Degrees", value: $config.tiltIntensity, range: 0...45)
                }

                if showMetalControls {
                    Section("Anisotropic Light") {
                        SliderRow(label: "Intensity", value: $config.anisoLightIntensity, range: 0...1)
                        SliderRow(label: "Size", value: $config.anisoLightSize, range: 0.05...1)
                        SliderRow(label: "Stretch", value: $config.anisoLightStretch, range: 1...20)
                        SliderRow(label: "Softness", value: $config.anisoLightSoftness, range: 0.5...5)
                    }

                    Section("Metal") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 12) {
                        ForEach(MetalPreset.allCases) { preset in
                            Button {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    config.cardBaseColor = preset.color
                                }
                            } label: {
                                VStack(spacing: 6) {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(preset.color)
                                        .frame(height: 44)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .strokeBorder(
                                                    config.cardBaseColor == preset.color
                                                        ? Color.accentColor
                                                        : Color.clear,
                                                    lineWidth: 2
                                                )
                                        )
                                    Text(preset.name)
                                        .font(.caption2)
                                        .foregroundStyle(.primary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                    }
                }

                Section("Colors") {
                    ColorPicker("Background", selection: $config.backgroundColor)
                    ColorPicker("Card Base", selection: $config.cardBaseColor)
                }
            }
            .navigationTitle("Controls")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Save Preset", isPresented: $showingSaveAlert) {
                TextField("Preset name", text: $presetName)
                Button("Save") {
                    if !presetName.isEmpty {
                        presetStore.save(name: presetName, config: config)
                        presetName = ""
                    }
                }
                Button("Cancel", role: .cancel) {
                    presetName = ""
                }
            }
        }
    }
}
