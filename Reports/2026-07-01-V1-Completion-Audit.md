# MetalAnimationLab V1 Completion Audit

Date: 2026-07-01

## Hosts

- iOS: `MetalAnimationLabiOS`, UIKit application lifecycle, shared SwiftUI experiment UI
- macOS: `MetalAnimationLabmacOS`, explicit AppKit application lifecycle, shared SwiftUI experiment UI
- iOS runtime: iPhone 17 Pro Simulator running iOS 26.5
- macOS runtime: native AppKit window launched by `script/build_and_run.sh`

## Experiment matrix

| Experiment | Scope | iOS Simulator | macOS host | Verified conclusion |
| --- | --- | --- | --- | --- |
| EXP-001 Layer Tree | Required | Passed | Passed | Subject CALayer renders and follows host geometry |
| EXP-002 Implicit vs Explicit | Required | Passed | Passed | Implicit transition visually changes position/color; all three modes reach the expected model target |
| EXP-003 MTKView Triangle | Required | Passed | Passed | Same Metal shader renders the gradient triangle in both MTKView hosts |
| EXP-004 Offscreen Rendering | Extension | Passed | Passed | shadowPath control updates state and scene; no performance claim without Instruments |
| EXP-005 CAMetalLayer | Extension | Passed | Passed | Manual drawable/encode/present path renders animated procedural bands |
| EXP-006 Metal Particles | Extension | Passed | Passed | Consecutive frames show GPU-generated particle motion |

Runtime screenshots remain local under the ignored `Reports/local/` directory. They are evidence for local validation and are intentionally not published.

## Automated gates

- SwiftPM unit tests cover registry routing, metrics, layer geometry, render configuration, animation model targets, and large-timestamp render timing.
- `Scripts/lint.sh` runs SwiftFormat in lint mode and SwiftLint with `--strict`.
- `Scripts/verify_public_boundary.sh` rejects private package names, local private paths, agent-only documents, and likely secrets from tracked public content and reachable history.
- GitHub Actions regenerates both Xcode projects, runs tests and repository checks, and builds both formal hosts.

## Deliberate limitation

EXP-004 proves the two rendering configurations are selectable and visible. It does not claim a performance win because no controlled Instruments capture on physical hardware is part of this audit.
