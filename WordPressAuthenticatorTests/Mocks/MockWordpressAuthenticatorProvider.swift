@testable import WordPressAuthenticator

struct MockWordpressAuthenticatorProvider {
    static func wordPressAuthenticatorConfiguration() -> WordPressAuthenticatorConfiguration {
        return WordPressAuthenticatorConfiguration(wpcomClientId: "23456",
                                                   wpcomSecret: "arfv35dj57l3g2323",
                                                   wpcomScheme: "https",
                                                   wpcomTermsOfServiceURL: "https://wordpress.com/tos/",
                                                   googleLoginClientId: "",
                                                   googleLoginServerClientId: "",
                                                   googleLoginScheme: "https",
                                                   userAgent: "")
    }
    
    static func wordPressAuthenticatorStyle(_ style: AuthenticatorStyeType) -> WordPressAuthenticatorStyle {
        var wpAuthStyle: WordPressAuthenticatorStyle!
        
        switch style {
        case .random:
            wpAuthStyle = WordPressAuthenticatorStyle(primaryNormalBackgroundColor: UIColor.random(),
                                                      primaryNormalBorderColor: UIColor.random(),
                                                      primaryHighlightBackgroundColor: UIColor.random(),
                                                      primaryHighlightBorderColor: UIColor.random(),
                                                      secondaryNormalBackgroundColor: UIColor.random(),
                                                      secondaryNormalBorderColor: UIColor.random(),
                                                      secondaryHighlightBackgroundColor: UIColor.random(),
                                                      secondaryHighlightBorderColor: UIColor.random(),
                                                      disabledBackgroundColor: UIColor.random(),
                                                      disabledBorderColor: UIColor.random(),
                                                      primaryTitleColor: UIColor.random(),
                                                      secondaryTitleColor: UIColor.random(),
                                                      disabledTitleColor: UIColor.random(),
                                                      textButtonColor: UIColor.random(),
                                                      textButtonHighlightColor: UIColor.random(),
                                                      instructionColor: UIColor.random(),
                                                      subheadlineColor: UIColor.random(),
                                                      placeholderColor: UIColor.random(),
                                                      viewControllerBackgroundColor: UIColor.random(),
                                                      textFieldBackgroundColor: UIColor.random(),
                                                      navBarImage: UIImage(color: UIColor.random()),
                                                      navBarBadgeColor: UIColor.random(),
                                                      navBarBackgroundColor: UIColor.random())
        case .wordpressStandard:
            wpAuthStyle = WordPressAuthenticatorStyle(primaryNormalBackgroundColor: UIColor.black,
                                                      primaryNormalBorderColor: UIColor.black,
                                                      primaryHighlightBackgroundColor: UIColor.black,
                                                      primaryHighlightBorderColor: UIColor.black,
                                                      secondaryNormalBackgroundColor: UIColor.black,
                                                      secondaryNormalBorderColor: UIColor.black,
                                                      secondaryHighlightBackgroundColor: UIColor.black,
                                                      secondaryHighlightBorderColor: UIColor.black,
                                                      disabledBackgroundColor: UIColor.black,
                                                      disabledBorderColor: UIColor.black,
                                                      primaryTitleColor: UIColor.black,
                                                      secondaryTitleColor: UIColor.black,
                                                      disabledTitleColor: UIColor.black,
                                                      textButtonColor: UIColor.black,
                                                      textButtonHighlightColor: UIColor.black,
                                                      instructionColor: UIColor.black,
                                                      subheadlineColor: UIColor.black,
                                                      placeholderColor: UIColor.black,
                                                      viewControllerBackgroundColor: UIColor.black,
                                                      textFieldBackgroundColor: UIColor.black,
                                                      navBarImage: UIImage(color: UIColor.black),
                                                      navBarBadgeColor: UIColor.black,
                                                      navBarBackgroundColor: UIColor.black)
        }
        return wpAuthStyle
    }
}

enum AuthenticatorStyeType {
    case random
    case wordpressStandard
}


extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
            red:   .random(),
            green: .random(),
            blue:  .random(),
            alpha: 1.0
        )
    }
}
