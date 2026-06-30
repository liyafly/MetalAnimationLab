#if canImport(UIKit)
import UIKit

@MainActor
public final class ImplicitAnimationHostView: UIView {
    private let scene = ImplicitAnimationScene()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        scene.attach(to: layer)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        scene.attach(to: layer)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        scene.layout(in: bounds)
    }

    public func run(mode: AnimationMode) { scene.run(mode: mode, in: bounds) }
    public var modelPosition: CGPoint { scene.modelPosition }
    public var presentationPosition: CGPoint? { scene.presentationPosition }
}

#elseif canImport(AppKit)
import AppKit

@MainActor
public final class ImplicitAnimationHostView: NSView {
    private let scene = ImplicitAnimationScene()

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        if let layer { scene.attach(to: layer) }
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
        if let layer { scene.attach(to: layer) }
    }

    public override func layout() {
        super.layout()
        scene.layout(in: bounds)
    }

    public func run(mode: AnimationMode) { scene.run(mode: mode, in: bounds) }
    public var modelPosition: CGPoint { scene.modelPosition }
    public var presentationPosition: CGPoint? { scene.presentationPosition }
}
#endif

