---
type: decision
status: accepted
created: 2026-06-30
---

# ADR-001: Native shells with a shared core

## Decision

Use separate UIKit and AppKit application targets. Embed shared SwiftUI experiment pages with UIHostingController and NSHostingController. Keep Metal and Core Animation platform differences in small conditional-compilation bridge files inside shared package targets.

Mac Catalyst remains an optional comparison destination; it does not replace the AppKit application.

## Rationale

Apple recommends separate targets when an iOS app uses UIKit and its Mac counterpart uses AppKit. Kingfisher demonstrates a practical balance of shared logic, cross-platform type aliases, platform-specific extensions, and a separate SwiftUI layer. SwiftSoup demonstrates that platform-neutral logic can remain in one Swift package with only narrow operating-system conditionals.

References:

- https://developer.apple.com/documentation/xcode/configuring-a-multiplatform-app-target
- https://developer.apple.com/documentation/uikit/mac-catalyst
- https://github.com/onevcat/Kingfisher
- https://github.com/scinfu/SwiftSoup

No third-party source code was copied into this repository.

