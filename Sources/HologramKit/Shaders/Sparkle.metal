#include <metal_stdlib>
using namespace metal;

static float sparkleHash(float2 p) {
    return fract(sin(dot(p, float2(127.1, 311.7))) * 43758.5453123);
}

[[ stitchable ]] half4 sparkle(
    float2 position,
    half4 color,
    float2 size,
    float2 tilt,
    float time,
    float density,
    float speed,
    float sparkleSize
) {
    if (color.a < 0.001h) return color;

    // Grid of potential sparkle points
    float gridSize = mix(20.0, 5.0, density);
    float2 gridPos = floor(position / gridSize);
    float2 gridUV = fract(position / gridSize);

    // Per-cell random properties
    float rand1 = sparkleHash(gridPos);
    float rand2 = sparkleHash(gridPos + float2(42.0, 17.0));
    float rand3 = sparkleHash(gridPos + float2(13.0, 37.0));

    // Sparkle center within cell
    float2 center = float2(rand1, rand2);
    float dist = length(gridUV - center);

    // Each sparkle has a "catch angle" — only visible when tilt aligns
    float catchAngle = rand3 * 6.283185;
    float2 catchDir = float2(cos(catchAngle), sin(catchAngle));
    float2 tiltNorm = normalize(tilt + float2(0.001));
    float alignment = dot(tiltNorm, catchDir);
    alignment = pow(max(alignment, 0.0), 4.0);

    // Twinkle over time
    float twinkle = sin(time * speed * (1.0 + rand1 * 2.0) + rand2 * 6.283185);
    twinkle = max(twinkle, 0.0);

    // Small bright point
    float shape = smoothstep(sparkleSize * 0.08, 0.0, dist);

    float brightness = shape * alignment * twinkle;

    return half4(half3(half(brightness)), half(brightness));
}
