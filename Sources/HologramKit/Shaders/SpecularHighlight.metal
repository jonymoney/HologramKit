#include <metal_stdlib>
using namespace metal;

[[ stitchable ]] half4 specularHighlight(
    float2 position,
    half4 color,
    float2 size,
    float2 tilt,
    float intensity,
    float spotSize,
    float falloff,
    half4 spotColor
) {
    if (color.a < 0.001h) return color;

    float2 uv = position / size;

    // Spot center tracks device tilt
    float2 spotPos = float2(0.5 + tilt.x * 0.4, 0.5 + tilt.y * 0.4);

    float dist = length(uv - spotPos);

    // Radial falloff with configurable curve
    float spot = 1.0 - smoothstep(0.0, spotSize, pow(dist, falloff));
    spot *= intensity;

    return half4(spotColor.rgb * half(spot), half(spot));
}
