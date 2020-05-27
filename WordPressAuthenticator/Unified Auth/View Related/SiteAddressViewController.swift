import UIKit


/// SiteAddressViewController: starts the "log in by Site Address" flow.
///
class SiteAddressViewController: AuthBaseViewController {
    /// Login Fields.
    ///
    var loginFields = LoginFields()

    /// Host App decisions are communicated to the Authenticator via the delegate.
    /// Creating a local variable to signal this VC's dependency upfront.
    ///
    var authDelegate: WordPressAuthenticatorDelegate {
        guard let delegate = WordPressAuthenticator.shared.delegate else {
            fatalError()
        }

        return delegate
    }

    /// Make dependencies obvious.
    ///
    var displayStrings: WordPressAuthenticatorDisplayStrings {
        return WordPressAuthenticator.shared.displayStrings
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Don't assume the user's baseURL is https://wordpress.com.
        loginFields.meta.userIsDotCom = false
        createTableHeaderViewIfNeeded()
    }

    func createTableHeaderViewIfNeeded() {
        if authDelegate.largeTitlesEnabled,
            let title = displayStrings.siteAddressTitle.nonEmptyString() {
            let headerView = LargeTitleHeaderView()
            headerView.titleLabel.text = title
            tableView.tableHeaderView = headerView
        }
    }
}


// MARK: - UITableViewDataSource
extension SiteAddressViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}
