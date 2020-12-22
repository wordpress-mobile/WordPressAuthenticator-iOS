import Foundation

/// Navigates to the request for a magic link.
///
public struct NavigateToMagicLink: NavigationCommand {
    private let email: String

    public init(email: String) {
        self.email = email
    }

    public func execute(from: UIViewController?) {
        navigate(navigationController: from?.navigationController)
    }
}

private extension NavigateToMagicLink {
    func navigate(navigationController: UINavigationController?) {
        guard let vc = LoginLinkRequestViewController.instantiate(from: .login) else {
            DDLogError("Failed to navigate from LoginEmailViewController to LoginLinkRequestViewController")
            return
        }

        let loginFields = LoginFields()
        loginFields.username = email
        loginFields.emailAddress = email

        vc.loginFields = loginFields

        navigationController?.pushViewController(vc, animated: true)
    }
}

