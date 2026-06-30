# EXP-005: CAMetalLayer Manual Renderer

## Question

What responsibilities does MTKView normally handle around CAMetalLayer?

## Procedure

Render a fullscreen procedural effect by acquiring a CAMetalDrawable, creating a render pass, encoding commands, presenting, and committing manually.

## Observation

Compare drawable sizing, scale, and presentation behavior across UIKit and AppKit.

