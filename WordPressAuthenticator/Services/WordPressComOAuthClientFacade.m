#import "WordPressComOAuthClientFacade.h"
#import "WPAuthenticator-Swift.h"
@import WordPressKit;

@interface WordPressComOAuthClientFacade ()

@property (nonatomic, strong) WordPressComOAuthClient *client;

@end

@implementation WordPressComOAuthClientFacade

@synthesize client;

- (instancetype)initWithClient:(NSString *)client secret:(NSString *)secret
{
    NSParameterAssert(client);
    NSParameterAssert(secret);
    self = [super init];
    if (self) {
        self.client = [WordPressComOAuthClientFacade initializeOAuthClientWithClientID:client secret:secret];
    }

    return self;
}

- (instancetype)init {
    NSAssert(false, @"Please initializer WordPressComOAuthClientFacade with the ClientID and Secret!");
    return nil;
}

- (void)authenticateWithUsername:(NSString *)username
                        password:(NSString *)password
                 multifactorCode:(NSString *)multifactorCode
                         success:(void (^)(NSString *authToken))success
                needsMultiFactor:(void (^)(NSInteger userID, SocialLogin2FANonceInfo *nonceInfo))needsMultifactor
                         failure:(void (^)(NSError *error))failure
{
    [self.client authenticateWithUsername:username password:password multifactorCode:multifactorCode needsMultifactor:needsMultifactor success:success failure:^(NSError * error) {
        if (error.code == WordPressComOAuthErrorNeedsMultifactorCode) {
            if (needsMultifactor != nil) {
                needsMultifactor(0, nil);
            }
        } else {
            if (failure != nil) {
                failure(error);
            }
        }
    }];
}

- (void)requestOneTimeCodeWithUsername:(NSString *)username
                              password:(NSString *)password
                               success:(void (^)(void))success
                               failure:(void (^)(NSError *error))failure
{
    [self.client requestOneTimeCodeWithUsername:username password:password success:success failure:failure];
}

- (void)requestSocial2FACodeWithUserID:(NSInteger)userID
                                 nonce:(NSString *)nonce
                               success:(void (^)(NSString *newNonce))success
                               failure:(void (^)(NSError *error, NSString *newNonce))failure
{
    [self.client requestSocial2FACodeWithUserID:userID nonce:nonce success:success failure:failure];
}

- (void)authenticateWithSocialIDToken:(NSString *)token
                              service:(NSString *)service
                              success:(void (^)(NSString *authToken))success
                     needsMultiFactor:(void (^)(NSInteger userID, SocialLogin2FANonceInfo *nonceInfo))needsMultifactor
          existingUserNeedsConnection:(void (^)(NSString *email))existingUserNeedsConnection
                              failure:(void (^)(NSError *error))failure
{
    [self.client authenticateWithIDToken:token
                                 service:service
                                 success:success
                        needsMultifactor:needsMultifactor
             existingUserNeedsConnection:existingUserNeedsConnection
                                 failure:failure];
}

- (void)authenticateSocialLoginUser:(NSInteger)userID
                           authType:(NSString *)authType
                        twoStepCode:(NSString *)twoStepCode
                       twoStepNonce:(NSString *)twoStepNonce
                            success:(void (^)(NSString *authToken))success
                            failure:(void (^)(NSError *error))failure
{
    [self.client authenticateSocialLoginUser:userID authType:authType twoStepCode:twoStepCode twoStepNonce:twoStepNonce success:success failure:failure];
}

- (void) requestWebauthnChallengeWithUserID: (NSInteger)userID
                               twoStepNonce:(NSString *)twoStepNonce
                                    success:(void (^)(WebauthnChallengeInfo *challengeData))success
                                    failure:(void (^)(NSError *error))failure {
    [self.client requestWebauthnChallengeWithUserID:userID twoStepNonce:twoStepNonce success:success failure:failure];
}

- (void) authenticateWebauthnSignatureWithUserID:(NSInteger)userID
                                    twoStepNonce:(NSString *)twoStepNonce
                                    credentialID:(NSData *)credentialID
                                  clientDataJson:(NSData *)clientDataJson
                               authenticatorData:(NSData *)authenticatorData
                                       signature:(NSData *)signature
                                      userHandle:(NSData *)userHandle
                                         success:(void (^)(NSString *authToken))success
                                         failure:(void (^)(NSError *error))failure {
    [self.client authenticateWebauthnSignatureWithUserID:userID
                                            twoStepNonce:twoStepNonce
                                            credentialID:credentialID
                                          clientDataJson:clientDataJson
                                       authenticatorData:authenticatorData
                                               signature:signature
                                              userHandle:userHandle
                                                 success:success
                                                 failure:failure];
}

@end
