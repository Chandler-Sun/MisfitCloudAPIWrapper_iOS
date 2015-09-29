//
//  MFAPIClient.h
//  MFResearchApp2
//
//  Created by Hai Phan on 2/13/15.
//  Copyright (c) 2015 MF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFCError.h"
#import "MFCError+Private.h"

typedef void (^MFCAPIClientSuccess)(id responseObject);
typedef void (^MFCAPIClientFailure)(MFCError * error);


@interface MFCAPIClient : NSObject

+ (MFCAPIClient *)sharedClient;

- (void)setDefaultHeader:(NSString *)header withValue:(NSString *) value;

- (void)sendRequestToMisfitRelativePath:(NSString *)relativePath
                             httpMethod:(NSString *)httpMethod
                             parameters:(NSDictionary *)parameters
                                success:(MFCAPIClientSuccess)success
                                failure:(MFCAPIClientFailure)failure;

+ (NSString *)extraUserAgent;

- (void)cancelAllRequests;

@end
