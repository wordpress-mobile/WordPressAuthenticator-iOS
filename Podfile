# frozen_string_literal: true

source 'https://cdn.cocoapods.org/'

inhibit_all_warnings!
use_frameworks!

ios_deployment_target = Gem::Version.new('13.0')

platform :ios, ios_deployment_target

## Third party libraries
## =====================
##
def third_party_pods
  pod '1PasswordExtension', '1.8.6'
  pod 'Alamofire', '4.8'
  pod 'CocoaLumberjack', '3.5.2'
  pod 'GoogleSignIn', '6.0.1'
  pod 'lottie-ios', '3.1.6'
  pod 'NSURL+IDN', '0.4'
  pod 'SVProgressHUD', '2.2.5'
end

def wordpress_authenticator_pods
  ## Automattic libraries
  ## ====================
  ##
  pod 'Gridicons', '~> 1.0-beta' # Don't change this until we hit 2.0 in Gridicons
  pod 'WordPressUI', '~> 1.7-beta' # Don't change this until we hit 2.0 in WordPressUI
  pod 'WordPressKit', '~> 4.18-beta' # Don't change this until we hit 5.0 in WPKit
  pod 'WordPressShared', '~> 1.12-beta' # Don't change this until we hit 2.0 in WPShared

  third_party_pods
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

  pod 'OCMock', '~> 3.4'
  pod 'Expecta', '1.0.6'
  pod 'Specta', '1.0.7'

  post_install do |installer|
    # Let Pods targets inherit deployment target from the app
    # This solution is suggested here: https://github.com/CocoaPods/CocoaPods/issues/4859
    # =====================================
    #
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |configuration|
        pod_ios_deployment_target = Gem::Version.new(configuration.build_settings['IPHONEOS_DEPLOYMENT_TARGET'])
        configuration.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET' if pod_ios_deployment_target <= ios_deployment_target
      end
    end
  end
end
