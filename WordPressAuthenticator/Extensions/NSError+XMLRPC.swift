import Foundation

extension NSError {
    func originalErrorOrError() -> NSError {
        guard let err = userInfo[XMLRPCOriginalErrorKey] as? NSError else {
            return self
        }

        return err
    }
}
