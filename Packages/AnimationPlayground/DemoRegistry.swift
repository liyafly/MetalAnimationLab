public enum DemoRegistry {
    public static let standard: [ExperimentDescriptor] = [
        ExperimentDescriptor(
            id: "EXP-001",
            title: "Layer Tree Basics",
            summary: "Inspect frame, bounds, position, anchor point, and sublayers.",
            category: .coreAnimation,
            isRequired: true
        ),
        ExperimentDescriptor(
            id: "EXP-002",
            title: "Implicit vs Explicit Animation",
            summary: "Compare transactions, layer actions, and explicit animations.",
            category: .coreAnimation,
            isRequired: true
        ),
        ExperimentDescriptor(
            id: "EXP-003",
            title: "MTKView First Triangle",
            summary: "Follow a complete Metal render and presentation pass.",
            category: .metal,
            isRequired: true
        ),
        ExperimentDescriptor(
            id: "EXP-004",
            title: "Offscreen Rendering",
            summary: "Compare shadows with and without a precomputed shadow path.",
            category: .performance,
            isRequired: false
        ),
        ExperimentDescriptor(
            id: "EXP-005",
            title: "CAMetalLayer Manual Renderer",
            summary: "Own drawable acquisition, command encoding, and presentation.",
            category: .metal,
            isRequired: false
        ),
        ExperimentDescriptor(
            id: "EXP-006",
            title: "Metal Particle Animation",
            summary: "Animate procedural particles on the GPU.",
            category: .metal,
            isRequired: false
        ),
    ]
}
