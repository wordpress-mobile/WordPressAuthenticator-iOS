import UIKit
import WordPressAuthenticator

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Error domain is \(WordPressAuthenticator.errorDomain)")
    }
}
