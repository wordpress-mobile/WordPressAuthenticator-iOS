import Foundation

extension LoginFacade {
    private var tracker: AuthenticatorAnalyticsTracker {
        AuthenticatorAnalyticsTracker.shared
    }
    
    func requestOneTimeCode(with loginFields: LoginFields, completion: @escaping (_ error: Error?, _ success: Bool) -> Void) {
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

                completion(nil, true)
        }) { error in
            /// So these new completion handlers allow API request failure messages to bubble up to the user layer.
            /// However, we receive a false negative in this situation. The API reports a failure, but still successfully
            /// sends an SMS OTP. So we'll log it, but not report the error to the user.
            DDLogError("Possible failure when requesting a one time code: \(error?.localizedDescription)")
            completion(nil, true)
        }
    }

    func requestSocial2FACode(with loginFields: LoginFields, completion: @escaping (_ error: Error?, _ success: Bool) -> Void) {
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

                completion(nil, true)
        }) { (error, newNonce) in
            guard let newNonce = newNonce else {
                DDLogError("Failed to request one time code");
                completion(error, false)
                return
            }

            loginFields.nonceInfo?.nonceSMS = newNonce
            completion(nil, true)
        }
    }
    
    @objc
    public func trackSuccess() {
        tracker.track(step: .success)
    }
}
