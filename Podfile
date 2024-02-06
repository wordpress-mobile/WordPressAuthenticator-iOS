# frozen_string_literal: true

source 'https://cdn.cocoapods.org/'
# It can take CocoaPods some time to propagate new versions.
# To avoid waiting, we also publish our pods to our own specs repo.
source 'https://github.com/wordpress-mobile/cocoapods-specs.git'

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
  pod 'NSURL+IDN', '0.4'
  pod 'SVProgressHUD', '2.2.5'
end

def wordpress_authenticator_pods
  ## Automattic libraries
  ## ====================
  ##
  ## These should match the version requirement from the podspec.
  pod 'Gridicons', '~> 1.0'
  pod 'WordPressUI', '~> 1.7-beta'
  pod 'WordPressKit', '~> 13.0'
  pod 'WordPressShared', '~> 2.1-beta'

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
