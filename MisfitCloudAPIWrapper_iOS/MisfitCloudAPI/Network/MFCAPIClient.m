//
//  MFAPIClient.m
//  MFResearchApp2
//
//  Created by Hai Phan on 2/13/15.
//  Copyright (c) 2015 MF. All rights reserved.
//

#import "MFCAPIClient.h"
#import "FSNConnection.h"

#if DEBUG
static NSString * const kCloudAPIv2BaseURL = @"https://build.int.misfit.com/cloudapi/resource/v2/";
#else
static NSString * const kCloudAPIv2BaseURL = @"https://build.misfit.com/cloudapi/resource/v2/";
#endif
@interface MFCAPIClient()

@property (strong, nonatomic) NSURL * baseURL;
@property (strong, nonatomic) NSMutableDictionary * defaultHeaders;
@end

@implementation MFCAPIClient

static MFCAPIClient *_sharedClient = nil;

+ (MFCAPIClient *)sharedClient
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString * baseUrlString = kCloudAPIv2BaseURL;
        NSURL * baseURL = [NSURL URLWithString:[baseUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        _sharedClient = [[MFCAPIClient alloc] initWithBaseURL:baseURL];
    });
    return _sharedClient;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        self.baseURL = url;
        self.defaultHeaders = [[NSMutableDictionary alloc] init];
        [self.defaultHeaders setValue:[MFCAPIClient extraUserAgent] forKey:@"User-Agent"];
    }
    return self;
}

- (void)setDefaultHeader:(NSString *)header withValue:(NSString *) value
{
    [self.defaultHeaders setValue:value forKey:header];
}

- (void)sendRequestToMisfitRelativePath:(NSString *)relativePath
                             httpMethod:(NSString *)httpMethod
                             parameters:(NSDictionary *)parameters
                                success:(MFCAPIClientSuccess)success
                                failure:(MFCAPIClientFailure)failure
{
    NSURL *url = [NSURL URLWithString:relativePath relativeToURL:self.baseURL];
    NSLog(@"Misfit Cloud API URL: %@, %@",url, self.defaultHeaders);
    
    FSNRequestMethod theMethod = FSNRequestMethodGET;
    if ([[httpMethod lowercaseString] isEqualToString:@"post"]) {
        theMethod = FSNRequestMethodPOST;
    }
    FSNConnection *connection =
    [FSNConnection withUrl:url
                    method:theMethod
                   headers:self.defaultHeaders
                parameters:parameters
                parseBlock:^id(FSNConnection *c, NSError **error) {
                    if ((!c.responseData) || ([c.responseData length] == 0)) {
                        return @{};
                    }
                    return [c.responseData dictionaryFromJSONWithError:error];
                }
           completionBlock:^(FSNConnection *c) {
               NSLog(@"complete: %@\n  error: %@\n  parseResult: %@\n", c, c.error, c.parseResult);
               if(c.error)
               {
                   NSLog(@"error: %@",c.error);
                   if(c.httpResponse.statusCode==403){
                       failure([MFCError businessErrorNotAuthorized]);
                   }else{
                       failure([MFCError networkErrorFromError:c.error]);
                   }
               }
               else
               {
                   NSDictionary *response = (NSDictionary*)c.parseResult;
                   [self handleCommonMisfitResponseObject:response
                                                operation:c
                                                  success:success
                                                  failure:failure];
               }
           }
             progressBlock:^(FSNConnection *c) {
                 NSLog(@"progress: %@: %.2f/%.2f", c, c.uploadProgress, c.downloadProgress);
             }];
    
    [connection start];
}

- (void)handleCommonMisfitResponseObject:(NSDictionary * )responseObject
                               operation:(FSNConnection *)operation
                                 success:(MFCAPIClientSuccess)success
                                 failure:(MFCAPIClientFailure)failure
{
    NSInteger httpCode = operation.response.statusCode;
    
    // No network
    if (httpCode == 0)
    {
        MFCError *networkError = [[MFCError alloc] init];
        networkError.httpErrorCode = httpCode;
        networkError.isBusinessError = NO;
        networkError.localizedTitle = MFCLocalizedString(@"Network error", nil);
        networkError.localizedMessage = MFCLocalizedString(@"Sorry, please check your connection and try again", nil);
        if (failure)
        {
            failure(networkError);
        }
        return;
    }
    
    // HTTP 5xx: something wrong with server
    if (httpCode >= 500)
    {
        if (failure)
        {
            failure([MFCError networkErrorGeneral]);
        }
        return;
    }
    // HTTP 4xx: authentication error
    if (httpCode >= 400)
    {
        if (failure)
        {
            failure([MFCError businessErrorNotAuthorized]);
        }
        return;
    }
    
    NSDictionary *metaDict = [responseObject objectForKey:@"meta"];
    
    // HTTP code is normal, but no metadata
    if (metaDict.count == 0)
    {
        if (failure)
        {
            failure([MFCError networkErrorWrongResponseFromServer]);
        }
        return;
    }
    
    NSNumber *metaCode = [metaDict objectForKey:@"code"];
    
    BOOL isOK = (httpCode == 200
                 && metaCode
                 && ([metaCode integerValue] == 1000        // ok
                     || [metaCode integerValue] == 1001     // ok
                     || [metaCode integerValue] == 1104));  // ok
    if ((isOK))
    {
        if (success)
        {
            success(responseObject);
        }
        return;
    }
    
    if (failure)
    {
        failure([MFCError networkErrorFromMetaDict:metaDict]);
    }
}

- (NSString * )generateCallId
{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
    NSString *result = (__bridge NSString *)(uuidString);
    CFRelease(uuidString);
    CFRelease(uuid);
    return result;
}

+ (NSString *)extraUserAgent
{
    static NSString * userAgent;
    if (userAgent == nil)
    {
        userAgent = [NSString stringWithFormat:@" ## misfit3rdparty;%@;%@;iOS",
                     [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"],
                     @"CloudAPISDK"];
    }
   
    return userAgent;
}

- (void)cancelAllRequests
{
    NSLog(@"cancelAllConnections");
    [FSNConnection cancelAllConnections];
}

@end
