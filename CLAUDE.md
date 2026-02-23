# HologramKit

A SwiftUI framework for layered, motion-reactive holographic card effects using Metal shaders.

## Project Structure

```
Sources/HologramKit/
├── API/              # Public surface: HologramCard, HologramLayer, Modifiers, MotionSource, HolographicPattern
├── Internal/         # LayerRenderer, MotionManager, CardEnvironment, InspectorModifier, ShaderLibrary+Bundle
└── Shaders/          # 7 Metal shaders (all [[ stitchable ]], applied via .colorEffect())

Tests/HologramKitTests/
└── HologramLayerBuilderTests.swift   # Swift Testing (@Suite, @Test)

Example/
├── CardLab/          # Demo app with 3 sample cards and real-time control panel
├── CardLab.xcodeproj
└── CardLab.xcworkspace
```

## Build & Test

This is an **iOS-only** package. `swift build` / `swift test` will fail on macOS because SwiftUI, Metal shaders, and CoreMotion aren't available for the macOS target. Always use `xcodebuild`.

```bash
# Build the framework
xcodebuild build -scheme HologramKit -destination 'platform=iOS Simulator,name=iPhone 16'

# Run tests
xcodebuild test -scheme HologramKit -destination 'platform=iOS Simulator,name=iPhone 16' -skipPackagePluginValidation

# Build the example app
xcodebuild -workspace Example/CardLab.xcworkspace -scheme CardLab -destination 'generic/platform=iOS' build
```

## Lint

SwiftLint is configured via `.swiftlint.yml`. Run with:

```bash
swiftlint lint
```

Must report 0 violations before committing.

## Key Architecture Decisions

- **Swift tools version 6.0** with **Swift 5 language mode** (`swiftLanguageMode(.v5)`) — avoids strict concurrency errors for consumers on Swift 5 projects.
- **Minimum deployment: iOS 18** — API floor is technically iOS 17 (@Observable, [[ stitchable ]] shaders, ShaderLibrary, 3-param onChange), but declared as iOS 18.
- **Metal shaders are bundled as SPM resources** via `.process("Shaders")` and accessed through `ShaderLibrary.bundle(.module)` (see `ShaderLibrary+Bundle.swift`).
- **`MotionManager` uses `@Observable`** (not ObservableObject) — requires Observation framework (iOS 17+).
- **`MotionSource.custom(any MotionProviding)`** uses `@unchecked Sendable` because the existential can't be proven Sendable.
- **`accessibilityReduceMotion`** freezes all tilt, animation time, and pauses the TimelineView.

## Conventions

- Public API lives in `Sources/HologramKit/API/`, internal implementation in `Sources/HologramKit/Internal/`.
- All public types and methods have `///` doc comments with parameter ranges and defaults.
- Layer modifiers use copy-on-write pattern: `var copy = self; copy.field = value; return copy`.
- Shader parameters use short names (`r`, `p`, `sd`) — `identifier_name` lint rule is disabled.
- `LayerRenderer.render()` is intentionally large (175 lines, one big switch) — `function_body_length` and `cyclomatic_complexity` limits are raised in `.swiftlint.yml`.
- Tests use Swift Testing framework (`import Testing`, `@Suite`, `@Test`, `#expect`), not XCTest.
- The Example app references HologramKit via a local SPM path (`..`). Contributors must clone the whole repo.
