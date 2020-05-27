import UIKit


/// AuthBaseViewController: the base view controller for the Unified Auth flows.
///
class AuthBaseViewController: UIViewController {
    /// The "call to action" button.
    ///
    @IBOutlet var formButton: UIButton!

    /// The main tableView.
    ///
    @IBOutlet var tableView: UITableView!

    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
