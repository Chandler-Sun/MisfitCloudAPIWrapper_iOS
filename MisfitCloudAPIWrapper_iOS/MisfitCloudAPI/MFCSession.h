//
//  MFLSession.h
//  Quantum
//
//  Created by Guomin Li on 7/20/15.
//  Copyright (c) 2015 Misfit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MFCError.h"

typedef void (^MFCCompletion) (NSDictionary * data, MFCError * error);

typedef enum {
    MFCQuerySummaryRangeWeek,
    MFCQuerySummaryRangeMonth,
} MFCQuerySummaryRange;

@interface MFCSession : NSObject

@property (nonatomic, readonly) BOOL isConnected;

@property (nonatomic, copy) NSString* token;

@property (nonatomic, copy) NSString* appId;

@property (nonatomic, copy) NSString* appSecret;


+ (MFCSession *) sharedInstance;

- (BOOL) handleOpenURL:(NSURL *) url;
- (BOOL) canHandleOpenUrl:(NSURL *) url;
- (void) handleDidBecomeActive;

- (void) connectWithAppId:(NSString *) appId appSecret:(NSString *) appSecret responseType:(NSString *) responseType completion:(MFCCompletion) completion;

- (void) disconnectWithCompletion:(MFCCompletion) completion;

- (BOOL) isMisfitAppInstalled;

- (void) getProfileWithCompletion:(MFCCompletion) completion;
- (void) getProfileStatisticsWithCompletion:(MFCCompletion) completion;
- (void) getSettingWithCompletion:(MFCCompletion) completion;
- (void) getDeviceWithCompletion:(MFCCompletion) completion;

- (void) getActivitySummaryWithCompletionByDate:(NSDate *)date range:(MFCQuerySummaryRange)range completion:(MFCCompletion) completion;
- (void) getActivityDetailWithCompletionByDate:(NSDate *)date completion:(MFCCompletion) completion;
- (void) getActivityGraphWithCompletionByDate:(NSDate *)date completion:(MFCCompletion) completion;

- (void) getSleepSummaryWithCompletionByDate:(NSDate *)date range:(MFCQuerySummaryRange)range completion:(MFCCompletion) completion;
- (void) getSleepDetailWithCompletionByDate:(NSDate *)date completion:(MFCCompletion) completion;
- (void) getWeightSummaryWithCompletionByDate:(NSDate *)date range:(MFCQuerySummaryRange)range completion:(MFCCompletion) completion;



@end