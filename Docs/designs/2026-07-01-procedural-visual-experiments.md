# Procedural Visual Experiments Design

Status: approved for implementation planning

Date: 2026-07-01

## Purpose

Add three macOS-first teaching experiments that demonstrate procedural visual effects driven by Metal while preserving the repository's shared SwiftUI and reusable-rendering architecture.

The experiments are:

- EXP-007: SF Symbol Light Sweep
- EXP-008: Procedural Night Sky
- EXP-009: Ambient Light and Shadow

The implementations remain generic and suitable for this public MIT-licensed laboratory. They do not contain product-specific shaders, copied application resources, weather data, screenshots, videos, or private presets.

## Scope

The first implementation targets the existing macOS 14 application. Shared package boundaries must remain compatible with a later iOS 17 presentation pass, but iOS UI verification is not part of this milestone.

### Goals

- Use Metal for the core visual computation in all three experiments.
- Use the native `heart.fill` SF Symbol directly rather than exporting or redrawing it.
- Generate the night sky, partial cloud cover, branch shadows, and leaf shadows procedurally.
- Keep each experiment independently understandable and navigable from the existing lab.
- Respect Reduce Motion and pause continuous work when the app is inactive.
- Preserve the repository's public/private boundary.

### Non-goals

- Weather data, location, temperature, alerts, or condition switching.
- Pixel-for-pixel reproduction of another application's animation.
- Image, video, or audio assets.
- User-authored shader presets or a general-purpose visual editor.
- iOS-specific layout and performance tuning in this milestone.

## Repository Integration

The new experiments follow the current native-shell/shared-core decision:

- `AnimationPlayground` registers EXP-007 through EXP-009.
- `LabSwiftUI` owns the experiment pages and SwiftUI lifecycle integration.
- `MetalRenderKit` owns shader functions, renderers, uniforms, and reusable parameter models.
- The macOS AppKit shell continues to host `LabRootView` without experiment-specific code.

The existing `MetalViewRepresentable` gains focused destinations for the two full-screen procedural scenes. The symbol experiment uses SwiftUI's Metal shader integration so the native SF Symbol remains the source layer.

## EXP-007: SF Symbol Light Sweep

### Visual behavior

- Display the native `heart.fill` symbol in a neutral gray on a dark preview surface.
- Preserve the symbol's original silhouette and base color.
- Sweep a narrow, soft white light diagonally across the symbol.
- Add only a restrained cool outer glow near the moving light band.
- Repeat on a low-frequency cycle: approximately 1.5 seconds of motion within a 10-second cycle.
- Hold a static appearance between sweeps; do not simulate metal, prism, or pearl material.

### Rendering design

`LabSwiftUI` creates `Image(systemName: "heart.fill")`. A `[[ stitchable ]]` layer-effect shader in `MetalRenderKit` receives the source layer, position, bounds, elapsed time, cycle duration, sweep duration, angle, softness, and intensity.

The shader computes a signed distance to the animated diagonal light band, shapes it with smooth falloff, raises luminance only inside the symbol, and emits a small bounded glow. The SwiftUI layer remains responsible for the SF Symbol rasterization; no exported symbol asset is stored in the repository.

## EXP-008: Procedural Night Sky

### Visual behavior

- Show stars and partial clouds simultaneously in one fixed night scene.
- Use a low-saturation deep-blue background.
- Keep stars crisp with restrained variation in size, color temperature, and twinkle phase.
- Cover approximately 30 percent of the scene with low-contrast cloud forms.
- Drift the cloud field slowly and predominantly horizontally.
- Use a fixed seed so the initial composition is stable across launches.
- Display no weather controls, labels, or data.

### Rendering design

An `MTKView` renders one full-screen triangle. A Metal fragment shader receives resolution, elapsed time, seed, motion scale, and Reduce Motion state.

The shader builds stars from deterministic spatial hashing and independent twinkle phases. Clouds use layered value noise or gradient noise with domain warping and smooth thresholding. The result is composited in a single full-screen pass for the initial implementation. If profiling shows that the octave count is too expensive, quality is reduced through parameter selection rather than by introducing image assets.

