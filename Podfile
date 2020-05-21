source 'https://cdn.cocoapods.org/'

inhibit_all_warnings!
use_frameworks!

platform :ios, '11.0'

def wordpress_authenticator_pods
  ## Automattic libraries
  ## ====================
  ##
  pod 'Gridicons', '~> 1.0'
  pod 'WordPressUI', '~> 1.7.0'
  pod 'WordPressKit', '~> 4.9.0-beta.1'
  pod 'WordPressShared', '~> 1.8.16'

  ## Third party libraries
  ## =====================
  ##
  pod '1PasswordExtension', '1.8.6'
  pod 'Alamofire', '4.8'
  pod 'CocoaLumberjack', '3.5.2'
  pod 'GoogleSignIn', '5.0.2'
  pod 'lottie-ios', '3.1.6'
  pod 'NSURL+IDN', '0.4'
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
