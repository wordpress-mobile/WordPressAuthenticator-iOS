import Foundation
import WordPressKit

extension LoginFacade {
    private var tracker: AuthenticatorAnalyticsTracker {
        AuthenticatorAnalyticsTracker.shared
    }

    func requestOneTimeCode(with loginFields: LoginFields) {
        wordpressComOAuthClientFacade.requestOneTimeCode(
            withUsername: loginFields.username,
            password: loginFields.password,
            success: { [weak self] in
                guard let self = self else {
                    return
                }

                if self.tracker.shouldUseLegacyTracker() {
                    WordPressAuthenticator.track(.twoFactorSentSMS)
                }
        }) { _ in
            WPAuthenticatorLogError("Failed to request one time code")
        }
    }

    func requestSocial2FACode(with loginFields: LoginFields) {
        guard let nonce = loginFields.nonceInfo?.nonceSMS else {
            return
        }

        wordpressComOAuthClientFacade.requestSocial2FACode(
            withUserID: loginFields.nonceUserID,
            nonce: nonce,
            success: { [weak self] newNonce in
                guard let self = self else {
                    return
                }

                if let newNonce = newNonce {
                    loginFields.nonceInfo?.nonceSMS = newNonce
                }

                if self.tracker.shouldUseLegacyTracker() {
                    WordPressAuthenticator.track(.twoFactorSentSMS)
                }
        }) { (_, newNonce) in
            if let newNonce = newNonce {
                loginFields.nonceInfo?.nonceSMS = newNonce
            }
            WPAuthenticatorLogError("Failed to request one time code")
        }
    }

    /// Async function that returns the necessary `WebauthnChallengeInfo` to start allow for a security key log in.
    ///
    func requestWebauthnChallenge(userID: Int, twoStepNonce: String) async -> WebauthnChallengeInfo? {

        delegate?.displayLoginMessage?(NSLocalizedString("Waiting for security key", comment: "Text while waiting for a security key challenge"))

        return await withCheckedContinuation { continuation in
            wordpressComOAuthClientFacade.requestWebauthnChallenge(withUserID: userID, twoStepNonce: twoStepNonce, success: { challengeInfo in
                if let challengeInfo {
                    continuation.resume(returning: challengeInfo)
                }

            }, failure: { [weak self] error in
                guard let self else { return }
                if let error {
                    WPAuthenticatorLogError("Failed to request webauthn challenge \(error)")
                    WordPressAuthenticator.track(.loginFailed, error: error)
                    continuation.resume(returning: nil)

                    DispatchQueue.main.async {
                        self.delegate?.displayRemoteError?(error)
                    }
                }
            })
        }
    }

    /// Forwards the authentication signature message and updates delegates accordingly.
    ///
    func authenticateWebauthnSignature(userID: Int,
                                       twoStepNonce: String,
                                       credentialID: Data,
                                       clientDataJson: Data,
                                       authenticatorData: Data,
                                       signature: Data,
                                       userHandle: Data) {

        delegate?.displayLoginMessage?(NSLocalizedString("Waiting for security key", comment: "Text while the webauthn signature is being verified"))

        wordpressComOAuthClientFacade.authenticateWebauthnSignature(withUserID: userID,
                                                                    twoStepNonce: twoStepNonce,
                                                                    credentialID: credentialID,
                                                                    clientDataJson: clientDataJson,
                                                                    authenticatorData: authenticatorData,
                                                                    signature: signature,
                                                                    userHandle: userHandle,
                                                                    success: { [weak self] accessToken in
            if let accessToken {
                self?.delegate?.finishedLogin?(withNonceAuthToken: accessToken)
                self?.trackSuccess()
            }

        }, failure: { [weak self] error in
            if let error {
                WPAuthenticatorLogError("Failed to verify webauthn signature \(error)")
                WordPressAuthenticator.track(.loginFailed, error: error)
                self?.delegate?.displayRemoteError?(error)
            }
        })
    }

    @objc
    public func trackSuccess() {
        tracker.track(step: .success)
    }
}
