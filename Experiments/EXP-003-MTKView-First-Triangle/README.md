# EXP-003: MTKView First Triangle

## Question

What is the minimum complete Metal render-and-present flow?

## Procedure

Trace device creation, command queue reuse, pipeline creation, render encoding, drawable presentation, and commit. The vertex shader generates vertices from vertex_id.

## Observation

Confirm the same shader renders in the UIKit and AppKit MTKView hosts.

