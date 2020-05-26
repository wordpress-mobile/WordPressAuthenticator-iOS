import UIKit


/// AuthBaseViewController: the base view controller for the Unified Auth flows.
///
class AuthBaseViewController: UIViewController {
    @IBOutlet var formButton: UIButton!
    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        styleBackground()
    }

    // MARK: - Setup and configuration

    /// Styles the view's background color.
    ///
    func styleBackground() {
        view.backgroundColor = WordPressAuthenticator.shared.style.viewControllerBackgroundColor
    }
}
