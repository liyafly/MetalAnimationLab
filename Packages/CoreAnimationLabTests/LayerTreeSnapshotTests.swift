import CoreGraphics
import Testing

@testable import CoreAnimationLab

@Test
func snapshotDescribesLayerGeometry() {
    let snapshot = LayerTreeSnapshot(
        frame: CGRect(x: 10, y: 20, width: 80, height: 40),
        bounds: CGRect(x: 0, y: 0, width: 80, height: 40),
        position: CGPoint(x: 50, y: 40),
        anchorPoint: CGPoint(x: 0.5, y: 0.5)
    )

    #expect(snapshot.lines.count == 4)
    #expect(snapshot.lines[0].hasPrefix("frame:"))
    #expect(snapshot.lines[1].hasPrefix("bounds:"))
    #expect(snapshot.lines[2].hasPrefix("position:"))
    #expect(snapshot.lines[3].hasPrefix("anchorPoint:"))
}

@Test
func snapshotFormattingIsStable() {
    let snapshot = LayerTreeSnapshot(
        frame: CGRect(x: 1, y: 2, width: 3, height: 4),
        bounds: CGRect(x: 0, y: 0, width: 3, height: 4),
        position: CGPoint(x: 2.5, y: 4),
        anchorPoint: CGPoint(x: 0.5, y: 0.5)
    )

    #expect(snapshot.lines[0] == "frame: (1.0, 2.0, 3.0, 4.0)")
}
