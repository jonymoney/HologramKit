#include <metal_stdlib>
using namespace metal;

static float hash21(float2 p) {
    return fract(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
}

// 2-D value noise with hermite interpolation
static float noise2D(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash21(i);
    float b = hash21(i + float2(1.0, 0.0));
    float c = hash21(i + float2(0.0, 1.0));
    float d = hash21(i + float2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

[[ stitchable ]] half4 brushedMetal(
    float2 position,
    half4 color,
    float2 size,
    float2 tilt,        // (roll, pitch) — unused now, kept for interface stability
    float grainScale,   // density of brush lines (default 1.0)
    float reflectivity, // controls grain contrast (0 = flat, 1 = pronounced)
    float brushAngle    // direction of grain in radians (0 = horizontal)
) {
    if (color.a < 0.001h) return color;

    float ca = cos(brushAngle);
    float sa = sin(brushAngle);

    // Pixel-space coordinates aligned to brush direction
    float perpPx  = (position.y * ca - position.x * sa) * grainScale;
    float alongPx = (position.x * ca + position.y * sa) * grainScale;

    // --- Irregular directional grain ---
    // Stretched 2-D noise: high frequency perpendicular to brush,
    // low frequency along brush — elongated, irregular scratches.
    float grain = 0.0;
    grain += noise2D(float2(alongPx * 0.02, perpPx * 0.3))  * 0.30;  // broad patches
    grain += noise2D(float2(alongPx * 0.08, perpPx * 1.5))  * 0.30;  // medium streaks
    grain += noise2D(float2(alongPx * 0.3,  perpPx * 6.0))  * 0.25;  // fine scratches
    grain += noise2D(float2(alongPx * 0.8,  perpPx * 20.0)) * 0.15;  // micro detail

    // Uniform grain visibility — reflectivity controls how pronounced the texture is
    float contrast = reflectivity * 0.15;
    float surface = grain * contrast + (1.0 - contrast * 0.5);

    return half4(color.rgb * half(surface), color.a);
}
