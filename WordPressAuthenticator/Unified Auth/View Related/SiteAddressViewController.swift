import UIKit


/// SiteAddressViewController: starts the "log in by Site Address" flow.
///
class SiteAddressViewController: AuthBaseViewController {
    /// Login Fields.
    ///
    var loginFields = LoginFields()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Don't assume the user's baseURL is https://wordpress.com.
        loginFields.meta.userIsDotCom = false
    }
}
