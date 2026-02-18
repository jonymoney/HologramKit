import SwiftUI
import CoreMotion

@Observable
class MotionManager {
    var pitch: Float = 0
    var roll: Float = 0
    var isUsingSimulatedInput = false

    var sensitivity: Float = 1.0
    var smoothingFactor: Float = 0.15

    private let motion = CMMotionManager()

    init() {
        #if targetEnvironment(simulator)
        isUsingSimulatedInput = true
        #endif
    }

    /// Call from .onAppear to start device motion after the view is in the hierarchy.
    func start() {
        #if !targetEnvironment(simulator)
        startDeviceMotion()
        #endif
    }

    func updateSimulatedTilt(x: Float, y: Float) {
        guard isUsingSimulatedInput else { return }
        pitch = x * sensitivity
        roll = y * sensitivity
    }

    // MARK: - Private

    private func startDeviceMotion() {
        guard motion.isDeviceMotionAvailable else {
            isUsingSimulatedInput = true
            return
        }
        motion.deviceMotionUpdateInterval = 1.0 / 60.0
        motion.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let self, let data else { return }
            let rawP = Float(data.attitude.pitch) * self.sensitivity
            let rawR = Float(data.attitude.roll) * self.sensitivity
            // Low-pass filter applied here, not in the view body
            self.pitch += (rawP - self.pitch) * self.smoothingFactor
            self.roll += (rawR - self.roll) * self.smoothingFactor
        }
    }

    deinit {
        motion.stopDeviceMotionUpdates()
    }
}
