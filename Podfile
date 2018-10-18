source 'https://github.com/CocoaPods/specs.git'

inhibit_all_warnings!
use_frameworks!

platform :ios, '10.0'


## WordPress Authenticator
## =======================
##
target 'WordPressAuthenticator' do
  project 'WordPressAuthenticator.xcodeproj'

  ## Automattic libraries
  ## ====================
  ##
  pod 'Gridicons', '~> 0.15'
  pod 'WordPressUI', '~> 1.0'
  pod 'WordPressKit', '~> 1.4.2-beta.3'
  pod 'WordPressShared', '~> 1.2.0-beta.1'
  pod 'wpxmlrpc', '~> 0.8'

  ## Third party libraries
  ## =====================
  ##
  pod '1PasswordExtension', '1.8.5'
  pod 'Alamofire', '4.7.3'
  pod 'CocoaLumberjack', '3.4.2'
  pod 'GoogleSignInRepacked', '4.1.2'
  pod 'lottie-ios', '2.5.0'
  pod 'NSURL+IDN', '0.3'
  pod 'SVProgressHUD', '2.2.5'
  pod 'UIDeviceIdentifier', '~> 0.4'


  ## Unit Tests
  ## ==========
  ##
  target 'WordPressAuthenticatorTests' do
    inherit! :search_paths

    pod 'OHHTTPStubs', '6.1.0'
    pod 'OHHTTPStubs/Swift', '6.1.0'
    pod 'OCMock', '~> 3.4'
    pod 'Expecta', '1.0.6'
    pod 'Specta', '1.0.7'
  end
end
