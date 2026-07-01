# Procedural Visual Effects with Metal

This guide documents the reusable, public techniques behind EXP-007 through EXP-009. The examples use native Apple framework APIs and original procedural shaders. They do not depend on captured application assets, weather data, image textures, video, or product-specific presets.

## Architecture

The three experiments use two Metal integration paths:

1. EXP-007 keeps a native SwiftUI `Image(systemName:)` as the source layer and applies a stitchable Metal layer effect.
2. EXP-008 and EXP-009 use `MTKView`, a full-screen triangle, and a fragment shader that computes every output pixel.

`LabSwiftUI` owns presentation and environment state. `MetalRenderKit` owns parameters, shader lookup, the full-screen renderer, and Metal source. `RenderLabCore` provides monotonic, pause-aware elapsed time.

## Applying Metal to an SF Symbol

The symbol is not exported to SVG or converted to a custom path. SwiftUI rasterizes the native `heart.fill` symbol, and a `[[ stitchable ]]` function samples that layer:

```metal
[[ stitchable ]] half4 lab_symbol_light_sweep(
    float2 position,
    SwiftUI::Layer layer,
    float2 size,
    float time,
    float cycleDuration,
    float sweepDuration,
    float angle,
    float softness,
    float intensity
)
```

The shader projects normalized coordinates onto a direction vector. A narrow smooth band moves across that one-dimensional projection during the active part of the cycle. Outside the 1.5-second sweep window, the shader returns the original source unchanged.

Nearby alpha samples provide a restrained glow at the symbol boundary. The SwiftUI view declares a bounded `maxSampleOffset`, which makes the sampling contract explicit.

The package exposes its shader through `ShaderLibrary.bundle(.module)`. This matters in a Swift package because the Metal library belongs to the package resource bundle rather than the app's default shader library.

## Full-Screen Procedural Rendering

The night and ambient-shadow experiments render a single oversized triangle. This avoids a diagonal seam and covers the viewport with three vertices:

```metal
const float2 positions[] = {
    float2(-1.0, -1.0),
    float2(3.0, -1.0),
    float2(-1.0, 3.0),
};
```

Each frame passes a small uniform value containing drawable resolution, elapsed time, motion scale, and a deterministic seed. Resolution is expressed in drawable pixels, while the fragment shader normalizes coordinates and corrects for aspect ratio before evaluating procedural shapes.

The scenes run at 30 fps because their motion is deliberately slow. The renderer skips frames when no drawable, render-pass descriptor, command buffer, or encoder is available.

## Deterministic Stars

The night shader divides the view into a regular cell grid. A hash of each cell and the fixed scene seed determines whether the cell contains a star, its subcell position, radius, color temperature, twinkle phase, and twinkle speed.

This method has three useful properties:

- It does not require a particle buffer or texture.
- The composition is stable across launches.
- Each star can twinkle independently without CPU updates.

Cloud opacity reduces star contribution before cloud color is composited, allowing stars to remain visible in clear areas without shining uniformly through clouds.

## Layered-Noise Clouds

Clouds start with interpolated value noise. Five octaves at increasing spatial frequency create fractional Brownian motion. A second pair of noise samples warps the lookup coordinates before the final cloud sample, which reduces obvious grid structure.

The final density is shaped with a smooth threshold rather than a hard step. Threshold and vertical weighting keep the scene partially cloudy instead of filling the frame. Time changes only the horizontal sample offset, producing slow drift without moving geometry on the CPU.

## Signed-Distance Shadows

EXP-009 builds its shadow mask from signed-distance functions:

- Capsules represent major branches and fine twigs.
- Rotated ellipse distances represent leaves.
- Smooth falloff outside the zero-distance contour represents penumbra.

Major branch endpoints never depend on time. Fine twigs receive a very small displacement. Leaf groups transform in local coordinates with independent phases, directions, and amplitudes. This separation prevents the entire tree from moving like one flat texture.

Each leaf group also varies its penumbra width slightly with wind displacement. The background combines an off-white base, low-amplitude broad illumination, and deterministic high-frequency luminance noise to suggest a physical surface without using a paper texture.

## Time, Inactive Windows, and Reduce Motion

Wall-clock subtraction causes animation jumps after an app resumes. `RenderClock` tracks accumulated paused duration and excludes it from elapsed time. Repeated pause or resume notifications are idempotent.

SwiftUI supplies `scenePhase` and `accessibilityReduceMotion`:

- Inactive views pause their timeline or `MTKView`.
- Reduce Motion renders a deterministic frame with a zero motion scale.
- Resuming continues from the previous animation phase instead of catching up.

## Verification

Parameter models are tested independently from GPU rendering. Registry tests guarantee every public experiment has a destination and stable ordering. `swift test` verifies CPU behavior, while the macOS Xcode build compiles the package Metal library and links the native app.

Use:

```bash
swift test
./Scripts/lint.sh
./Scripts/verify_public_boundary.sh
xcodebuild -quiet \
  -project Apps/MetalAnimationLabmacOS/MetalAnimationLabmacOS.xcodeproj \
  -scheme MetalAnimationLabmacOS \
  -configuration Debug \
  build CODE_SIGNING_ALLOWED=NO
```

Runtime review remains necessary for composition, contrast, cadence, resize behavior, and accessibility behavior because those qualities are not captured by unit tests.

## iOS Follow-Up

The shader and renderer code is shared. An iOS pass mainly needs device performance checks, safe-area-aware presentation, lifecycle verification, and tuning for smaller screens. No weather or location framework is required.
