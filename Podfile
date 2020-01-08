source 'https://cdn.cocoapods.org/'

inhibit_all_warnings!
use_frameworks!

platform :ios, '11.0'

def wordpress_authenticator_pods
  ## Automattic libraries
  ## ====================
  ##
  pod 'Gridicons', '~> 0.15'
  pod 'WordPressUI', '~> 1.4-beta.1'
  pod 'WordPressKit', '~> 4.5.6-beta.1'
  # pod 'WordPressKit', :git => 'https://github.com/wordpress-mobile/WordPressKit-iOS.git', :branch => 'issue/apple_2fa_auth'
  pod 'WordPressShared', '~> 1.8'

  ## Third party libraries
  ## =====================
  ##
  pod '1PasswordExtension', '1.8.5'
  pod 'Alamofire', '4.7.3'
  pod 'CocoaLumberjack', '3.5.2'
  pod 'GoogleSignIn', '4.4.0'
  pod 'lottie-ios', '2.5.2'
  pod 'NSURL+IDN', '0.3'
  pod 'SVProgressHUD', '2.2.5'
end

## WordPress Authenticator
## =======================
##
target 'WordPressAuthenticator' do
  project 'WordPressAuthenticator.xcodeproj'
  wordpress_authenticator_pods
end

## Unit Tests
## ==========
##
target 'WordPressAuthenticatorTests' do
  project 'WordPressAuthenticator.xcodeproj'
  wordpress_authenticator_pods

  pod 'OHHTTPStubs', '8.0.0'
  pod 'OHHTTPStubs/Swift', '8.0.0'
  pod 'OCMock', '~> 3.4'
  pod 'Expecta', '1.0.6'
  pod 'Specta', '1.0.7'
end
