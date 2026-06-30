import LabSwiftUI
import SwiftUI
import UIKit

@main
@MainActor
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let hostingController = UIHostingController(rootView: LabRootView())
        hostingController.title = "MetalAnimationLab"

        let navigationController = UINavigationController(rootViewController: hostingController)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}
