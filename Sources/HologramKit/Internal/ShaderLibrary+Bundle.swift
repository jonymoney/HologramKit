import SwiftUI

/// Bundle-aware shader loading so Metal shaders resolve from the SPM resource bundle.
@dynamicMemberLookup
enum HologramShaderLibrary {
    static subscript(dynamicMember name: String) -> ShaderFunction {
        ShaderLibrary.bundle(.module)[dynamicMember: name]
    }
}
