import SwiftUI
import CoreMotion

@Observable
final class MotionManager {
    var pitch: Float = 0
    var roll: Float = 0

    var sensitivity: Float = 1.0
    var smoothingFactor: Float = 0.15

    private let motion = CMMotionManager()
    private var isRunning = false

    func start() {
        guard !isRunning else { return }
        isRunning = true
        #if !targetEnvironment(simulator)
        startDeviceMotion()
        #endif
    }

    func updateSimulatedTilt(x: Float, y: Float) {
        pitch = x * sensitivity
        roll = y * sensitivity
    }

    private func startDeviceMotion() {
        guard motion.isDeviceMotionAvailable else { return }
        motion.deviceMotionUpdateInterval = 1.0 / 60.0
        motion.startDeviceMotionUpdates(to: .main) { [weak self] data, _ in
            guard let self, let data else { return }
            let rawP = Float(data.attitude.pitch) * self.sensitivity
            let rawR = Float(data.attitude.roll) * self.sensitivity
            self.pitch += (rawP - self.pitch) * self.smoothingFactor
            self.roll += (rawR - self.roll) * self.smoothingFactor
        }
    }

    deinit {
        motion.stopDeviceMotionUpdates()
    }
}
