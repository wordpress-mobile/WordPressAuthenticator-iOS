import Foundation
import WordPressKit

@objc public class WordPressComOAuthClientFacade: NSObject, WordPressComOAuthClientFacadeProtocol {

    private let client: WordPressComOAuthClient

    @objc required public init(client: String, secret: String) {
        self.client = WordPressComOAuthClient(clientID: client,
                                         secret: secret,
                                         wordPressComBaseUrl: WordPressAuthenticator.shared.configuration.wpcomBaseURL,
                                         wordPressComApiBaseUrl: WordPressAuthenticator.shared.configuration.wpcomAPIBaseURL)
    }

    public func authenticate(
        username: String,
        password: String,
        multifactorCode: String?,
        success: @escaping (_ authToken: String?) -> Void,
        needsMultifactor: ((_ userID: Int, _ nonceInfo: SocialLogin2FANonceInfo?) -> Void)?,
        failure: ((_ error: Error) -> Void)?
    ) {
        self.client.authenticateWithUsername(username, password: password, multifactorCode: multifactorCode, needsMultifactor: needsMultifactor, success: success, failure: { error in
            if error.code == WordPressComOAuthError.needsMultifactorCode.rawValue {
                needsMultifactor?(0, nil)
            } else {
                failure?(error)
            }
        })
    }

    public func requestOneTimeCode(
        username: String,
        password: String,
        success: @escaping () -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        self.client.requestOneTimeCodeWithUsername(username, password: password, success: success, failure: failure)
    }

    public func requestSocial2FACode(
        userID: Int,
        nonce: String,
        success: @escaping (_ newNonce: String) -> Void,
        failure: @escaping (_ error: Error, _ newNonce: String?) -> Void
    ) {
        self.client.requestSocial2FACodeWithUserID(userID, nonce: nonce, success: success, failure: failure)
    }

    public func authenticate(
        socialIDToken: String,
        service: String,
        success: @escaping (_ authToken: String?) -> Void,
        needsMultifactor: @escaping (_ userID: Int, _ nonceInfo: SocialLogin2FANonceInfo) -> Void,
        existingUserNeedsConnection: @escaping (_ email: String) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        self.client.authenticateWithIDToken(
            socialIDToken,
            service: service,
            success: success,
            needsMultifactor: needsMultifactor,
            existingUserNeedsConnection: existingUserNeedsConnection,
            failure: failure
        )
    }

    public func authenticate(
        socialLoginUser userID: Int,
        authType: String,
        twoStepCode: String,
        twoStepNonce: String,
        success: @escaping (_ authToken: String?) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        self.client.authenticateSocialLoginUser(
            userID,
            authType: authType,
            twoStepCode: twoStepCode,
            twoStepNonce: twoStepNonce,
            success: success,
            failure: failure
        )
    }

    public func requestWebauthnChallenge(
        userID: Int64,
        twoStepNonce: String,
        success: @escaping (_ challengeData: WebauthnChallengeInfo) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        self.client.requestWebauthnChallenge(userID: userID, twoStepNonce: twoStepNonce, success: success, failure: failure)
    }

    public func authenticateWebauthnSignature(
        userID: Int64,
        twoStepNonce: String,
        credentialID: Data,
        clientDataJson: Data,
        authenticatorData: Data,
        signature: Data,
        userHandle: Data,
        success: @escaping (_ authToken: String) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) {
        self.client.authenticateWebauthnSignature(
            userID: userID,
            twoStepNonce: twoStepNonce,
            credentialID: credentialID,
            clientDataJson: clientDataJson,
            authenticatorData: authenticatorData,
            signature: signature,
            userHandle: userHandle,
            success: success,
            failure: failure
        )
    }

}
