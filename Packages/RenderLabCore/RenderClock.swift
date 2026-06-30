import Foundation

public struct RenderClock: Sendable {
    private var origin: TimeInterval?

    public init() {}

    public mutating func elapsedTime(at timestamp: TimeInterval) -> Float {
        guard let origin else {
            origin = timestamp
            return 0
        }
        return Float(max(0, timestamp - origin))
    }
}
