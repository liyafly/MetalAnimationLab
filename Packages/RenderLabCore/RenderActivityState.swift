public struct RenderActivityState: Equatable, Sendable {
    public let isApplicationActive: Bool
    public let reduceMotion: Bool

    public init(isApplicationActive: Bool, reduceMotion: Bool) {
        self.isApplicationActive = isApplicationActive
        self.reduceMotion = reduceMotion
    }

    public var isPaused: Bool {
        !isApplicationActive || reduceMotion
    }

    public var motionScale: Float {
        reduceMotion ? 0 : 1
    }
}
