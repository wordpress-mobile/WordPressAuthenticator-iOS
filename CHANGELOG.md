# Changelog

The format of this document is inspired by [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and the project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- This is a comment, you won't see it when GitHub renders the Markdown file.

When releasing a new version:

1. Remove any empty section (those with `_None._`)
2. Update the `## Unreleased` header to `## [<version_number>](https://github.com/wordpress-mobile/WordPressAuthenticator-iOS/releases/tag/<version_number>)`
3. Add a new "Unreleased" section for the next iteration, by copy/pasting the following template:

## Unreleased

### Breaking Changes

_None._

### New Features

_None._

### Bug Fixes

_None._

### Internal Changes

_None._

-->

## Unreleased

### Breaking Changes

_None._

### New Features

-  Add new config to remove XMLRPC check for site address login [#736]

### Bug Fixes

_None._

### Internal Changes

_None._

## [5.2.0](https://github.com/wordpress-mobile/WordPressAuthenticator-iOS/releases/tag/5.2.0)

### Internal Changes

- Change minimum version of WordPressKit to 6.0.

## [5.1.0](https://github.com/wordpress-mobile/WordPressAuthenticator-iOS/releases/tag/5.1.0)

### New Features

- New configuration for site address login only on the prologue screen. [#725]

### Bug Fixes

- Fix unresponsive issue in Onboading Questions screen. [#719]
- Use configuration flag to log custom `step` event for `GetStartedViewController`. [#724]

## [5.0.0](https://github.com/wordpress-mobile/WordPressAuthenticator-iOS/releases/tag/5.0.0)

### Breaking Changes

- Remove CocoaLumberjack. Use `WPAuthenticatorSetLoggingDelegate` to assign a logger to this library. [#708]

## [4.3.0](https://github.com/wordpress-mobile/WordPressAuthenticator-iOS/releases/tag/4.3.0)

### New Features

- Make XMLRPC URL optional when verifying WP.com email [#711]
- A new config is added to skip the XMLRPC check for the site discovery flow [#711]

## [4.2.0](https://github.com/wordpress-mobile/WordPressAuthenticator-iOS/releases/tag/4.2.0)

### New Features

- New tracking event for XMLRPC related failure. by @selanthiraiyan [#701]

## [4.1.1](https://github.com/wordpress-mobile/WordPressAuthenticator-iOS/releases/tag/4.1.1)

### New Features

- New `NUXStackedButtonsViewController` with two stack views and a configurable OR divider. by @selanthiraiyan [#695]
- Add OR divider colors to `WordPressAuthenticatorStyle` with default values. @selanthiraiyan [#695]

### Internal Changes

- There have been [new changes to how `UIPasteboard` works](https://sarunw.com/posts/uipasteboard-privacy-change-ios16/) in iOS 16.0. This makes the unit tests from `PasteboardTests` fail. I have [skipped those tests for iOS 16.0](https://github.com/wordpress-mobile/WordPressAuthenticator-iOS/pull/695/files#diff-ba468f6db6f592cdacdb632f7783a721c5eb856e8ab66765e8e59aabc2c1a7b4R13-R16) and created a GH issue [here](https://github.com/wordpress-mobile/WordPressAuthenticator-iOS/issues/696) to keep track of this. by @selanthiraiyan [#695]

## [4.0.0](https://github.com/wordpress-mobile/WordPressAuthenticator-iOS/releases/tag/4.0.0)

### Breaking Changes

- Allow the host app to pass a custom source identifier to the login flow. [#692]

### New Features

- New configuration options for the simplified login flow. [#691]

### Bug Fixes

_None._

### Internal Changes

- Add this changelog file. [#690]
- Remove Alamofire as an explicit dependency. [#689]
