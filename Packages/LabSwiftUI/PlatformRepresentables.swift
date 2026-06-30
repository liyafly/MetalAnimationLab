import CoreAnimationLab
import MetalKit
import MetalRenderKit
import SwiftUI

#if canImport(UIKit)
import UIKit

@MainActor
struct LayerTreeRepresentable: UIViewRepresentable {
    func makeUIView(context _: Context) -> LayerTreeHostView {
        LayerTreeHostView()
    }

    func updateUIView(_: LayerTreeHostView, context _: Context) {}
}

@MainActor
struct ImplicitAnimationRepresentable: UIViewRepresentable {
    let mode: AnimationMode
    let runToken: Int

    func makeCoordinator() -> Coordinator { Coordinator(runToken: runToken) }

    func makeUIView(context _: Context) -> ImplicitAnimationHostView {
        ImplicitAnimationHostView()
    }

    func updateUIView(_ view: ImplicitAnimationHostView, context: Context) {
        guard context.coordinator.lastRunToken != runToken else { return }
        context.coordinator.lastRunToken = runToken
        view.run(mode: mode)
    }

    final class Coordinator {
        var lastRunToken: Int
        init(runToken: Int) { lastRunToken = runToken }
    }
}

@MainActor
struct OffscreenRenderingRepresentable: UIViewRepresentable {
    let usesShadowPath: Bool

    func makeUIView(context _: Context) -> OffscreenRenderingHostView {
        OffscreenRenderingHostView()
    }

    func updateUIView(_ view: OffscreenRenderingHostView, context _: Context) {
        view.usesShadowPath = usesShadowPath
    }
}

@MainActor
struct ManualMetalLayerRepresentable: UIViewRepresentable {
    let time: TimeInterval

    func makeCoordinator() -> ManualMetalCoordinator { ManualMetalCoordinator() }

    func makeUIView(context: Context) -> PlatformMetalLayerView {
        let view = PlatformMetalLayerView()
        context.coordinator.configure(view: view)
        return view
    }

    func updateUIView(_ view: PlatformMetalLayerView, context: Context) {
        context.coordinator.draw(view: view, time: time, scale: view.window?.screen.scale ?? 2)
    }
}

#elseif canImport(AppKit)
import AppKit

@MainActor
struct LayerTreeRepresentable: NSViewRepresentable {
    func makeNSView(context _: Context) -> LayerTreeHostView {
        LayerTreeHostView()
    }

    func updateNSView(_: LayerTreeHostView, context _: Context) {}
}

@MainActor
struct ImplicitAnimationRepresentable: NSViewRepresentable {
    let mode: AnimationMode
    let runToken: Int

    func makeCoordinator() -> Coordinator { Coordinator(runToken: runToken) }

    func makeNSView(context _: Context) -> ImplicitAnimationHostView {
        ImplicitAnimationHostView()
    }

    func updateNSView(_ view: ImplicitAnimationHostView, context: Context) {
        guard context.coordinator.lastRunToken != runToken else { return }
        context.coordinator.lastRunToken = runToken
        view.run(mode: mode)
    }

    final class Coordinator {
        var lastRunToken: Int
        init(runToken: Int) { lastRunToken = runToken }
    }
}

@MainActor
struct OffscreenRenderingRepresentable: NSViewRepresentable {
    let usesShadowPath: Bool

    func makeNSView(context _: Context) -> OffscreenRenderingHostView {
        OffscreenRenderingHostView()
    }

    func updateNSView(_ view: OffscreenRenderingHostView, context _: Context) {
        view.usesShadowPath = usesShadowPath
    }
}

@MainActor
struct ManualMetalLayerRepresentable: NSViewRepresentable {
    let time: TimeInterval

    func makeCoordinator() -> ManualMetalCoordinator { ManualMetalCoordinator() }

    func makeNSView(context: Context) -> PlatformMetalLayerView {
        let view = PlatformMetalLayerView()
        context.coordinator.configure(view: view)
        return view
    }

    func updateNSView(_ view: PlatformMetalLayerView, context: Context) {
        context.coordinator.draw(
            view: view,
            time: time,
            scale: view.window?.backingScaleFactor ?? 2
        )
    }
}
#endif

@MainActor
final class ManualMetalCoordinator {
    private let renderer: CAMetalLayerRenderer?

    init() {
        renderer = try? CAMetalLayerRenderer()
    }

    func configure(view: PlatformMetalLayerView) {
        guard let layer = view.metalLayer else { return }
        renderer?.configure(layer: layer)
    }

    func draw(view: PlatformMetalLayerView, time: TimeInterval, scale: CGFloat) {
        guard let layer = view.metalLayer else { return }
        layer.frame = view.bounds
        layer.contentsScale = scale
        layer.drawableSize = CGSize(
            width: max(1, view.bounds.width * scale),
            height: max(1, view.bounds.height * scale)
        )
        renderer?.draw(layer: layer, time: Float(time))
    }
}

enum MetalDemoKind {
    case triangle
    case particles
}

#if canImport(UIKit)
@MainActor
struct MetalViewRepresentable: UIViewRepresentable {
    let kind: MetalDemoKind

    func makeCoordinator() -> MetalViewCoordinator { MetalViewCoordinator() }

    func makeUIView(context: Context) -> MTKView {
        makeView(context: context)
    }

    func updateUIView(_: MTKView, context _: Context) {}

    private func makeView(context: Context) -> MTKView {
        let view = MTKView()
        context.coordinator.install(kind: kind, in: view)
        return view
    }
}
#elseif canImport(AppKit)
@MainActor
struct MetalViewRepresentable: NSViewRepresentable {
    let kind: MetalDemoKind

    func makeCoordinator() -> MetalViewCoordinator { MetalViewCoordinator() }

    func makeNSView(context: Context) -> MTKView {
        let view = MTKView()
        context.coordinator.install(kind: kind, in: view)
        return view
    }

    func updateNSView(_: MTKView, context _: Context) {}
}
#endif

@MainActor
final class MetalViewCoordinator {
    private var delegate: (any MTKViewDelegate)?

    func install(kind: MetalDemoKind, in view: MTKView) {
        do {
            switch kind {
            case .triangle:
                delegate = try TriangleRenderer(view: view)
            case .particles:
                delegate = try ParticleRenderer(view: view)
            }
            view.delegate = delegate
        } catch {
            view.clearColor = MTLClearColor(red: 0.3, green: 0.02, blue: 0.04, alpha: 1)
        }
    }
}

