source 'https://github.com/CocoaPods/specs.git'

inhibit_all_warnings!
use_frameworks!

platform :ios, '10.0'
plugin 'cocoapods-repo-update'

def wordpress_authenticator_pods
  ## Automattic libraries
  ## ====================
  ##
  pod 'Gridicons', '~> 0.15'
  pod 'WordPressUI', '~> 1.0'
  pod 'WordPressKit', '~> 4.0.0-beta'
  pod 'WordPressShared', '~> 1.7.5-beta.1'

  ## Third party libraries
  ## =====================
  ##
  pod '1PasswordExtension', '1.8.5'
  pod 'Alamofire', '4.7.3'
  pod 'CocoaLumberjack', '3.4.2'
  pod 'GoogleSignIn', '4.1.2'
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

  pod 'OHHTTPStubs', '6.1.0'
  pod 'OHHTTPStubs/Swift', '6.1.0'
  pod 'OCMock', '~> 3.4'
  pod 'Expecta', '1.0.6'
  pod 'Specta', '1.0.7'
end
