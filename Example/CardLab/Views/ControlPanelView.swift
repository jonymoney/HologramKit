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

    static var gridOptions: [ColorGridOption] {
        allCases.map { ColorGridOption(id: $0.rawValue, name: $0.name, color: $0.color) }
    }
}

struct ControlPanelView: View {
    @Bindable var config: CardConfiguration
    var presetStore: PresetStore
    var customSections: [ControlSection] = []

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

                ForEach(customSections) { section in
                    Section(section.title) {
                        ForEach(section.items) { item in
                            controlView(for: item)
                        }
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

    // MARK: - Dynamic Control Renderer

    @ViewBuilder
    private func controlView(for item: ControlItem) -> some View {
        switch item {
        case .floatSlider(let label, let keyPath, let range, let format):
            SliderRow(
                label: label,
                value: Bindable(config)[dynamicMember: keyPath],
                range: range,
                format: format
            )

        case .doubleSlider(let label, let keyPath, let range, let format):
            SliderRow(
                label: label,
                value: Bindable(config)[dynamicMember: keyPath],
                range: range,
                format: format
            )

        case .cgFloatSlider(let label, let keyPath, let range, let format):
            SliderRow(
                label: label,
                value: Bindable(config)[dynamicMember: keyPath],
                range: range,
                format: format
            )

        case .colorPicker(let label, let keyPath):
            ColorPicker(label, selection: Bindable(config)[dynamicMember: keyPath])

        case .colorGrid(let keyPath, let options):
            colorGridView(keyPath: keyPath, options: options)
        }
    }

    @ViewBuilder
    private func colorGridView(
        keyPath: ReferenceWritableKeyPath<CardConfiguration, Color>,
        options: [ColorGridOption]
    ) -> some View {
        let binding = Bindable(config)[dynamicMember: keyPath]
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 90))], spacing: 12) {
            ForEach(options) { option in
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        binding.wrappedValue = option.color
                    }
                } label: {
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(option.color)
                            .frame(height: 44)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(
                                        binding.wrappedValue == option.color
                                            ? Color.accentColor
                                            : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                        Text(option.name)
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
