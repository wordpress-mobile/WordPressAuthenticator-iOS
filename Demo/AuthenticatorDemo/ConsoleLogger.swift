import WordPressKit

class ConsoleLogger: NSObject, WordPressLoggingDelegate {

    func logError(_ str: String) {
        print("❌ – Error: \(str)")
    }

    func logWarning(_ str: String) {
        print("⚠️ – Warning: \(str)")
    }

    func logInfo(_ str: String) {
        print("ℹ️ – Info: \(str)")
    }

    func logDebug(_ str: String) {
        print("🔎 – Debug: \(str)")
    }

    func logVerbose(_ str: String) {
        print("📃 – Verbose: \(str)")
    }
}
