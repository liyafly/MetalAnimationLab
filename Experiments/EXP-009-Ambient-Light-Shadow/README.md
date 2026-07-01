# EXP-009: Ambient Light and Shadow

## Question

Can procedural distance fields keep major branch shadows fixed while independent leaf groups move gently?

## Procedure

Construct major branches and fine twigs from capsule distances. Construct leaves from rotated ellipse distances grouped around fixed anchors. Animate only fine twigs and leaf-local transforms, then composite a soft shadow mask over a procedural off-white surface.

## Observation

Inspect branch stability, independent leaf phases, low-amplitude twig motion, penumbra variation, surface texture, inactive-window pause, and Reduce Motion behavior.
