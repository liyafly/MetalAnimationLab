# EXP-007: SF Symbol Light Sweep

## Question

Can a native SF Symbol keep its system-provided shape while Metal adds a low-frequency soft light sweep?

## Procedure

Render `heart.fill` with SwiftUI and apply a stitchable Metal layer effect from the package shader library. Use a ten-second cycle with a 1.5-second diagonal light pass, then hold the symbol unchanged.

## Observation

Inspect the symbol silhouette, light-band softness, bounded edge glow, inactive-window pause, and Reduce Motion behavior in the native macOS host.
