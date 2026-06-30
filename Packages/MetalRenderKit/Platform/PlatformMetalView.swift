import QuartzCore

#if canImport(UIKit)
    import UIKit

    public typealias PlatformView = UIView

    public final class PlatformMetalLayerView: UIView {
        override public class var layerClass: AnyClass {
            CAMetalLayer.self
        }

        public var metalLayer: CAMetalLayer? {
            layer as? CAMetalLayer
        }
    }

#elseif canImport(AppKit)
    import AppKit

    public typealias PlatformView = NSView

    public final class PlatformMetalLayerView: NSView {
        override public init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            wantsLayer = true
        }

        public required init?(coder: NSCoder) {
            super.init(coder: coder)
            wantsLayer = true
        }

        override public func makeBackingLayer() -> CALayer {
            CAMetalLayer()
        }

        public var metalLayer: CAMetalLayer? {
            layer as? CAMetalLayer
        }
    }
#endif
