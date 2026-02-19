import SwiftUI

struct Preset: Codable, Identifiable {
    var id = UUID()
    var name: String
    var snapshot: CardConfiguration.Snapshot
}

@Observable
class PresetStore {
    var presets: [Preset] = []

    private static let key = "savedPresets"

    init() {
        load()
    }

    func save(name: String, config: CardConfiguration) {
        presets.append(Preset(name: name, snapshot: config.makeSnapshot()))
        persist()
    }

    func delete(_ preset: Preset) {
        presets.removeAll { $0.id == preset.id }
        persist()
    }

    func apply(_ preset: Preset, to config: CardConfiguration) {
        config.apply(preset.snapshot)
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(presets) else { return }
        UserDefaults.standard.set(data, forKey: Self.key)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.key),
              let saved = try? JSONDecoder().decode([Preset].self, from: data) else { return }
        presets = saved
    }
}
