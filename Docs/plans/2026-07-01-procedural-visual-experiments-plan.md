# Procedural Visual Experiments Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add three macOS-first Metal experiments for a native SF Symbol light sweep, a procedural star-and-cloud night scene, and procedural branch-and-leaf shadows.

**Architecture:** Keep experiment discovery and pages in the existing `AnimationPlayground` and `LabSwiftUI` targets. Put parameter models, shader access, full-screen renderers, and `.metal` functions in `MetalRenderKit`; use SwiftUI's layer-effect bridge only to supply the native SF Symbol source layer. Extend `RenderClock` so inactive rendering pauses without a time jump.

**Tech Stack:** Swift 6, SwiftUI, AppKit shell, Metal, MetalKit, Swift Testing, SwiftPM.

---

## File Map

- Modify `Packages/RenderLabCore/RenderClock.swift`: add explicit pause and resume accounting.
- Modify `Packages/RenderLabCoreTests/RenderClockTests.swift`: prove paused time is excluded.
- Create `Packages/MetalRenderKit/Core/VisualExperimentParameters.swift`: validated defaults for all three experiments.
- Create `Packages/MetalRenderKitTests/VisualExperimentParametersTests.swift`: parameter validation tests.
- Create `Packages/MetalRenderKit/SwiftUI/LabShaderLibrary.swift`: public SwiftUI shader factory bound to `Bundle.module`.
- Modify `Packages/MetalRenderKit/Shaders/LabShaders.metal`: add the stitchable light sweep and two procedural fragment shaders.
- Create `Packages/MetalRenderKit/Renderer/ProceduralSceneRenderer.swift`: focused full-screen renderer for night and ambient-shadow scenes.
- Modify `Packages/LabSwiftUI/PlatformRepresentables.swift`: install and update the new Metal scenes.
- Create `Packages/LabSwiftUI/Views/SymbolLightSweepExperimentView.swift`: native SF Symbol plus Metal layer effect.
- Create `Packages/LabSwiftUI/Views/NightSkyExperimentView.swift`: night-scene page.
- Create `Packages/LabSwiftUI/Views/AmbientShadowExperimentView.swift`: branch-and-leaf-shadow page.
- Modify `Packages/AnimationPlayground/DemoRegistry.swift`: register EXP-007 through EXP-009.
- Modify `Packages/LabSwiftUI/ExperimentDestination.swift`: add typed destinations.
- Modify `Packages/LabSwiftUI/ExperimentDetailView.swift`: route to the new pages.
- Modify `Packages/AnimationPlaygroundTests/DemoRegistryTests.swift`: lock the new stable order.
- Modify `Packages/LabSwiftUITests/ExperimentDestinationTests.swift`: retain registry/destination parity.
- Create `Experiments/EXP-007-SF-Symbol-Light-Sweep/README.md` and `Result.md`: describe the experiment and verified result.
- Create `Experiments/EXP-008-Procedural-Night-Sky/README.md` and `Result.md`: describe the experiment and verified result.
- Create `Experiments/EXP-009-Ambient-Light-Shadow/README.md` and `Result.md`: describe the experiment and verified result.
- Modify `README.md` and `Docs/00-Index.md`: expose the new experiments.

### Task 1: Make the Render Clock Pause-Aware

**Files:**
- Modify: `Packages/RenderLabCore/RenderClock.swift`
- Modify: `Packages/RenderLabCoreTests/RenderClockTests.swift`

- [ ] **Step 1: Write the failing pause tests**

Add tests that establish the clock at time 10, pause at 12, resume at 20, and expect elapsed time 4 at timestamp 22. Add a second test proving repeated identical pause state changes do not alter elapsed time.

