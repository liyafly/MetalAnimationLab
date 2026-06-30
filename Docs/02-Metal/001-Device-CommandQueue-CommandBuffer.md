# Device, Command Queue, and Command Buffer

`MetalContext` owns a device and a reusable command queue. Each rendered frame creates a command buffer, encodes work, presents the current drawable, and commits the buffer.

EXP-003 uses MTKView to manage drawable timing. EXP-005 performs drawable acquisition and presentation directly through CAMetalLayer. Both paths reuse the same shader library and error model.

