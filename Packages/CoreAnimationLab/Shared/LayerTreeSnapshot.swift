import CoreGraphics
import Foundation

public struct LayerTreeSnapshot: Equatable, Sendable {
    public let frame: CGRect
    public let bounds: CGRect
    public let position: CGPoint
    public let anchorPoint: CGPoint

    public init(
        frame: CGRect,
        bounds: CGRect,
        position: CGPoint,
        anchorPoint: CGPoint
    ) {
        self.frame = frame
        self.bounds = bounds
        self.position = position
        self.anchorPoint = anchorPoint
    }

    public var lines: [String] {
        [
            "frame: \(Self.describe(frame))",
            "bounds: \(Self.describe(bounds))",
            "position: \(Self.describe(position))",
            "anchorPoint: \(Self.describe(anchorPoint))",
        ]
    }

    private static func describe(_ rect: CGRect) -> String {
        String(
            format: "(%.1f, %.1f, %.1f, %.1f)",
            Double(rect.origin.x),
            Double(rect.origin.y),
            Double(rect.size.width),
            Double(rect.size.height)
        )
    }

    private static func describe(_ point: CGPoint) -> String {
        String(format: "(%.1f, %.1f)", Double(point.x), Double(point.y))
    }
}
