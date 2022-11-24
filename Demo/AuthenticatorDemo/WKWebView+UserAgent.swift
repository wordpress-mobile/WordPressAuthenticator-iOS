import WebKit

extension WKWebView {

    static var userAgent: String {
        guard let userAgent = Self().value(forKey: "_userAgent") as? String, userAgent.isEmpty == false else {
            return ""
        }
        return userAgent
    }
}
