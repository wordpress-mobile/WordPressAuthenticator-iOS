import UIKit
import WordPressShared
import WordPressUI


public class AuthLoginNavigationController: RotationAwareNavigationViewController {
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return WordPressAuthenticator.shared.style.statusBarStyle
    }
}
