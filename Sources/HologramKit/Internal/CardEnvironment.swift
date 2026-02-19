import SwiftUI

// MARK: - Environment Keys

struct CardSizeKey: EnvironmentKey {
    nonisolated(unsafe) static var defaultValue = CGSize(width: 300, height: 420)
}

struct CornerRadiusKey: EnvironmentKey {
    nonisolated(unsafe) static var defaultValue: CGFloat = 20
}

struct TiltIntensityKey: EnvironmentKey {
    nonisolated(unsafe) static var defaultValue: Double = 15
}

struct ParallaxIntensityKey: EnvironmentKey {
    nonisolated(unsafe) static var defaultValue: CGFloat = 20
}

struct MotionSourceKey: EnvironmentKey {
    nonisolated(unsafe) static var defaultValue: MotionSource = .device
}

struct MotionSensitivityKey: EnvironmentKey {
    nonisolated(unsafe) static var defaultValue: Float = 1.0
}

struct MotionSmoothingKey: EnvironmentKey {
    nonisolated(unsafe) static var defaultValue: Float = 0.15
}

struct InspectorPresentedKey: EnvironmentKey {
    nonisolated(unsafe) static var defaultValue: Bool = false
}

// MARK: - EnvironmentValues Extensions

extension EnvironmentValues {
    var hologramCardSize: CGSize {
        get { self[CardSizeKey.self] }
        set { self[CardSizeKey.self] = newValue }
    }

    var hologramCornerRadius: CGFloat {
        get { self[CornerRadiusKey.self] }
        set { self[CornerRadiusKey.self] = newValue }
    }

    var hologramTiltIntensity: Double {
        get { self[TiltIntensityKey.self] }
        set { self[TiltIntensityKey.self] = newValue }
    }

    var hologramParallaxIntensity: CGFloat {
        get { self[ParallaxIntensityKey.self] }
        set { self[ParallaxIntensityKey.self] = newValue }
    }

    var hologramMotionSource: MotionSource {
        get { self[MotionSourceKey.self] }
        set { self[MotionSourceKey.self] = newValue }
    }

    var hologramMotionSensitivity: Float {
        get { self[MotionSensitivityKey.self] }
        set { self[MotionSensitivityKey.self] = newValue }
    }

    var hologramMotionSmoothing: Float {
        get { self[MotionSmoothingKey.self] }
        set { self[MotionSmoothingKey.self] = newValue }
    }

    var hologramInspectorPresented: Bool {
        get { self[InspectorPresentedKey.self] }
        set { self[InspectorPresentedKey.self] = newValue }
    }
}
