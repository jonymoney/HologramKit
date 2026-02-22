#include <metal_stdlib>
using namespace metal;

// --- Helpers (lg-prefixed to avoid linker collisions) ---

static float lgHash(float2 p) {
    float h = dot(p, float2(127.1, 311.7));
    return fract(sin(h) * 43758.5453);
}

static float lgNoise(float2 p) {
    float2 i = floor(p);
    float2 f = fract(p);
    float2 u = f * f * (3.0 - 2.0 * f);

    float a = lgHash(i);
    float b = lgHash(i + float2(1.0, 0.0));
    float c = lgHash(i + float2(0.0, 1.0));
    float d = lgHash(i + float2(1.0, 1.0));

    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// Domain-warped value noise producing caustic-like lines.
// `clarity` controls warp strength: high = sharp caustic lines, low = frosted/diffused.
static float lgCaustic(float2 uv, float time, float clarity) {
    float speed = time * 0.3;

    // Warp pass 1
    float2 warp1 = float2(
        lgNoise(uv * 3.0 + float2(speed, 0.0)),
        lgNoise(uv * 3.0 + float2(0.0, speed * 0.7))
    );

    // Warp pass 2
    float warpStrength = mix(0.15, 0.6, clarity);
    float2 warped = uv + warp1 * warpStrength;
    float2 warp2 = float2(
        lgNoise(warped * 4.0 + float2(-speed * 0.5, speed * 0.3)),
        lgNoise(warped * 4.0 + float2(speed * 0.4, -speed * 0.6))
    );

    // Two octaves for richer pattern
    float2 final_uv = warped + warp2 * warpStrength * 0.5;
    float n1 = lgNoise(final_uv * 5.0);
    float n2 = lgNoise(final_uv * 10.0 + float2(5.2, 1.3));

    float caustic = n1 * 0.7 + n2 * 0.3;

    // Sharpen lines with clarity
    float sharpness = mix(1.0, 4.0, clarity);
    caustic = pow(caustic, sharpness);

    return caustic;
}

// Signed distance to a rounded rectangle centered at origin.
static float lgSdRoundedRect(float2 p, float2 halfSize, float r) {
    float2 q = abs(p) - halfSize + r;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

[[ stitchable ]] half4 smokeGlass(
    float2 position,
    half4 color,
    float2 size,
    float2 tilt,
    float time,
    float refraction,
    float edgeWidth,
    float aberration,
    float clarity,
    float highlightSize,
    float intensity,
    float speed,
    float cornerRadius
) {
    if (color.a < 0.001h) return color;

    float2 uv = position / size;
    float animTime = time * speed;

    // --- Tilt-offset UVs (caustic pattern slides with device motion) ---
    float2 causticUV = uv + tilt * 0.15 * refraction;

    // --- Caustic patterns ---
    float causticCenter = lgCaustic(causticUV, animTime, clarity) * refraction;

    // --- Chromatic aberration ---
    // Offset increases toward edges and near caustic peaks
    float edgeDist = length(uv - 0.5) * 2.0;
    float aberrationOffset = aberration * 0.02 * (0.3 + 0.7 * edgeDist + causticCenter * 0.5);

    float2 dirFromCenter = normalize(uv - 0.5 + 1e-6);
    float2 uvR = causticUV + dirFromCenter * aberrationOffset;
    float2 uvB = causticUV - dirFromCenter * aberrationOffset;

    float causticR = lgCaustic(uvR, animTime, clarity) * refraction;
    float causticB = lgCaustic(uvB, animTime, clarity) * refraction;

    float3 causticRGB = float3(causticR, causticCenter, causticB);

    // --- SDF and boundary fade ---
    float2 center = size * 0.5;
    float sd = -lgSdRoundedRect(position - center, center, cornerRadius);

    // Fade everything to zero within 2px of the card boundary so nothing
    // bleeds at the very edge of the rounded rectangle.
    float boundaryFade = smoothstep(0.0, 2.0, sd);

    // --- Fresnel rim glow ---
    float edgePx = edgeWidth * size.x;
    // Rim band sits just inside the boundary, peaking a few px inward
    float rimInner = smoothstep(edgePx, 0.0, sd);
    float rimOuter = smoothstep(0.0, 3.0, sd);
    float edgeFactor = rimInner * rimOuter;

    // Gradient of SDF for edge normal direction
    float eps = 1.0;
    float sdR = -lgSdRoundedRect(position - center + float2(eps, 0), center, cornerRadius);
    float sdU = -lgSdRoundedRect(position - center + float2(0, eps), center, cornerRadius);
    float2 grad = float2(sdR - sd, sdU - sd) / eps;
    float2 edgeNormal = normalize(grad + 1e-6);

    // Tilt direction — edges facing tilt glow brighter
    float tiltMag = length(tilt);
    float2 tiltDir = tiltMag > 0.001 ? normalize(tilt) : float2(0.0);
    float facing = max(0.0, -dot(edgeNormal, tiltDir));

    float rim = edgeFactor * (0.10 + 0.55 * facing * saturate(tiltMag));

    // Chromatic rim: subtle tint split
    float3 rimRGB = float3(rim * 1.05, rim, rim * 1.08);

    // --- Specular highlight (Gaussian sheen tracking tilt) ---
    float2 shineCenter = float2(0.5 - tilt.x * 0.6, 0.5 - tilt.y * 0.6);
    float shineDist = length(uv - shineCenter);
    float sigma2 = highlightSize * highlightSize * 0.5;
    float shine = exp(-shineDist * shineDist / sigma2) * 0.3;

    // --- Combine ---
    float3 combined = (causticRGB + rimRGB + float3(shine)) * intensity * boundaryFade;
    combined = clamp(combined, 0.0, 1.0);

    // Alpha = perceptual luminance (for .screen blend)
    float lum = combined.r * 0.2126 + combined.g * 0.7152 + combined.b * 0.0722;

    return half4(half3(combined), half(lum));
}