```swift
@Test
func renderClockExcludesPausedDuration() {
    var clock = RenderClock()
    #expect(clock.elapsedTime(at: 10) == 0)
    #expect(clock.elapsedTime(at: 12) == 2)
    clock.setPaused(true, at: 12)
    #expect(clock.elapsedTime(at: 18) == 2)
    clock.setPaused(false, at: 20)
    #expect(clock.elapsedTime(at: 22) == 4)
}

@Test
func renderClockIgnoresRepeatedPauseState() {
    var clock = RenderClock()
    _ = clock.elapsedTime(at: 4)
    clock.setPaused(true, at: 5)
    clock.setPaused(true, at: 7)
    clock.setPaused(false, at: 9)
    clock.setPaused(false, at: 11)
    #expect(clock.elapsedTime(at: 12) == 4)
}
```

- [ ] **Step 2: Run the focused tests and verify failure**

Run: `swift test --filter RenderClock`

Expected: compilation fails because `RenderClock` has no `setPaused(_:at:)` method.

- [ ] **Step 3: Implement pause accounting**

Add `pausedAt`, `accumulatedPause`, and `setPaused(_:at:)`. Compute elapsed time by subtracting accumulated paused duration and the current open pause interval from the monotonic timestamp.

```swift
private var pausedAt: TimeInterval?
private var accumulatedPause: TimeInterval = 0

public mutating func setPaused(_ isPaused: Bool, at timestamp: TimeInterval) {
    if isPaused {
        guard pausedAt == nil else { return }
        pausedAt = timestamp
    } else if let pausedAt {
        accumulatedPause += max(0, timestamp - pausedAt)
        self.pausedAt = nil
    }
}
```

Update `elapsedTime(at:)` to subtract `accumulatedPause` and, when paused, `timestamp - pausedAt`.

- [ ] **Step 4: Run the focused and full tests**

Run: `swift test --filter RenderClock && swift test`

Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add Packages/RenderLabCore/RenderClock.swift Packages/RenderLabCoreTests/RenderClockTests.swift
git commit -m "feat: pause render clock without time jumps"
```

### Task 2: Add Validated Visual Experiment Parameters

**Files:**
- Create: `Packages/MetalRenderKit/Core/VisualExperimentParameters.swift`
- Create: `Packages/MetalRenderKitTests/VisualExperimentParametersTests.swift`

- [ ] **Step 1: Write failing parameter tests**

Test the standard defaults and invalid-input clamping:

```swift
@Test
func symbolLightSweepDefaultsUseLowFrequencyCycle() {
    let value = SymbolLightSweepParameters.standard
    #expect(value.cycleDuration == 10)
    #expect(value.sweepDuration == 1.5)
}

@Test
func proceduralSceneParametersClampRuntimeValues() {
    let value = ProceduralSceneParameters(
        seed: 7,
        preferredFramesPerSecond: 0,
        motionScale: -2
    )
    #expect(value.preferredFramesPerSecond == 1)
    #expect(value.motionScale == 0)
}
```

- [ ] **Step 2: Run the focused tests and verify failure**

Run: `swift test --filter VisualExperimentParameters`

Expected: compilation fails because the parameter types do not exist.

- [ ] **Step 3: Implement focused Sendable values**

Define:

```swift
public struct SymbolLightSweepParameters: Equatable, Sendable {
    public static let standard = SymbolLightSweepParameters()
    public let cycleDuration: Float
    public let sweepDuration: Float
    public let angle: Float
    public let softness: Float
    public let intensity: Float
}

