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

static float2 hash22(float2 p) {
    float2 k = float2(127.1, 311.7);
    return fract(sin(float2(dot(p, k), dot(p, k.yx))) * 43758.5453);
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

// Fractal Brownian Motion — layered noise octaves for richer detail.
static float fbm(float2 p, int octaves) {
    float value = 0.0;
    float amplitude = 0.5;
    for (int i = 0; i < octaves; i++) {
        value += amplitude * noise(p);
        p *= 2.0;
        amplitude *= 0.5;
    }
    return value;
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

    } else if (pType == 4) {
        // Crisscross
        pattern = (sin(uv.x * scale * 10.0) + sin(uv.y * scale * 10.0)) * 0.25;

    } else if (pType == 5) {
        // Fluid — domain-warped noise creating organic marble/oil-slick swirls.
        // Warp UV through multiple noise passes to bend space into flowing rivers.
        float2 q = float2(
            fbm(uv * scale * 3.0, 4),
            fbm(uv * scale * 3.0 + float2(5.2, 1.3), 4)
        );
        float2 r = float2(
            fbm(uv * scale * 3.0 + q * 4.0 + float2(1.7, 9.2), 4),
            fbm(uv * scale * 3.0 + q * 4.0 + float2(8.3, 2.8), 4)
        );
        pattern = fbm(uv * scale * 3.0 + r * 2.0, 4) * 2.0;

    } else if (pType == 6) {
        // Micro-facet — grid of tiny pyramid cells, each with a random surface normal.
        // Color depends on how each facet's normal aligns with the tilt direction.
        float cellScale = scale * 20.0;
        float2 cell = floor(uv * cellScale);
        float2 localUV = fract(uv * cellScale) - 0.5;

        // Random normal per cell (tilted micro-pyramid)
        float2 cellHash = hash22(cell);
        float2 facetNormal = (cellHash - 0.5) * 2.0;

        // Color = dot product of facet normal with tilt + position within facet
        float facetAngle = dot(facetNormal, tilt);
        float localGrad = dot(localUV, normalize(facetNormal + 0.001));

        pattern = (facetAngle * 0.8 + localGrad * 0.4) * scale;

    } else {
        // Waves — overlapping sine waves at different angles creating interference fringes.
        // Like fine-line security holograms on credit cards.
        float w = 0.0;
        float freq = scale * 15.0;
        w += sin(uv.x * freq + uv.y * freq * 0.5);
        w += sin(uv.x * freq * 0.7 - uv.y * freq * 0.9) * 0.8;
        w += sin((uv.x * 0.3 + uv.y) * freq * 1.3) * 0.6;
        w += sin(length(uv - 0.5) * freq * 2.0) * 0.4;
        pattern = w * 0.2;
    }

    // Tilt-driven holographic shift (speed controls tilt sensitivity)
    pattern += tilt.x * speed + tilt.y * speed * 0.6;

    // Static noise for organic feel (reduced for patterns that already have noise)
    if (pType != 5) {
        float n = noise(position * 0.01 * scale);
        pattern += n * 0.15;
    }

    // Map to rainbow via HSV
    float hue = fract(pattern);
    half3 rainbow = hsv2rgb(half3(half(hue), half(saturation), 1.0h));

    half h_intensity = half(intensity);
    half3 blended = mix(color.rgb, rainbow, h_intensity);
    half alpha = color.a * h_intensity;
    return half4(blended * alpha, alpha);
}
