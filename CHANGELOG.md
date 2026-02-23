# Changelog

All notable changes to HologramKit will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [0.1.0] - Unreleased

### Added

- **Layer system** with 10 built-in layer types: base, image, content, holographic foil, specular highlight, sparkle, brushed metal, anisotropic light, plastic foil, and smoke glass
- **Group compositing** for combining multiple layers with shared blend modes
- **8 holographic patterns**: diagonal, horizontal, vertical, radial, diamond, wave, chevron, and crosshatch
- **Inspector view** for exploded layer-by-layer visualization
- **Motion-reactive tilt** with device motion and manual/custom motion sources
- **Parallax offsets** per layer for depth effect
- **SwiftUI modifiers** for card size, corner radius, tilt intensity, parallax intensity, motion sensitivity, and motion smoothing
- **`reduceMotion` accessibility support** — freezes all tilt and animation when the system Reduce Motion setting is enabled
- **Example app** (CardLab) with 3 sample cards demonstrating different layer combinations
- **Swift Package** structure with HologramKit framework target
