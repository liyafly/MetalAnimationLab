@testable import CoreAnimationLab
import QuartzCore
import Testing

@MainActor
@Test(arguments: AnimationMode.allCases)
func everyAnimationModeUpdatesTheModelLayerToItsTarget(mode: AnimationMode) {
    let bounds = CGRect(x: 0, y: 0, width: 320, height: 240)
    let rootLayer = CALayer()
    rootLayer.bounds = bounds
    let scene = ImplicitAnimationScene()
    scene.attach(to: rootLayer)
    scene.layout(in: bounds)

    #expect(scene.modelPosition == CGPoint(x: 70, y: bounds.midY))

    scene.run(mode: mode, in: bounds)

    #expect(scene.modelPosition == CGPoint(x: bounds.maxX - 70, y: bounds.midY))
}
