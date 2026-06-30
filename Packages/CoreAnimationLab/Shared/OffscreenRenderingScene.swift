import QuartzCore

@MainActor
final class OffscreenRenderingScene {
    private let cardLayer = CALayer()

    init() {
        cardLayer.bounds = CGRect(x: 0, y: 0, width: 180, height: 120)
        cardLayer.cornerRadius = 28
        cardLayer.backgroundColor = CGColor(red: 0.95, green: 0.96, blue: 1, alpha: 1)
        cardLayer.shadowColor = CGColor(gray: 0, alpha: 1)
        cardLayer.shadowOpacity = 0.45
        cardLayer.shadowRadius = 18
        cardLayer.shadowOffset = CGSize(width: 0, height: 12)
    }

    func attach(to rootLayer: CALayer) {
        guard cardLayer.superlayer !== rootLayer else { return }
        cardLayer.removeFromSuperlayer()
        rootLayer.addSublayer(cardLayer)
    }

    func layout(in bounds: CGRect, usesShadowPath: Bool) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        cardLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        cardLayer.shadowPath = usesShadowPath
            ? CGPath(roundedRect: cardLayer.bounds, cornerWidth: 28, cornerHeight: 28, transform: nil)
            : nil
        CATransaction.commit()
    }
}
