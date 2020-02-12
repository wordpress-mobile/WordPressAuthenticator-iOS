import Foundation


extension UIViewController {

    static func instantiate(from storyboard: Storyboard) -> Self? {
        return storyboard.instantiateViewController(ofClass: self)
    }
}
