import QuartzCore

@MainActor
final class LayerTreeScene {
    private let subjectLayer = CALayer()

    init() {
        subjectLayer.name = "ExperimentSubject"
        subjectLayer.bounds = CGRect(x: 0, y: 0, width: 150, height: 100)
        subjectLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        subjectLayer.cornerRadius = 22
        subjectLayer.backgroundColor = CGColor(red: 0.22, green: 0.55, blue: 0.96, alpha: 1)
        subjectLayer.borderColor = CGColor(red: 0.75, green: 0.9, blue: 1, alpha: 1)
        subjectLayer.borderWidth = 2
    }

    func attach(to rootLayer: CALayer) {
        guard subjectLayer.superlayer !== rootLayer else { return }
        subjectLayer.removeFromSuperlayer()
        rootLayer.addSublayer(subjectLayer)
    }

    func layout(in bounds: CGRect) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        subjectLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        CATransaction.commit()
    }

    var snapshot: LayerTreeSnapshot {
        LayerTreeSnapshot(
            frame: subjectLayer.frame,
            bounds: subjectLayer.bounds,
            position: subjectLayer.position,
            anchorPoint: subjectLayer.anchorPoint
        )
    }
}
