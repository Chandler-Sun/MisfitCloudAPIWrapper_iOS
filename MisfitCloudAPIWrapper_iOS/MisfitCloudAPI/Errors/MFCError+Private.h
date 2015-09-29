//
//  MFLError+Private.h
//  Quantum
//
//  Created by Guomin Li on 9/1/15.
//  Copyright (c) 2015 Misfit. All rights reserved.
//

#import "MFCError.h"

@interface MFCError (Private)

+ (instancetype)networkErrorFromError:(NSError *)error;
+ (instancetype)networkErrorFromMetaDict:(NSDictionary *)metaDict;
+ (instancetype)networkErrorWrongResponseFromServer;
+ (instancetype)networkErrorGeneral;
+ (instancetype)networkErrorContactTechSupport;
+ (instancetype)businessErrorUserCanceled;
+ (instancetype)businessErrorForbidden;
+ (instancetype)businessErrorNotAuthorized;

@end