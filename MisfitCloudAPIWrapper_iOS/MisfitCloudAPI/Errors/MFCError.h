//
//  MFLError.h
//  MFLButtonSDK
//
//  Created by ASeign on 7/30/15.
//  Copyright (c) 2015 Misfit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MFCError : NSError

// Internal
@property (assign, nonatomic) NSInteger httpErrorCode;
@property (assign, nonatomic) BOOL isBusinessError;
@property (assign, nonatomic) NSInteger businessErrorCode;

// Debug only. Don't use them to make decision
@property (strong, nonatomic) NSString * debugMessage;
@property (strong, nonatomic) NSError * internalError;

// To display
@property (strong, nonatomic) NSString * localizedTitle;
@property (strong, nonatomic) NSString * localizedMessage;

+ (instancetype)networkErrorFromError:(NSError *)error;
+ (instancetype)networkErrorFromMetaDict:(NSDictionary *)metaDict;
+ (instancetype)networkErrorWrongResponseFromServer;
+ (instancetype)networkErrorGeneral;
+ (instancetype)networkErrorContactTechSupport;
@end
