import Foundation

/// Pattern style for the holographic foil effect layer.
public enum HolographicPattern: Int, CaseIterable, Codable, Sendable {
    case diagonal = 0
    case diamond = 1
    case radial = 2
    case linear = 3
    case crisscross = 4
}
