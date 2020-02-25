import UIKit
import WordPressShared
import WordPressUI


public class AuthNavigationController: RotationAwareNavigationViewController {
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return WordPressAuthenticator.shared.style.statusBarStyle
    }
}
