#import <Foundation/Foundation.h>

@protocol WordPressXMLRPCAPIFacadeProtocol

- (instancetype)initWithUserAgent:(NSString *)userAgent;

- (void)guessXMLRPCURLForSite:(NSString *)url
                      success:(void (^)(NSURL *xmlrpcURL))success
                      failure:(void (^)(NSError *error))failure;

- (void)getBlogOptionsWithEndpoint:(NSURL *)xmlrpc
                         username:(NSString *)username
                         password:(NSString *)password
                          success:(void (^)(NSDictionary *options))success
                          failure:(void (^)(NSError *error))failure;

@end

@interface WordPressXMLRPCAPIFacade : NSObject<WordPressXMLRPCAPIFacadeProtocol>

@end
