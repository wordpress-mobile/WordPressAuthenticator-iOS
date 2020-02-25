// Based on this article by @NatashaTheRobot:
// https://www.natashatherobot.com/protocol-oriented-segue-identifiers-swift/

public protocol AuthNUXSegueHandler {
    associatedtype SegueIdentifier: RawRepresentable
}

extension AuthNUXSegueHandler where Self: AuthNUXViewController {
    public func performSegue(withIdentifier identifier: AuthNUXViewController.SegueIdentifier, sender: AnyObject?) {
        performSegue(withIdentifier: identifier.rawValue, sender: sender)
    }
}
