#include <metal_stdlib>
using namespace metal;

/// Anisotropic light reflection — a light source whose reflection stretches
/// along the brush/grain direction of a surface.
///
/// A circular light becomes an elongated streak on brushed metal, just like
/// real life. The reflection position tracks device tilt.
[[ stitchable ]] half4 anisotropicLight(
    float2 position,
    half4 color,
    float2 size,
    float2 tilt,        // (roll, pitch) from MotionManager
    float intensity,    // brightness of the reflection (0–1)
    float lightSize,    // apparent size of the light source
    float stretch,      // anisotropic ratio (1 = circular, higher = more streak)
    float brushAngle,   // surface grain direction in radians (0 = horizontal)
    float softness,     // falloff curve (higher = sharper edge, lower = softer)
    half4 lightColor    // color of the light source
) {
    if (color.a < 0.001h) return color;

    float2 uv = position / size;

    // Light source position tracks device tilt
    float2 lightPos = float2(0.5 + tilt.x * 0.4, 0.5 + tilt.y * 0.4);
    float2 delta = uv - lightPos;

    // Rotate delta into brush-aligned space
    float ca = cos(brushAngle);
    float sa = sin(brushAngle);
    float2 brushDelta = float2(
        delta.x * ca + delta.y * sa,    // along brush direction
       -delta.x * sa + delta.y * ca     // perpendicular to brush
    );

    // Anisotropic distance: compress along brush direction
    // This stretches a circular source into a streak along the grain
    float2 anisoDelta = float2(
        brushDelta.x / max(stretch, 0.01),
        brushDelta.y
    );
    float dist = length(anisoDelta);

    // Smooth falloff with configurable softness
    float radius = max(lightSize, 0.001);
    float falloff = exp(-pow(dist / radius, softness));

    float brightness = falloff * intensity;

    return half4(lightColor.rgb * half(brightness), half(brightness));
}
