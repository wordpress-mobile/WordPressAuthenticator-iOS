import UIKit


/// AuthBaseViewController: the base view controller for the Unified Auth flows.
///
open class AuthBaseViewController: UIViewController {
    /// The "call to action" button.
    ///
    @IBOutlet var formButton: UIButton!

    /// The main tableView.
    ///
    @IBOutlet var tableView: UITableView!

    // MARK: - View lifecycle
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
}


//final class AuthTableDataSource: NSObject {
//    enum Row {
//        case textInstructions
//
//        var reuseIdentifier: String {
//            case .textInstructions:
//            return TextInstructionTableViewCell.reuseIdentifier
//        }
//    }
//}
