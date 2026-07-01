public struct SymbolLightSweepParameters: Equatable, Sendable {
    public static let standard = SymbolLightSweepParameters()

    public let cycleDuration: Float
    public let sweepDuration: Float
    public let angle: Float
    public let softness: Float
    public let intensity: Float

    public init(
        cycleDuration: Float = 10,
        sweepDuration: Float = 1.5,
        angle: Float = 0.55,
        softness: Float = 0.09,
        intensity: Float = 0.9
    ) {
        let safeCycle = max(1, cycleDuration)
        self.cycleDuration = safeCycle
        self.sweepDuration = min(safeCycle, max(0.1, sweepDuration))
        self.angle = angle
        self.softness = min(1, max(0.001, softness))
        self.intensity = min(2, max(0, intensity))
    }
}

public struct ProceduralSceneParameters: Equatable, Sendable {
    public static let nightSky = ProceduralSceneParameters(
        seed: 0x5A17_2026,
        preferredFramesPerSecond: 30,
        motionScale: 1
    )

    public static let ambientShadow = ProceduralSceneParameters(
        seed: 0x1EA7_2026,
        preferredFramesPerSecond: 30,
        motionScale: 1
    )

    public let seed: UInt32
    public let preferredFramesPerSecond: Int
    public let motionScale: Float

    public init(
        seed: UInt32,
        preferredFramesPerSecond: Int,
        motionScale: Float
    ) {
        self.seed = seed
        self.preferredFramesPerSecond = min(120, max(1, preferredFramesPerSecond))
        self.motionScale = min(2, max(0, motionScale))
    }
}
