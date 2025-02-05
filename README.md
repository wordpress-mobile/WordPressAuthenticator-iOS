<!-- red -->
> [!CAUTION]
> This repository has been archived and its functionality has been merged into its only two former clients: [WordPress/Jetpack iOS](https://github.com/wordpress-mobile/WordPress-iOS/tree/07ce020686a324112941274e8e5536682ded9278/WordPressAuthenticator) and [WooCommerce iOS](https://github.com/woocommerce/woocommerce-ios/pull/15000).
> 
> Future development will continue in those repositories.

---
 
# WordPressAuthenticator-iOS

WordPressAuthenticator implements an easy and elegant way to authenticate your WordPress Apps. 

This framework encapsulates everything required to display the Authentication UI and perform authentication against WordPress.com and WordPress.org sites.

Plus: WordPress.com *signup*  is supported.

## Setup

```sh
# Install required ruby version
rbenv install -s

# Install bundler and Gemfile dependencies
gem install bundler
bundle install

# Install CocoaPods dependencies
bundle exec pod install
```

## Integrating the Library with CocoaPods

WordPressAuthenticator is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```bash
pod "WordPressAuthenticator"
```
