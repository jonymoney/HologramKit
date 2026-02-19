import SwiftUI

/// Determines how pitch/roll values are provided to the hologram card.
public enum MotionSource: @unchecked Sendable {
    /// Default — uses CoreMotion device gyroscope.
    case device
    /// Fixed pitch and roll values.
    case manual(pitch: Float, roll: Float)
    /// User-provided motion source.
    case custom(any MotionProviding)
}

/// Protocol for custom motion input sources.
public protocol MotionProviding: Observable {
    var pitch: Float { get }
    var roll: Float { get }
}
