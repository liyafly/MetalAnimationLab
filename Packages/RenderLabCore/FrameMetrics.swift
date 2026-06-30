import Foundation

public struct FrameMetrics: Equatable, Sendable {
    public let hitchThreshold: TimeInterval

    public private(set) var sampleCount = 0
    public private(set) var hitchCount = 0
    public private(set) var totalDuration: TimeInterval = 0
    public private(set) var latestSample: PerformanceSample?

    public var averageFPS: Double {
        guard totalDuration > 0 else { return 0 }
        return Double(sampleCount) / totalDuration
    }

    public init(hitchThreshold: TimeInterval = 0.05) {
        self.hitchThreshold = hitchThreshold
    }

    public mutating func record(frameDuration: TimeInterval) {
        guard frameDuration.isFinite, frameDuration > 0 else { return }

        let sample = PerformanceSample(
            frameDuration: frameDuration,
            hitchThreshold: hitchThreshold
        )
        latestSample = sample
        sampleCount += 1
        totalDuration += frameDuration
        if sample.isHitch {
            hitchCount += 1
        }
    }

    public mutating func reset() {
        sampleCount = 0
        hitchCount = 0
        totalDuration = 0
        latestSample = nil
    }
}
