# Golden Ticket

An exploration of holographic card effects built with SwiftUI and Metal shaders on iOS.

## What This Explores

This project experiments with compositing multiple visual layers — each driven by real-time device motion — to create a convincing holographic trading card effect. The card reacts to how you tilt your phone: rainbow foil shifts, specular highlights track the light, and glitter particles catch at different angles.

### Layers

The card is built from several composited layers, bottom to top:

- **Base** — Solid color foundation
- **Image layers** — Composited artwork with per-layer parallax (sun, mountain, flowers)
- **Content** — Text overlay
- **Holographic foil** — Metal shader producing a prismatic rainbow that shifts with tilt (5 pattern types: diagonal, diamond, radial, linear, crisscross)
- **Specular highlight** — Metal shader simulating a radial light reflection that tracks device orientation
- **Sparkle** — Metal shader generating glitter particles, each with a unique "catch angle" that only fires when the tilt aligns

### Techniques

- **Metal shaders via SwiftUI** — `[[ stitchable ]]` functions applied through `.colorEffect()`, no UIKit bridging needed
- **CoreMotion** — 60Hz gyroscope data with low-pass smoothing drives all effects
- **Parallax** — Each layer moves at a different rate based on tilt, creating depth
- **3D rotation** — `rotation3DEffect` with perspective gives the card physical presence
- **Exploded view** — Toggle to separate all layers in 3D space using `anchorZ` for true Z-depth inspection

### Controls

A real-time control panel lets you tune every parameter while the card is live: shader intensity, parallax factors, pattern types, sparkle density, card geometry, motion sensitivity, and more. Presets can be saved and restored.

## Requirements

- iOS 26.0+
- Xcode 26.0+

## Setup

Open `Golden Ticket.xcodeproj` in Xcode, set your development team under Signing & Capabilities, and run on a physical device for the full gyroscope-driven experience. The Simulator supports drag-to-tilt as a fallback.
