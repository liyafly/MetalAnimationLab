# EXP-005 Result

- Toolchain: Xcode 26.6, Swift 6.3.3
- Build status: iOS and macOS passed
- Runtime verification: animated procedural bands rendered through CAMetalLayer in both hosts on 2026-07-01
- Fix verified: render time is relative to a local origin, preserving frame intervals before conversion to Float
