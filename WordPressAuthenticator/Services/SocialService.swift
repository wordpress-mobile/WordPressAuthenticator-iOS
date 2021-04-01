
// MARK: - Social Services Metadata
//
public enum SocialService {

    /// Google's Signup Linked Account
    ///
    case google(user: GoogleUser)

    /// Apple's Signup Linked Account
    ///
    case apple(user: AppleUser)
}

public protocol SocialUser {
    var email: String { get }
    var fullName: String { get }
}

// Struct to contain information relevant to an Apple ID account.
public struct AppleUser: SocialUser {
    public var email: String
    public var fullName: String
}

// Struct to contain information relevant to a Google ID account.
public struct GoogleUser: SocialUser {
    public var email: String
    public var fullName: String
}
