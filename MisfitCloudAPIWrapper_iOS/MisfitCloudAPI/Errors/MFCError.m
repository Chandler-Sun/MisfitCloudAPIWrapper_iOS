//
//  MFLError.m
//  MFLButtonSDK
//
//  Created by ASeign on 7/30/15.
//  Copyright (c) 2015 Misfit. All rights reserved.
//

#import "MFCError.h"

@implementation MFCError

- (instancetype)init
{
    self = [super initWithDomain:@"NETWORK" code:0 userInfo:@{}];
    if (self) {
        self.httpErrorCode = 0;
        self.isBusinessError = NO;
        self.localizedTitle = MFCLocalizedString(@"Error", nil);
        self.localizedMessage = MFCLocalizedString(@"An unexpected error occurred. Please try again later.", nil);
    }
    return self;
}

+ (instancetype)networkErrorFromError:(NSError *)error
{
    MFCError *networkError = [[MFCError alloc] init];
    networkError.internalError = error;
    return networkError;
}

+ (instancetype)networkErrorWrongResponseFromServer
{
    MFCError *networkError = [[MFCError alloc] init];
    // TODO
    return networkError;
}

+ (instancetype)networkErrorFromMetaDict:(NSDictionary *)metaDict
{
    MFCError *networkError = [[MFCError alloc] init];
    networkError.isBusinessError = YES;
    networkError.businessErrorCode = [[metaDict objectForKey:@"code"] integerValue];
    networkError.debugMessage = [metaDict objectForKey:@"debug"];
    return networkError;
}

+ (instancetype)networkErrorContactTechSupport
{
    MFCError *networkError = [[MFCError alloc] init];
    networkError.localizedTitle = MFCLocalizedString(@"Error", nil);
    networkError.localizedMessage = MFCLocalizedString(@"An error occurred. Please try again or contact customer support if the problem persists.", nil);
    return networkError;
    
}
+ (instancetype)networkErrorGeneral
{
    MFCError *networkError = [[MFCError alloc] init];
    networkError.localizedTitle = MFCLocalizedString(@"Error", nil);
    networkError.localizedMessage = MFCLocalizedString(@"An unexpected error occurred. Please try again later.", nil);
    return networkError;
}
@end
