#include <metal_stdlib>
using namespace metal;

// Signed distance to a rounded rectangle centered at origin.
// `halfSize` = half the card dimensions, `r` = corner radius.
static float sdRoundedRect(float2 p, float2 halfSize, float r) {
    float2 q = abs(p) - halfSize + r;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

[[ stitchable ]] half4 plasticFoil(
    float2 position,
    half4 color,
    float2 size,
    float2 tilt,
    float edgeWidth,
    float intensity,
    float shineSize,
    float cornerRadius
) {
    if (color.a < 0.001h) return color;

    float2 uv = position / size;

    // Pixel-space signed distance from the rounded-rect border.
    // Negative inside, zero on edge, positive outside.
    float2 center = size * 0.5;
    float sd = -sdRoundedRect(position - center, center, cornerRadius);

    // Normalize to a 0..1 ramp over `edgeWidth` (fraction of card width)
    float edgePx = edgeWidth * size.x;
    float edgeFactor = 1.0 - smoothstep(0.0, edgePx, sd);

    // --- Directional edge lighting ---
    // Compute which direction the nearest edge faces (gradient of the SDF).
    // Edges whose outward normal aligns with the tilt catch more light.
    float eps = 1.0;
    float sdR = -sdRoundedRect(position - center + float2(eps, 0), center, cornerRadius);
    float sdU = -sdRoundedRect(position - center + float2(0, eps), center, cornerRadius);
    float2 grad = float2(sdR - sd, sdU - sd) / eps;
    float2 edgeNormal = normalize(grad + 1e-6);

    // Tilt direction = which way the card leans.
    // Edges facing the tilt direction catch light (like Fresnel).
    float tiltMag = length(tilt);
    float2 tiltDir = tiltMag > 0.001 ? normalize(tilt) : float2(0.0);
    float facing = max(0.0, -dot(edgeNormal, tiltDir));

    // Dim base rim + strong directional highlight
    float rim = edgeFactor * (0.15 + 0.85 * facing * tiltMag);

    // --- Broad specular sheen ---
    float2 shineCenter = float2(0.5 - tilt.x * 0.6, 0.5 - tilt.y * 0.6);
    float shineDist = length(uv - shineCenter);
    float sigma2 = shineSize * shineSize * 0.5;
    float shine = exp(-shineDist * shineDist / sigma2) * 0.25;

    // --- Combine ---
    float effect = clamp((rim + shine) * intensity, 0.0, 1.0);

    half3 col = half3(1.0h, 0.98h, 0.96h) * half(effect);

    return half4(col, half(effect));
}
