Pod::Spec.new do |s|
  s.name          = "WordPressAuthenticator"
  s.version       = "1.10.7-beta.1"
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

  s.dependency '1PasswordExtension', '1.8.5'
  s.dependency 'Alamofire', '4.7.3'
  s.dependency 'CocoaLumberjack', '~> 3.5'
  s.dependency 'lottie-ios', '2.5.2'
  s.dependency 'NSURL+IDN', '0.3'
  s.dependency 'SVProgressHUD', '2.2.5'

  s.dependency 'Gridicons', '~> 0.15'
  s.dependency 'GoogleSignIn', '~> 4.4'
  s.dependency 'WordPressUI', '~> 1.4-beta.1'
  s.dependency 'WordPressKit', '~> 4.5.6-beta.1'
  s.dependency 'WordPressShared', '~> 1.8'
end
