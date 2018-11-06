Pod::Spec.new do |s|
  s.name          = "WordPressAuthenticator"
  s.version       = "1.1.5"
  s.summary       = "WordPressAuthenticator implements an easy and elegant way to authenticate your WordPress Apps."

  s.description   = <<-DESC
                    This framework encapsulates everything required to display the Authentication UI
                    and perform authentication against WordPress.com and WordPress.org sites.

                    Plus: WordPress.com *signup*  is supported.
                    DESC

  s.homepage      = "http://apps.wordpress.com"
  s.license       = "GPLv2"
  s.author        = { "WordPress" => "mobile@automattic.com" }
  s.platform      = :ios, "10.0"
  s.swift_version = '4.2'
  s.source        = { :git => "https://github.com/wordpress-mobile/WordPressAuthenticator-iOS.git", :tag => s.version.to_s }
  s.source_files  = 'WordPressAuthenticator/**/*.{h,m,swift}'
  s.private_header_files = "WordPressAuthenticator/Private/*.h"
  s.resources     = [ 'WordPressAuthenticator/**/*.{xcassets,storyboard,xib,json}' ]
  s.requires_arc  = true
  s.header_dir    = 'WordPressAuthenticator'

  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO' }

  s.dependency '1PasswordExtension', '1.8.5'
  s.dependency 'Alamofire', '4.7.3'
  s.dependency 'CocoaLumberjack', '3.4.2'
  s.dependency 'lottie-ios', '2.5.0'
  s.dependency 'NSURL+IDN', '0.3'
  s.dependency 'SVProgressHUD', '2.2.5'
  s.dependency 'UIDeviceIdentifier', '~> 0.4'

  s.dependency 'Gridicons', '~> 0.15'
  s.dependency 'GoogleSignInRepacked', '4.1.2'
  s.dependency 'WordPressUI', '~> 1.0'
  s.dependency 'WordPressKit', '~> 1.4'
  s.dependency 'WordPressShared', '~> 1.4'
  s.dependency 'wpxmlrpc', '~> 0.8'
end
