# EXP-008: Procedural Night Sky

## Question

Can one full-screen Metal pass render stable stars and slowly drifting partial clouds without textures or weather data?

## Procedure

Generate stars from hashed cells and a fixed seed. Generate cloud density from layered value noise with domain warping, then composite clouds over stars in one fragment shader.

## Observation

Inspect star stability, independent twinkle, approximate cloud coverage, horizontal drift, aspect-correct resizing, inactive-window pause, and Reduce Motion behavior.
