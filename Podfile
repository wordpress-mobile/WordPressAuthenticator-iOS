# frozen_string_literal: true

source 'https://cdn.cocoapods.org/'

inhibit_all_warnings!
use_frameworks!

ios_deployment_target = Gem::Version.new('13.0')

platform :ios, ios_deployment_target

# This Podfile defines dependencies across multiple `.xcodeproj` files, so we
# need to explicitly define the workspace to use.
workspace 'WordPressAuthenticator.xcworkspace'

## Third party libraries
## =====================
##
def third_party_pods
  pod 'GoogleSignIn', '6.0.1'
  pod 'NSURL+IDN', '0.4'
  pod 'SVProgressHUD', '2.2.5'
end

def wordpress_authenticator_pods
  ## Automattic libraries
  ## ====================
  ##
  pod 'Gridicons', '~> 1.0-beta' # Don't change this until we hit 2.0 in Gridicons
  pod 'WordPressUI', '~> 1.7-beta' # Don't change this until we hit 2.0 in WordPressUI
  pod 'WordPressKit', '~> 5.0-beta' # Don't change this until we hit 5.0 in WPKit
  pod 'WordPressShared', '~> 2.0-beta' # Don't change this until we hit 2.0 in WPShared

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
end

target 'AuthenticatorDemo' do
  project 'Demo/AuthenticatorDemo.xcodeproj'

  pod 'WordPressAuthenticator', path: '.'
end

# Used to donwload CLI tools.
abstract_target 'Tools' do
  pod 'SwiftLint', '~> 0.49'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |configuration|
      # Let Pods targets inherit deployment target from the app
      # This solution is suggested here: https://github.com/CocoaPods/CocoaPods/issues/4859
      pod_ios_deployment_target = Gem::Version.new(configuration.build_settings['IPHONEOS_DEPLOYMENT_TARGET'])
      configuration.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET' if pod_ios_deployment_target <= ios_deployment_target

      # This addresses Xcode 12, 13, and 14 showing an "Update to recommended
      # settings" warning on the Pods project.
      #
      # See:
      #
      # - https://github.com/CocoaPods/CocoaPods/issues/10189
      # - https://github.com/CocoaPods/CocoaPods/issues/11553
      configuration.build_settings.delete 'ARCHS'
      configuration.build_settings['DEAD_CODE_STRIPPING'] = 'YES'
    end
  end
end
