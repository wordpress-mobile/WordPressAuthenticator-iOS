import AuthenticationServices
import UIKit
import WordPressAuthenticator

/// Starting point for the demo app. It shows a table view with actionable rows each loading a different authentication flow.
/// (Currently, we only have one authentication flow).
class ViewController: UIViewController {

    /// Add `CellConfiguration` items to add new actionable rows to the table view in `ViewController`.
    lazy var configuration: [CellConfiguration] = [
        CellConfiguration(text: "Show Login") { [weak self] in
            guard let self else { fatalError() }

            self.initializeWordPressAuthenticator()
            WordPressAuthenticator.showLoginFromPresenter(self, animated: true)
        },
        CellConfiguration(text: "Get Google token only") { [weak self] in
            guard let self else { fatalError() }

            self.initializeWordPressAuthenticator()
            self.getAuthTokenFromGoogle()
        }
    ]

    let tableView = UITableView(frame: .zero, style: .grouped)
    let reuseIdentifier = "cell"

    lazy var googleAuthenticator = NewGoogleAuthenticator(
        clientId: GoogleClientId(string: APICredentials.googleLoginClientId)!,
        scheme: APICredentials.googleLoginSchemeId,
        audience: APICredentials.googleLoginServerClientId,
        urlSession: URLSession.shared
    )

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Authenticator Demo 🔐"

        setUpTableView()
    }

    func setUpTableView() {
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false

        let constraints = [NSLayoutConstraint.Attribute](arrayLiteral: .top, .right, .bottom, .left)
            .map {
                NSLayoutConstraint(
                    item: tableView,
                    attribute: $0,
                    relatedBy: .equal,
                    toItem: view,
                    attribute: $0,
                    multiplier: 1,
                    constant: 0
                )
            }
        view.addConstraints(constraints)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
    }
}

extension ViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        configuration.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        guard let configurationItem = configuration(for: indexPath) else { return cell }

        var content = cell.defaultContentConfiguration()
        content.text = configurationItem.text
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator

        return cell
    }
}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let configurationItem = configuration(for: indexPath) else { return }
        configurationItem.action()
    }
}

extension ViewController {

    func configuration(for indexPath: IndexPath) -> CellConfiguration? {
        guard configuration.count > indexPath.row else { return .none }
        return configuration[indexPath.row]
    }
}
