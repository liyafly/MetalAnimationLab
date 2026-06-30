import QuartzCore

@MainActor
final class ImplicitAnimationScene {
    private let subjectLayer = CALayer()
    private var moved = false

    init() {
        subjectLayer.bounds = CGRect(x: 0, y: 0, width: 88, height: 88)
        subjectLayer.cornerRadius = 24
        subjectLayer.backgroundColor = CGColor(red: 0.82, green: 0.3, blue: 0.9, alpha: 1)
    }

    func attach(to rootLayer: CALayer) {
        guard subjectLayer.superlayer !== rootLayer else { return }
        subjectLayer.removeFromSuperlayer()
        rootLayer.addSublayer(subjectLayer)
    }

    func layout(in bounds: CGRect) {
        let x = moved ? bounds.maxX - 70 : bounds.minX + 70
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        subjectLayer.position = CGPoint(x: x, y: bounds.midY)
        CATransaction.commit()
    }

    func run(mode: AnimationMode, in bounds: CGRect) {
        moved.toggle()
        let targetPosition = CGPoint(
            x: moved ? bounds.maxX - 70 : bounds.minX + 70,
            y: bounds.midY
        )
        let targetColor = moved
            ? CGColor(red: 0.15, green: 0.8, blue: 0.85, alpha: 1)
            : CGColor(red: 0.82, green: 0.3, blue: 0.9, alpha: 1)

        switch mode {
        case .implicit:
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.75)
            subjectLayer.position = targetPosition
            subjectLayer.backgroundColor = targetColor
            CATransaction.commit()
        case .disabledActions:
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            subjectLayer.position = targetPosition
            subjectLayer.backgroundColor = targetColor
            CATransaction.commit()
        case .explicit:
            let position = CABasicAnimation(keyPath: "position")
            position.fromValue = subjectLayer.presentation()?.position ?? subjectLayer.position
            position.toValue = targetPosition
            position.duration = 0.75
            position.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

            CATransaction.begin()
            CATransaction.setDisableActions(true)
            subjectLayer.position = targetPosition
            subjectLayer.backgroundColor = targetColor
            CATransaction.commit()
            subjectLayer.add(position, forKey: "position")
        }
    }

    var presentationPosition: CGPoint? {
        subjectLayer.presentation()?.position
    }

    var modelPosition: CGPoint {
        subjectLayer.position
    }
}

