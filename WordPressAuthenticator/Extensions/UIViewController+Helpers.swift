import Foundation


// MARK - UIViewController Helpers
extension UIViewController {

    /// Convenience method to instantiate a view controller from a storyboard.
    ///
    static func instantiate(from storyboard: Storyboard) -> Self? {
        return storyboard.instantiateViewController(ofClass: self)
    }

    /// Convenience method to load the nib associated with the view controller.
    ///
    static func loadFromNib() -> Self {
        func instantiateFromNib<T: UIViewController>() -> T {
            return T.init(nibName: String(describing: T.self), bundle: nil)
        }

        return instantiateFromNib()
    }
}
