#if canImport(UIKit)
    import UIKit

    @MainActor
    public final class LayerTreeHostView: UIView {
        private let scene = LayerTreeScene()

        override public init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = UIColor(red: 0.04, green: 0.05, blue: 0.09, alpha: 1)
            scene.attach(to: layer)
        }

        public required init?(coder: NSCoder) {
            super.init(coder: coder)
            scene.attach(to: layer)
        }

        override public func layoutSubviews() {
            super.layoutSubviews()
            scene.layout(in: bounds)
        }

        public var snapshot: LayerTreeSnapshot {
            scene.snapshot
        }
    }

#elseif canImport(AppKit)
    import AppKit

    @MainActor
    public final class LayerTreeHostView: NSView {
        private let scene = LayerTreeScene()

        override public init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
            layer?.backgroundColor = CGColor(red: 0.04, green: 0.05, blue: 0.09, alpha: 1)
            if let layer { scene.attach(to: layer) }
        }

        public required init?(coder: NSCoder) {
            super.init(coder: coder)
            wantsLayer = true
            if let layer { scene.attach(to: layer) }
        }

        override public func layout() {
            super.layout()
            scene.layout(in: bounds)
        }

        public var snapshot: LayerTreeSnapshot {
            scene.snapshot
        }
    }
#endif