The scene targets 30 frames per second because all motion is slow and continuous. Resolution and time calculations remain independent of backing scale and window size.

## EXP-009: Ambient Light and Shadow

### Visual behavior

- Present an off-white, subtly textured surface without text.
- Keep trunk and major branch shadows stationary.
- Allow only very small movement in fine terminal twigs.
- Move leaf clusters independently with different wind phases, directions, and amplitudes.
- Slightly vary penumbra width as leaves move, suggesting changing distance from the lit surface.
- Keep the overall contrast low and the motion calm.

### Rendering design

An `MTKView` renders a full-screen procedural shadow scene. Major branches are constructed from fixed signed-distance capsules or tapered curve approximations. Leaf clusters use repeated oriented ellipse distance fields grouped around deterministic anchors.

A low-frequency wind field changes each leaf group's rotation and offset independently. Fine twigs receive a much smaller deformation derived from the same field. Major branches do not receive time-dependent transforms. The shadow mask is softened with analytic distance falloff and composited over a procedural paper-like luminance texture.

The experiment uses fixed seeds and contains no plant texture, photograph, SVG, or video.

## Shared Runtime Behavior

Each animated view reads `scenePhase` and `accessibilityReduceMotion` from SwiftUI:

- Active plus normal motion: advance elapsed time and render at the experiment's preferred cadence.
- Inactive or background: pause the timeline or `MTKView`.
- Reduce Motion enabled: render a deterministic static frame with no sweep, twinkle, cloud drift, twig movement, or leaf movement.

Time values come from a monotonic render clock so pausing does not cause a visible jump when rendering resumes.

## Parameters and Boundaries

Small Sendable parameter values define the public experiment defaults. Parameters are validated or clamped before reaching Metal uniforms.

Initial defaults:

| Experiment | Parameter | Default |
| --- | --- | --- |
| EXP-007 | cycle duration | 10 seconds |
| EXP-007 | sweep duration | 1.5 seconds |
| EXP-007 | light style | narrow soft white |
| EXP-008 | cloud coverage | approximately 30 percent |
| EXP-008 | preferred cadence | 30 fps |
| EXP-008 | scene seed | fixed repository constant |
| EXP-009 | major branch motion | none |
| EXP-009 | fine twig motion | very low amplitude |
| EXP-009 | leaf cluster motion | low amplitude, independent phases |
| EXP-009 | preferred cadence | 30 fps |

The experiment pages intentionally omit tuning controls in the first version. The fixed defaults make the examples focused and the results reproducible.

## Error Handling

- If Metal is unavailable or a pipeline cannot be created, show the existing error-colored fallback surface plus a concise unavailable message.
- Do not silently replace a Metal experiment with a non-Metal implementation.
- Treat missing shader functions and pipeline creation errors as test or build failures.
- Clamp zero-sized drawables to safe dimensions and skip frames without a drawable or render-pass descriptor.

## Verification

Automated verification includes:

- Registry order and destination coverage for EXP-007 through EXP-009.
- Default parameter and clamping tests.
- Deterministic seed and static Reduce Motion parameter tests.
- Shader compilation as part of package and application builds.
- Existing `swift test`, lint, and public-boundary checks.

Manual macOS verification includes:

- Launch the native app and navigate to all three experiments.
- Confirm EXP-007 uses the native heart symbol and repeats one soft sweep per low-frequency cycle.
- Confirm EXP-008 displays stars and clouds together without any weather data.
- Confirm EXP-009 keeps major branches fixed while leaf groups move independently.
- Resize the window and verify aspect-correct rendering without stretching.
- Deactivate and reactivate the app and verify animation pauses and resumes without a time jump.
- Enable Reduce Motion and verify each experiment becomes static.

## Acceptance Criteria

The milestone is complete when all three experiments are discoverable in the macOS lab, their core visual computation is implemented in Metal, all automated checks pass, and the verified visual behavior matches the descriptions above without introducing external assets or private/product-specific content.
