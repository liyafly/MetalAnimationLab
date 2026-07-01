import Combine
import Foundation

#if canImport(AppKit)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

@MainActor
final class PlatformActivityMonitor: NSObject, ObservableObject {
    @Published private(set) var isActive: Bool

    override init() {
        #if canImport(AppKit)
            isActive = NSApplication.shared.isActive
        #elseif canImport(UIKit)
            isActive = UIApplication.shared.applicationState == .active
        #else
            isActive = true
        #endif

        super.init()

        #if canImport(AppKit)
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(didBecomeActive),
                name: NSApplication.didBecomeActiveNotification,
                object: nil
            )
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(didResignActive),
                name: NSApplication.didResignActiveNotification,
                object: nil
            )
        #elseif canImport(UIKit)
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(didBecomeActive),
                name: UIApplication.didBecomeActiveNotification,
                object: nil
            )
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(didResignActive),
                name: UIApplication.willResignActiveNotification,
                object: nil
            )
        #endif
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func didBecomeActive() {
        isActive = true
    }

    @objc private func didResignActive() {
        isActive = false
    }
}
