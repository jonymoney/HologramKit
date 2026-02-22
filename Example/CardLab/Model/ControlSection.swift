import SwiftUI

struct ControlSection: Identifiable {
    let id = UUID()
    let title: String
    let items: [ControlItem]
}

enum ControlItem: Identifiable {
    case floatSlider(label: String, keyPath: ReferenceWritableKeyPath<CardConfiguration, Float>, range: ClosedRange<Float>, format: String = "%.2f")
    case doubleSlider(label: String, keyPath: ReferenceWritableKeyPath<CardConfiguration, Double>, range: ClosedRange<Double>, format: String = "%.2f")
    case cgFloatSlider(label: String, keyPath: ReferenceWritableKeyPath<CardConfiguration, CGFloat>, range: ClosedRange<CGFloat>, format: String = "%.2f")
    case colorPicker(label: String, keyPath: ReferenceWritableKeyPath<CardConfiguration, Color>)
    case colorGrid(keyPath: ReferenceWritableKeyPath<CardConfiguration, Color>, options: [ColorGridOption])

    var id: String {
        switch self {
        case .floatSlider(let label, let kp, _, _):
            return "float-\(label)-\(kp)"
        case .doubleSlider(let label, let kp, _, _):
            return "double-\(label)-\(kp)"
        case .cgFloatSlider(let label, let kp, _, _):
            return "cgfloat-\(label)-\(kp)"
        case .colorPicker(let label, let kp):
            return "color-\(label)-\(kp)"
        case .colorGrid(let kp, _):
            return "grid-\(kp)"
        }
    }
}

struct ColorGridOption: Identifiable {
    let id: String
    let name: String
    let color: Color
}
