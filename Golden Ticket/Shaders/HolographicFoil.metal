#include <metal_stdlib>
using namespace metal;

static half3 hsv2rgb(half3 c) {
    half4 K = half4(1.0h, 2.0h / 3.0h, 1.0h / 3.0h, 3.0h);
    half3 p = abs(fract(half3(c.x) + K.xyz) * 6.0h - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0h, 1.0h), c.y);
}

static float hash21(float2 p) {
    return fract(sin(dot(p, float2(127.1, 311.7))) * 43758.5453123);
}

static float noise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash21(i);
    float b = hash21(i + float2(1.0, 0.0));
    float c = hash21(i + float2(0.0, 1.0));
    float d = hash21(i + float2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

[[ stitchable ]] half4 holographicFoil(
    float2 position,
    half4 color,
    float2 size,
    float2 tilt,
    float intensity,
    float scale,
    float speed,
    float saturation,
    float patternType
) {
    if (color.a < 0.001h) return color;

    float2 uv = position / size;

    float pattern;
    int pType = int(patternType);

    if (pType == 0) {
        // Diagonal
        pattern = (uv.x + uv.y) * scale;
    } else if (pType == 1) {
        // Diamond
        pattern = (abs(uv.x - 0.5) + abs(uv.y - 0.5)) * scale * 2.0;
    } else if (pType == 2) {
        // Radial
        pattern = length(uv - float2(0.5)) * scale * 2.0;
    } else if (pType == 3) {
        // Linear
        pattern = uv.x * scale;
    } else {
        // Crisscross
        pattern = (sin(uv.x * scale * 10.0) + sin(uv.y * scale * 10.0)) * 0.25;
    }

    // Tilt-driven holographic shift (speed controls tilt sensitivity)
    pattern += tilt.x * speed + tilt.y * speed * 0.6;

    // Static noise for organic feel
    float n = noise(position * 0.01 * scale);
    pattern += n * 0.15;

    // Map to rainbow via HSV
    float hue = fract(pattern);
    half3 rainbow = hsv2rgb(half3(half(hue), half(saturation), 1.0h));

    half4 result = half4(mix(color.rgb, rainbow, half(intensity)), color.a);
    return result;
}
