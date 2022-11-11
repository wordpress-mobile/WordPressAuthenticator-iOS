import UIKit
import WordPressAuthenticator

class ViewController: UIViewController {

    let tableView = UITableView(frame: .zero, style: .grouped)
    let reuseIdentifier = "cell"

    struct CellConfiguration {
        let text: String
        let action: () -> Void
    }

    lazy var configuration: [CellConfiguration] = [
        CellConfiguration(text: "Show Login") { [weak self] in
            guard let self else { fatalError() }
            WordPressAuthenticator.showLoginFromPresenter(self, animated: true)
        }
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Authenticator Demo 🔐"

        setUpTableView()

        initializeWordPressAuthenticator()
        WordPressAuthenticator.shared.delegate = self
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
