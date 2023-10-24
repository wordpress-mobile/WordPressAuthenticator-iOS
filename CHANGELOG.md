# Changelog

The format of this document is inspired by [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) and the project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

<!-- This is a comment, you won't see it when GitHub renders the Markdown file.

When releasing a new version:

1. Remove any empty section (those with `_None._`)
2. Update the `## Unreleased` header to `## <version_number>`
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

## 7.2.1

### Bug Fixes

- Fix an issue where `guessXMLRPCURL` was called with an URL without a scheme resulting in an error. [#792]
- Fix an issue that leads to an ambiguous error message when an incorrect SMS 2FA code is submitted. [#793]

## 7.2.0

### New Features

- Added security keys support as a two-factor authentication method.

### Internal Changes

- Bump WordPressKit dependency to `~> 8.7-beta`

## 7.0.0

### Breaking Changes

- Removed dependency GoogleSignIn SDK and flags to configure it [#777]
- Made `LoginFieldsMeta` `internal`, forwarding the few properties read by clients to `LoginFields` [#778]
- Restructured `SocialService` into `SocialUser`, removing the `SocialServiceName` `SocialService` `enum` cases duplicity [#778]
- Made `presentSignupEpilogue` in `WordPressAuthenticatorDelegateProtocol` use `SocialUser` instead of `SocialService` [#778]

## 6.4.0

### New Features

- Update button style and position on the prologue screen when `enableSiteCreation` and `enableSiteAddressLoginOnlyInPrologue` configs are enabled.

## 6.3.0

_Note: This should have been 6.2.1 because it contained only a bug fix. Unfortunately we currently don't have automation in place to enfore SemVer. Given a beta had already been released, we went with 6.3.0 stable._

### Bug Fixes

- Fix retain cycles by using `weak self` in action closures. [#775]

## 6.2.0

### Bug Fixes

- Remove the redundant and ambiguous config `enableSiteCredentialLoginForJetpackSites`. [#771]

## 6.1.0

### New Features

- Support navigating to the WPCom login flow with an existing email through `NavigateToEnterAccount`. [#767]

### Bug Fixes

- Always trigger `completionHandler` if possible when site credential login finishes. [#768]

### Internal Changes

- Bump WordPressKit dependency to `~> 8.0-beta`

## 6.0.0

### Breaking Changes

- `SocialService` `apple` associated type is now `User` instead of `AppleUser`. [#763]
- `SocialService` `google` associated type is now `User` instead of `GIDGoogleUser`. [#764]

### New Features

- Google's `IDToken` now exposes the user's full name via `name`. [#761]

## 5.7.0

### New Features

- New configuration and delegate method to handle site credential login failure manually. [#758]

## 5.6.0

### New Features

- It's now possible to authenticate with a Google account without using the Google SDK, via the `googleLoginWithoutSDK` configuration. [#743]

### Internal Changes

- Change minimum version of WordPressKit to 7.0 [#754]

## 5.5.0

### New Features

- Make `WordPressComAccountService` public to external access [#746]
- Make `MailPresenter` and `AppSelector` public to external access [#749]

## 5.4.0

### New Features

-  New configuration to disable site credential login on Get Started screen for the site address login flow [#742]

## 5.3.0

### New Features

-  Add new config to remove XMLRPC check for site address login [#736]

## 5.2.0

### Internal Changes

- Change minimum version of WordPressKit to 6.0.

## 5.1.0

### New Features

- New configuration for site address login only on the prologue screen. [#725]

### Bug Fixes

- Fix unresponsive issue in Onboading Questions screen. [#719]
- Use configuration flag to log custom `step` event for `GetStartedViewController`. [#724]

## 5.0.0

### Breaking Changes

- Remove CocoaLumberjack. Use `WPAuthenticatorSetLoggingDelegate` to assign a logger to this library. [#708]

## 4.3.0

### New Features

- Make XMLRPC URL optional when verifying WP.com email [#711]
- A new config is added to skip the XMLRPC check for the site discovery flow [#711]

## 4.2.0

### New Features

- New tracking event for XMLRPC related failure. by @selanthiraiyan [#701]

## 4.1.1

### New Features

- New `NUXStackedButtonsViewController` with two stack views and a configurable OR divider. by @selanthiraiyan [#695]
- Add OR divider colors to `WordPressAuthenticatorStyle` with default values. @selanthiraiyan [#695]

### Internal Changes

- There have been [new changes to how `UIPasteboard` works](https://sarunw.com/posts/uipasteboard-privacy-change-ios16/) in iOS 16.0. This makes the unit tests from `PasteboardTests` fail. I have [skipped those tests for iOS 16.0](https://github.com/wordpress-mobile/WordPressAuthenticator-iOS/pull/695/files#diff-ba468f6db6f592cdacdb632f7783a721c5eb856e8ab66765e8e59aabc2c1a7b4R13-R16) and created a GH issue [here](https://github.com/wordpress-mobile/WordPressAuthenticator-iOS/issues/696) to keep track of this. by @selanthiraiyan [#695]

## 4.0.0

### Breaking Changes

- Allow the host app to pass a custom source identifier to the login flow. [#692]

### New Features

- New configuration options for the simplified login flow. [#691]

### Bug Fixes

_None._

### Internal Changes

- Add this changelog file. [#690]
- Remove Alamofire as an explicit dependency. [#689]
