import Foundation

public struct PerformanceSample: Equatable, Sendable {
    public let frameDuration: TimeInterval
    public let framesPerSecond: Double
    public let isHitch: Bool

    public init(frameDuration: TimeInterval, hitchThreshold: TimeInterval) {
        self.frameDuration = frameDuration
        framesPerSecond = frameDuration > 0 ? 1 / frameDuration : 0
        isHitch = frameDuration >= hitchThreshold
    }
}

