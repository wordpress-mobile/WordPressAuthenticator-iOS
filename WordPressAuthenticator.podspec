Pod::Spec.new do |s|
  s.name          = "WordPressAuthenticator"
  s.version       = "1.26.0-beta.12"
  s.summary       = "WordPressAuthenticator implements an easy and elegant way to authenticate your WordPress Apps."

  s.description   = <<-DESC
                    This framework encapsulates everything required to display the Authentication UI
                    and perform authentication against WordPress.com and WordPress.org sites.

                    Plus: WordPress.com *signup*  is supported.
                    DESC

  s.homepage      = "https://github.com/wordpress-mobile/WordPressAuthenticator-iOS"
  s.license       = "GPLv2"
  s.author        = { "WordPress" => "mobile@automattic.com" }
  s.platform      = :ios, "11.0"
  s.swift_version = '4.2'
  s.source        = { :git => "https://github.com/wordpress-mobile/WordPressAuthenticator-iOS.git", :tag => s.version.to_s }
  s.source_files  = 'WordPressAuthenticator/**/*.{h,m,swift}'
  s.private_header_files = "WordPressAuthenticator/Private/*.h"
  s.resource_bundles = {
    'WordPressAuthenticatorResources': [
      'WordPressAuthenticator/Resources/Assets.xcassets',
      'WordPressAuthenticator/Resources/SupportedEmailClients/*.plist',
      'WordPressAuthenticator/Resources/Animations/*.json',
      'WordPressAuthenticator/**/*.{storyboard,xib}'
    ]
  }
  s.requires_arc  = true
  s.static_framework = true # This is needed because GoogleSignIn vendors a static framework
  s.header_dir    = 'WordPressAuthenticator'

  s.dependency '1PasswordExtension', '1.8.6'
  s.dependency 'Alamofire', '4.8'
  s.dependency 'CocoaLumberjack', '~> 3.5'
  s.dependency 'lottie-ios', '3.1.6'
  s.dependency 'NSURL+IDN', '0.4'
  s.dependency 'SVProgressHUD', '2.2.5'

  s.dependency 'Gridicons', '~> 1.0'
  s.dependency 'GoogleSignIn', '~> 5.0.2'
  s.dependency 'WordPressUI', '~> 1.7.0'

  # Use a loose restriction that allows both production and beta versions, up to the next major version.
  # If you want to update which of these is used, specify it in the host app.
  s.dependency 'WordPressKit', '~> 4.18-beta' # Don't change this until we hit 5.0 in WPKit
  s.dependency 'WordPressShared', '~> 1.11-beta' # Don't change this until we hit 2.0 in WPShared
end
