#if canImport(UIKit)
import UIKit

@MainActor
public final class OffscreenRenderingHostView: UIView {
    private let scene = OffscreenRenderingScene()
    public var usesShadowPath = false { didSet { setNeedsLayout() } }

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
        scene.layout(in: bounds, usesShadowPath: usesShadowPath)
    }
}

#elseif canImport(AppKit)
import AppKit

@MainActor
public final class OffscreenRenderingHostView: NSView {
    private let scene = OffscreenRenderingScene()
    public var usesShadowPath = false { didSet { needsLayout = true } }

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
        scene.layout(in: bounds, usesShadowPath: usesShadowPath)
    }
}
#endif
