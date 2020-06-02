import UIKit


/// SiteAddressViewController: log in by Site Address.
///
final class SiteAddressViewController: LoginViewController {

    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet var bottomContentConstraint: NSLayoutConstraint?

    // Required property declaration for `NUXKeyboardResponder` but unused here.
    var verticalCenterConstraint: NSLayoutConstraint?

    var displayStrings: WordPressAuthenticatorDisplayStrings {
        return WordPressAuthenticator.shared.displayStrings
    }

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        localizePrimaryButton()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        registerForKeyboardEvents(keyboardWillShowAction: #selector(handleKeyboardWillShow(_:)),
                                  keyboardWillHideAction: #selector(handleKeyboardWillHide(_:)))
    }

    func localizePrimaryButton() {
        let primaryTitle = displayStrings.continueButtonTitle
        submitButton?.setTitle(primaryTitle, for: .normal)
        submitButton?.setTitle(primaryTitle, for: .highlighted)
    }
}


// MARK: - UITableViewDataSource
extension SiteAddressViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "largetitlecell") ?? UITableViewCell()
        }

        if indexPath.row == 1 {
            return tableView.dequeueReusableCell(withIdentifier: "emailcell")  ?? UITableViewCell()
        }

        if indexPath.row == 2 {
            return tableView.dequeueReusableCell(withIdentifier: "instructionscell") ?? UITableViewCell()
        }

        if indexPath.row == 3 {
            return tableView.dequeueReusableCell(withIdentifier: "textfieldcell") ?? UITableViewCell()
        }

        if indexPath.row == 4 {
            return tableView.dequeueReusableCell(withIdentifier: "errorcell") ?? UITableViewCell()
        }

        if indexPath.row == 5 {
            return tableView.dequeueReusableCell(withIdentifier: "secondaryhelperbuttoncell") ?? UITableViewCell()
        }

        return UITableViewCell()
    }
}


// MARK: - UITableViewDelegate conformance
extension SiteAddressViewController: UITableViewDelegate {

}


// MARK: - Keyboard Notifications
extension SiteAddressViewController: NUXKeyboardResponder {
    @objc func handleKeyboardWillShow(_ notification: Foundation.Notification) {
        keyboardWillShow(notification)
    }

    @objc func handleKeyboardWillHide(_ notification: Foundation.Notification) {
        keyboardWillHide(notification)
    }
}
