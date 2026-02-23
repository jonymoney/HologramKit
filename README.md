# HologramKit

A SwiftUI framework for building layered, motion-reactive holographic card effects with Metal shaders.

<!-- TODO: Add hero screenshot/gif -->
![HologramKit Hero](screenshots/hero.png)

## Features

- **10 composable layer types** — base, image, content, holographic foil, specular highlight, sparkle, brushed metal, anisotropic light, plastic foil, smoke glass
- **8 holographic patterns** — diagonal, diamond, radial, linear, crisscross, fluid, micro-facet, waves
- **Real-time device motion** — gyroscope-driven tilt with configurable sensitivity and smoothing
- **Parallax depth** — per-layer movement at different rates for a 3D depth illusion
- **3D rotation** — perspective-correct card rotation that tracks device orientation
- **Group compositing** — combine layers with shared blend modes
- **Inspector view** — exploded layer-by-layer visualization for debugging
- **Accessibility** — respects Reduce Motion to freeze all animation and tilt
- **Declarative API** — result builder syntax that feels native to SwiftUI

## Screenshots

<!-- TODO: Replace with actual screenshots -->
| Mount Fuji | Nova | Aqua |
|:---:|:---:|:---:|
| ![Mount Fuji](screenshots/fuji.png) | ![Nova](screenshots/nova.png) | ![Aqua](screenshots/aqua.png) |

## Requirements

- iOS 18.0+
- Xcode 16.0+
- Swift 5.10+

## Installation

### Swift Package Manager

Add HologramKit to your project via Xcode:

1. File > Add Package Dependencies
2. Enter the repository URL
3. Select "Up to Next Major Version" from `0.1.0`

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/<your-org>/HologramKit.git", from: "0.1.0")
]
```

Then add the dependency to your target:

```swift
.target(
    name: "MyApp",
    dependencies: ["HologramKit"]
)
```

## Quick Start

```swift
import SwiftUI
import HologramKit

struct CardView: View {
    var body: some View {
        HologramCard {
            HologramLayer.base(Color(red: 0.1, green: 0.1, blue: 0.15))
            HologramLayer.image(Image("artwork"))
                .parallax(0.3)
            HologramLayer.holographicFoil()
                .intensity(0.8)
                .pattern(.diagonal)
            HologramLayer.specularHighlight()
                .size(0.35)
            HologramLayer.sparkle()
                .density(0.5)
        }
        .cardSize(width: 300, height: 420)
        .hologramCornerRadius(20)
        .tiltIntensity(15)
    }
}
```

## Layer Types

| Layer | Description |
|---|---|
| `.base(Color)` | Solid color foundation |
| `.image(Image)` | Full-bleed artwork |
| `.content { }` | Arbitrary SwiftUI views |
| `.holographicFoil()` | Prismatic rainbow that shifts with tilt |
| `.specularHighlight()` | Radial light reflection tracking orientation |
| `.sparkle()` | Glitter particles with unique catch angles |
| `.brushedMetal()` | Directional grain with anisotropic reflection |
| `.anisotropicLight()` | Stretched light streak along brush direction |
| `.plasticFoil()` | Transparent overlay with edge rims and sliding sheen |
| `.smokeGlass()` | Animated caustics with Fresnel glow and chromatic aberration |

## Modifiers

### Card-Level

```swift
HologramCard { ... }
    .cardSize(width: 300, height: 420)
    .hologramCornerRadius(20)
    .tiltIntensity(15)
    .parallaxIntensity(1.0)
    .motionSensitivity(1.0, smoothing: 0.15)
    .motionSource(.device)           // or .manual(pitch:roll:)
    .hologramInspector(isPresented: $inspecting)
```

### Layer-Level

```swift
// Universal (all layer types)
.parallax(0.5)
.blendMode(.overlay)
.opacity(0.8)

// Holographic foil
.intensity(0.8)
.pattern(.diamond)
.scale(1.0)
.speed(0.5)
.saturation(0.9)
.transparency(0.5)

// Specular
.intensity(0.7)
.size(0.35)
.falloff(1.2)
.color(.white)

// Sparkle
.density(0.5)
.speed(3.0)
.size(1.0)

// Brushed metal / Anisotropic light
.brushAngle(0)
.stretch(8.0)

// Plastic foil
.edgeWidth(0.06)

// Smoke glass
.refraction(0.5)
.aberration(0.3)
.clarity(0.8)
```

## Accessibility

HologramKit automatically reads `accessibilityReduceMotion`. When Reduce Motion is enabled:

- All tilt response freezes (card stays flat)
- Animated shaders (sparkle, smoke glass caustics) show a static frame
- The `TimelineView` animation pauses to save battery
- All layers still render — only motion is removed

## Example App

The `Example/` directory contains **CardLab**, a demo app with three sample cards and a real-time control panel. To run it:

1. Open `Example/CardLab.xcworkspace` in Xcode
2. Set your development team under Signing & Capabilities
3. Run on a physical device for the full gyroscope experience (Simulator supports drag-to-tilt as fallback)

## License

Apache 2.0 — see [LICENSE](LICENSE) for details.
