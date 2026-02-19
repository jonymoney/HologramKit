import SwiftUI

extension View {
    /// Sets the card dimensions.
    public func cardSize(width: CGFloat, height: CGFloat) -> some View {
        environment(\.hologramCardSize, CGSize(width: width, height: height))
    }

    /// Sets the card corner radius.
    public func hologramCornerRadius(_ radius: CGFloat) -> some View {
        environment(\.hologramCornerRadius, radius)
    }

    /// Sets the 3D tilt rotation strength in degrees.
    public func tiltIntensity(_ degrees: Double) -> some View {
        environment(\.hologramTiltIntensity, degrees)
    }

    /// Sets the global parallax movement multiplier.
    public func parallaxIntensity(_ value: CGFloat) -> some View {
        environment(\.hologramParallaxIntensity, value)
    }

    /// Tunes the motion sensor sensitivity and smoothing factor.
    public func motionSensitivity(_ sensitivity: Float, smoothing: Float = 0.15) -> some View {
        environment(\.hologramMotionSensitivity, sensitivity)
            .environment(\.hologramMotionSmoothing, smoothing)
    }

    /// Overrides the motion input source.
    public func motionSource(_ source: MotionSource) -> some View {
        environment(\.hologramMotionSource, source)
    }

    /// Toggles the exploded 3D layer inspector view.
    public func hologramInspector(isPresented: Binding<Bool>) -> some View {
        environment(\.hologramInspectorPresented, isPresented.wrappedValue)
    }
}
