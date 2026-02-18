import SwiftUI

struct ControlPanelView: View {
    @Bindable var config: CardConfiguration
    var presetStore: PresetStore

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

                Section("Image Layers") {
                    ForEach($config.imageLayers) { $layer in
                        DisclosureGroup {
                            SliderRow(label: "Parallax", value: $layer.parallaxFactor, range: 0...2)
                            SliderRow(label: "Opacity", value: $layer.opacity, range: 0...1)
                        } label: {
                            Toggle(layer.name, isOn: $layer.isVisible)
                        }
                    }
                    .onMove { from, to in
                        config.imageLayers.move(fromOffsets: from, toOffset: to)
                    }
                }

                Section("Effect Layers") {
                    Toggle("Base", isOn: $config.showBase)
                    Toggle("Content", isOn: $config.showContent)
                    Toggle("Holographic Foil", isOn: $config.showHolographic)
                    Toggle("Specular Highlight", isOn: $config.showSpecular)
                    Toggle("Sparkle", isOn: $config.showSparkle)
                }

                Section("Parallax") {
                    SliderRow(label: "Intensity", value: $config.parallaxIntensity, range: 0...60)
                    SliderRow(label: "Base", value: $config.baseParallaxFactor, range: 0...2)
                    SliderRow(label: "Content", value: $config.contentParallaxFactor, range: 0...2)
                    SliderRow(label: "Holographic", value: $config.holoParallaxFactor, range: 0...2)
                    SliderRow(label: "Specular", value: $config.specularParallaxFactor, range: 0...2)
                    SliderRow(label: "Sparkle", value: $config.sparkleParallaxFactor, range: 0...2)
                }

                Section("Holographic") {
                    SliderRow(label: "Intensity", value: $config.holoIntensity, range: 0...1)
                    SliderRow(label: "Scale", value: $config.holoScale, range: 0.1...5)
                    SliderRow(label: "Speed", value: $config.holoSpeed, range: 0...3)
                    SliderRow(label: "Saturation", value: $config.holoSaturation, range: 0...1)
                    Picker("Pattern", selection: $config.holoPattern) {
                        ForEach(CardConfiguration.HoloPattern.allCases) { pattern in
                            Text(pattern.name).tag(pattern)
                        }
                    }
                }

                Section("Specular") {
                    SliderRow(label: "Intensity", value: $config.specularIntensity, range: 0...1)
                    SliderRow(label: "Size", value: $config.specularSize, range: 0.05...1)
                    SliderRow(label: "Falloff", value: $config.specularFalloff, range: 0.1...5)
                    ColorPicker("Color", selection: $config.specularColor)
                }

                Section("Sparkle") {
                    SliderRow(label: "Density", value: $config.sparkleDensity, range: 0...1)
                    SliderRow(label: "Speed", value: $config.sparkleSpeed, range: 0...10)
                    SliderRow(label: "Size", value: $config.sparkleSize, range: 0.1...3)
                }

                Section("Card") {
                    SliderRow(label: "Corner Radius", value: $config.cornerRadius, range: 0...60)
                    SliderRow(label: "Width", value: $config.cardWidth, range: 200...380, format: "%.0f")
                    SliderRow(label: "Height", value: $config.cardHeight, range: 280...560, format: "%.0f")
                }

                Section("Motion") {
                    SliderRow(label: "Sensitivity", value: $config.sensitivity, range: 0.1...3)
                    SliderRow(label: "Smoothing", value: $config.smoothingFactor, range: 0.01...1)
                    SliderRow(label: "Tilt Degrees", value: $config.tiltIntensity, range: 0...45)
                }

                Section("Colors") {
                    ColorPicker("Background", selection: $config.backgroundColor)
                    ColorPicker("Card Base", selection: $config.cardBaseColor)
                }
            }
            .navigationTitle("Controls")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                EditButton()
            }
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
