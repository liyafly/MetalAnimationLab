import Foundation

public struct RenderClock: Sendable {
    private var origin: TimeInterval?
    private var pausedAt: TimeInterval?
    private var accumulatedPause: TimeInterval = 0

    public init() {}

    public mutating func elapsedTime(at timestamp: TimeInterval) -> Float {
        guard let origin else {
            origin = timestamp
            return 0
        }
        let openPause = pausedAt.map { max(0, timestamp - $0) } ?? 0
        return Float(max(0, timestamp - origin - accumulatedPause - openPause))
    }

    public mutating func setPaused(_ isPaused: Bool, at timestamp: TimeInterval) {
        if isPaused {
            guard pausedAt == nil else { return }
            pausedAt = timestamp
        } else if let pausedAt {
            accumulatedPause += max(0, timestamp - pausedAt)
            self.pausedAt = nil
        }
    }
}