public struct ProceduralSceneParameters: Equatable, Sendable {
    public let seed: UInt32
    public let preferredFramesPerSecond: Int
    public let motionScale: Float
}
```

Clamp cycle duration to at least 1 second, sweep duration to `0.1 ... cycleDuration`, softness to `0.001 ... 1`, intensity to `0 ... 2`, preferred FPS to `1 ... 120`, and motion scale to `0 ... 2`. Provide `.nightSky` and `.ambientShadow` defaults with fixed seeds, 30 fps, and motion scale 1.

- [ ] **Step 4: Run tests**

Run: `swift test --filter VisualExperimentParameters && swift test`

Expected: all tests pass.

- [ ] **Step 5: Commit**

```bash
git add Packages/MetalRenderKit/Core/VisualExperimentParameters.swift Packages/MetalRenderKitTests/VisualExperimentParametersTests.swift
git commit -m "feat: define procedural experiment parameters"
```

### Task 3: Implement EXP-007 SF Symbol Light Sweep

**Files:**
- Create: `Packages/MetalRenderKit/SwiftUI/LabShaderLibrary.swift`
- Modify: `Packages/MetalRenderKit/Shaders/LabShaders.metal`
- Create: `Packages/LabSwiftUI/Views/SymbolLightSweepExperimentView.swift`
- Modify: `Packages/AnimationPlayground/DemoRegistry.swift`
- Modify: `Packages/LabSwiftUI/ExperimentDestination.swift`
- Modify: `Packages/LabSwiftUI/ExperimentDetailView.swift`
- Modify: `Packages/AnimationPlaygroundTests/DemoRegistryTests.swift`

- [ ] **Step 1: Extend the registry-order test with EXP-007**

Expected IDs become `EXP-001` through `EXP-007` in order.

- [ ] **Step 2: Run the registry test and verify failure**

Run: `swift test --filter registryKeepsStableExperimentOrder`

Expected: the actual registry ends at EXP-006.

- [ ] **Step 3: Add the stitchable shader and Swift factory**

The Metal function signature is:

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

Normalize position by size, compute phase with `fmod(time, cycleDuration)`, move a diagonal band only while `phase <= sweepDuration`, and return the unchanged source color while idle. During the sweep, add a smooth white luminance term multiplied by source alpha. Sample nearby alpha at four offsets to produce a bounded cool glow without changing the symbol silhouette.

Expose the function through:

```swift
public enum LabShaderLibrary {
    public static func symbolLightSweep(
        size: CGSize,
        time: Float,
        parameters: SymbolLightSweepParameters
    ) -> Shader {
        Shader(
            function: ShaderFunction(
                library: .bundle(.module),
                name: "lab_symbol_light_sweep"
            ),
            arguments: [
                .float2(size), .float(time),
                .float(parameters.cycleDuration),
                .float(parameters.sweepDuration),
                .float(parameters.angle),
                .float(parameters.softness),
                .float(parameters.intensity),
            ]
        )
    }
}
```

- [ ] **Step 4: Add the experiment page and routing**

Use `TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: ...))`, `GeometryReader`, and `Image(systemName: "heart.fill")`. Add transparent padding before `.layerEffect` so the shader has room for bounded glow. Read `scenePhase` and `accessibilityReduceMotion`; pass time zero when reduced motion is enabled.

Register EXP-007 as a non-required Metal experiment and add `.symbolLightSweep` routing.

- [ ] **Step 5: Build and run tests**

Run: `swift test && xcodebuild -project Apps/MetalAnimationLabmacOS/MetalAnimationLabmacOS.xcodeproj -scheme MetalAnimationLabmacOS -configuration Debug build CODE_SIGNING_ALLOWED=NO`

Expected: shader compiles, tests pass, and the macOS target builds.

- [ ] **Step 6: Commit**

```bash
git add Packages/MetalRenderKit Packages/LabSwiftUI Packages/AnimationPlayground Packages/AnimationPlaygroundTests
git commit -m "feat: add SF Symbol light sweep experiment"
```

### Task 4: Implement the Full-Screen Procedural Renderer and EXP-008

**Files:**
- Create: `Packages/MetalRenderKit/Renderer/ProceduralSceneRenderer.swift`
- Modify: `Packages/MetalRenderKit/Shaders/LabShaders.metal`
- Modify: `Packages/LabSwiftUI/PlatformRepresentables.swift`
- Create: `Packages/LabSwiftUI/Views/NightSkyExperimentView.swift`
- Modify: `Packages/AnimationPlayground/DemoRegistry.swift`
- Modify: `Packages/LabSwiftUI/ExperimentDestination.swift`
- Modify: `Packages/LabSwiftUI/ExperimentDetailView.swift`
- Modify: `Packages/AnimationPlaygroundTests/DemoRegistryTests.swift`

- [ ] **Step 1: Extend the registry-order test through EXP-008**

Run: `swift test --filter registryKeepsStableExperimentOrder`

Expected: failure because EXP-008 is absent.

- [ ] **Step 2: Implement a focused full-screen renderer**

Define `ProceduralSceneKind` with `.nightSky` and `.ambientShadow`, each mapping to a fragment-function name and clear color. Define a 16-byte-aligned uniform value containing `resolution`, `time`, `motionScale`, and `seed`.

`ProceduralSceneRenderer` must:

- create a pipeline from `lab_fullscreen_vertex` and the selected fragment function;
- set 30 fps from `ProceduralSceneParameters`;
- pass the uniform value at fragment buffer index 0;
- expose `setPaused(_:at:)` and `setReduceMotion(_:)`;
- use `RenderClock` so resumed scenes do not jump;
- skip drawing without a descriptor, drawable, command buffer, or encoder.

- [ ] **Step 3: Add the procedural night shader**

Add `lab_night_sky_fragment`. Correct aspect ratio before evaluating spatial functions. Build deterministic stars from hashed grid cells and independently phased twinkle. Build clouds from four to five octaves of value noise, apply low-amplitude domain warping, move the sample position horizontally with time, threshold to approximately 30 percent coverage, and blend a desaturated blue-gray cloud color over the deep-blue background.

When `motionScale` is zero, use time zero for twinkle and cloud drift.

- [ ] **Step 4: Install the scene and page**

Extend `MetalDemoKind` and `MetalViewCoordinator` with `.nightSky`. Pass scene activity and Reduce Motion state through `MetalViewRepresentable` updates. Create `NightSkyExperimentView` with a minimum height of 420, rounded clipping, and a concise technique caption.

Register and route EXP-008.

- [ ] **Step 5: Verify**

Run: `swift test && xcodebuild -project Apps/MetalAnimationLabmacOS/MetalAnimationLabmacOS.xcodeproj -scheme MetalAnimationLabmacOS -configuration Debug build CODE_SIGNING_ALLOWED=NO`

Expected: tests pass and the app builds with the night shader in the package library.

- [ ] **Step 6: Commit**

```bash
git add Packages/MetalRenderKit Packages/LabSwiftUI Packages/AnimationPlayground Packages/AnimationPlaygroundTests
git commit -m "feat: add procedural night sky experiment"
```

### Task 5: Implement EXP-009 Ambient Light and Shadow

**Files:**
- Modify: `Packages/MetalRenderKit/Shaders/LabShaders.metal`
- Modify: `Packages/LabSwiftUI/PlatformRepresentables.swift`
- Create: `Packages/LabSwiftUI/Views/AmbientShadowExperimentView.swift`
- Modify: `Packages/AnimationPlayground/DemoRegistry.swift`
- Modify: `Packages/LabSwiftUI/ExperimentDestination.swift`
- Modify: `Packages/LabSwiftUI/ExperimentDetailView.swift`
- Modify: `Packages/AnimationPlaygroundTests/DemoRegistryTests.swift`

- [ ] **Step 1: Extend the registry-order test through EXP-009**

Run: `swift test --filter registryKeepsStableExperimentOrder`

Expected: failure because EXP-009 is absent.

- [ ] **Step 2: Add reusable distance helpers and the ambient shader**

Add Metal helpers for capsule distance, rotated ellipse distance, smooth shadow union, and deterministic noise. Implement `lab_ambient_shadow_fragment` with:

- three fixed major branch capsules;
- three low-amplitude fine-twig capsules;
- three leaf groups, each using four to six oriented ellipses;
- separate wind phase, direction, and amplitude per leaf group;
- no time term in major branch geometry;
- a small time term in fine twigs;
- penumbra width derived from each leaf group's wind displacement;
- off-white paper luminance with low-amplitude high-frequency noise.

Return a low-contrast neutral shadow over the paper background. Set effective time to zero when motion scale is zero.

- [ ] **Step 3: Install and route the scene**

Add `.ambientShadow` to `MetalDemoKind`, create `AmbientShadowExperimentView`, and register and route EXP-009.

- [ ] **Step 4: Verify**

Run: `swift test && xcodebuild -project Apps/MetalAnimationLabmacOS/MetalAnimationLabmacOS.xcodeproj -scheme MetalAnimationLabmacOS -configuration Debug build CODE_SIGNING_ALLOWED=NO`

Expected: all tests pass and the macOS app builds.

- [ ] **Step 5: Commit**

```bash
git add Packages/MetalRenderKit Packages/LabSwiftUI Packages/AnimationPlayground Packages/AnimationPlaygroundTests
git commit -m "feat: add ambient branch and leaf shadow experiment"
```

### Task 6: Add Experiment Documentation and Discovery

**Files:**
- Create: `Experiments/EXP-007-SF-Symbol-Light-Sweep/README.md`
- Create: `Experiments/EXP-007-SF-Symbol-Light-Sweep/Result.md`
- Create: `Experiments/EXP-008-Procedural-Night-Sky/README.md`
- Create: `Experiments/EXP-008-Procedural-Night-Sky/Result.md`
- Create: `Experiments/EXP-009-Ambient-Light-Shadow/README.md`
- Create: `Experiments/EXP-009-Ambient-Light-Shadow/Result.md`
- Modify: `README.md`
- Modify: `Docs/00-Index.md`

- [ ] **Step 1: Document inputs, render path, and expected observations**

Each README identifies the experiment ID, purpose, relevant source files, render path, expected visual behavior, Reduce Motion behavior, and verification commands. Each Result records the verified platform and observable result without claiming unmeasured performance numbers.

- [ ] **Step 2: Update discovery lists**

Add EXP-007 through EXP-009 to the root initial-experiments list and add links under the documentation index.

- [ ] **Step 3: Run documentation and boundary checks**

Run: `./Scripts/verify_public_boundary.sh`

Expected: public boundary passes.

- [ ] **Step 4: Commit**

```bash
git add README.md Docs/00-Index.md Experiments/EXP-007-SF-Symbol-Light-Sweep Experiments/EXP-008-Procedural-Night-Sky Experiments/EXP-009-Ambient-Light-Shadow
git commit -m "docs: document procedural visual experiments"
```

### Task 7: Final Verification and macOS Visual Check

**Files:**
- Modify only files required by failures found during verification.

- [ ] **Step 1: Run repository verification**

Run:

```bash
swift test
./Scripts/lint.sh
./Scripts/verify_public_boundary.sh
xcodebuild -project Apps/MetalAnimationLabmacOS/MetalAnimationLabmacOS.xcodeproj \
  -scheme MetalAnimationLabmacOS \
  -configuration Debug \
  build CODE_SIGNING_ALLOWED=NO
```

Expected: every command exits zero.

- [ ] **Step 2: Launch and inspect the macOS app**

Build and run with `./script/build_and_run.sh`. Navigate to EXP-007, EXP-008, and EXP-009. Verify the native heart symbol, one narrow sweep per low-frequency cycle, simultaneous stars and clouds, fixed major branches, independently moving leaves, resizing, inactive pause/resume, and Reduce Motion static behavior.

- [ ] **Step 3: Check the worktree and commit any verification-only fixes**

Run: `git status --short && git diff --check`

Expected: no unexpected files and no whitespace errors. If verification required a fix, commit only the focused fix with a message describing the corrected behavior.
