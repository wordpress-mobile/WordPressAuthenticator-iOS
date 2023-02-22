import UIKit
import WordPressKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // This is a property defined in `UIApplicationDelegate`. In modern UIKit apps,
    // `UISceneConfiguration` is responsible for creating and holding the window.
    //
    // However, we need to set this anyway because SVProgressHUD accesses it internally and will
    // crash the app if the value it finds is nil.
    var window: UIWindow?

    let logger = ConsoleLogger()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        WPKitSetLoggingDelegate(logger)
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}
