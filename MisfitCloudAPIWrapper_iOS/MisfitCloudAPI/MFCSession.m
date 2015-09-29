//
//  MFLSession.m
//  Quantum
//
//  Created by ASeign on 8/20/15.
//  Copyright (c) 2015 Misfit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFCSession.h"
#import "NSString+MD5.h"
#import "NSURL+QueryItem.h"
#import "MFCAPIClient.h"
#import "MFCError.h"
#import "MFCError+Private.h"

#if DEBUG || STAGING
static NSString * const kMisfitAppUrlScheme = @"shine-internal://";
#else
static NSString * const kMisfitAppUrlScheme = @"shine://";
#endif

static NSString * const kMisfitCloudAPIToken = @"__misfit_cloud_api_token";

static NSString * const kMisfitAppID = @"__misfit_cloud_app_id";

static NSString * const kMisfitAppSecret = @"__misfit_cloud_app_secret";


@interface MFCSession ()

@property (nonatomic, copy) NSString* appId;

@property (nonatomic, copy) NSString* appSecret;

@property (nonatomic, copy) NSString* token;

@property (nonatomic, readwrite) BOOL isConnected;

@property (nonatomic, strong) MFCCompletion connectCompletion;

@end

@implementation MFCSession

+ (MFCSession *) sharedInstance
{
    static MFCSession *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[MFCSession alloc] init];
        _sharedInstance.appId = [[NSUserDefaults standardUserDefaults] valueForKey:kMisfitAppID];
        _sharedInstance.appSecret = [[NSUserDefaults standardUserDefaults] valueForKey:kMisfitAppSecret];
        _sharedInstance.token = [[NSUserDefaults standardUserDefaults] valueForKey:kMisfitCloudAPIToken];
        if (_sharedInstance.token) {
            _sharedInstance.isConnected = YES;
            [[MFCAPIClient sharedClient] setDefaultHeader:@"Authorization"
                                                withValue:[NSString stringWithFormat:@"Bearer %@", _sharedInstance.token]];
            [[MFCAPIClient sharedClient] setDefaultHeader:@"Content-Type"
                                                withValue:@"application/json"];
        }
    });
    return _sharedInstance;
}


-(void) connectWithAppId:(NSString *) appId
               appSecret:(NSString *) appSecret
            responseType:(NSString *) responseType
              completion:(MFCCompletion) completion
{
    BOOL canOpenApp = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:kMisfitAppUrlScheme]];
    if(canOpenApp){
        
        self.appId = appId;
        self.appSecret = appSecret;
        self.connectCompletion = completion;
        
        //get hash of app secret. not used yet
        //NSString * appSecretMD5 = [appSecret MD5String];
        NSString * redirectURL = [NSString stringWithFormat:@"%@authorize?response_type=token&app_id=%@&secret_hash=%@",
                                  kMisfitAppUrlScheme,
                                  self.appId,
                                  self.appId];//for compatibility
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:redirectURL]];


    }else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/shine/id564157241"]];
    }
}

- (void) disconnectWithCompletion:(MFCCompletion) completion
{
    if(self.appId){
        [[MFCAPIClient sharedClient] sendRequestToMisfitRelativePath:[NSString stringWithFormat:@"/oauth/revoke/%@",self.appId]
                                                          httpMethod:@"POST"
                                                          parameters:@{}
                                                             success:^(id responseObject) {
                                                                
                                                                 [self reset];
                                                                 
                                                                 completion(responseObject,nil);
                                                             } failure:^(MFCError * error) {
                                                                 
                                                                 [self reset];
                                                                 completion(nil,error);
                                                             }];
    }
}

- (void) reset
{
    self.isConnected = NO;
    self.appId = nil;
    self.appSecret = nil;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMisfitAppID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMisfitAppSecret];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMisfitCloudAPIToken];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL) handleOpenURL:(NSURL *) url
{
    NSDictionary * params = [url queryItems];
    //URL: mfc-misfittest://authorize#access_token=[token]
    //OR: mfc-misfittest://authorize?error=cancel
    
    NSString * errorCode = [params objectForKey:@"error"];   
    
    if((errorCode) && (![errorCode isEqualToString:@""])){
        if (self.connectCompletion) {
            if([errorCode isEqualToString:@"cancel"]){
                self.connectCompletion(nil, [MFCError businessErrorUserCanceled]);
            }else{
                self.connectCompletion(nil, [MFCError businessErrorForbidden]);
            }
        }
        return NO;
    }
    NSDictionary * fragParams = [url fragmentItems];
    NSString * token = [fragParams objectForKey:@"access_token"];

    self.token = token;
    self.isConnected = YES;
    
    [[NSUserDefaults standardUserDefaults] setValue:self.appId forKey:kMisfitAppID];
    [[NSUserDefaults standardUserDefaults] setValue:self.appSecret forKey:kMisfitAppSecret];
    [[NSUserDefaults standardUserDefaults] setObject:self.token forKey:kMisfitCloudAPIToken];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[MFCAPIClient sharedClient] setDefaultHeader:@"Authorization"
                                        withValue:[NSString stringWithFormat:@"Bearer %@", token]];
    
    [self handleDidBecomeActive];
    
    if (self.connectCompletion) {
        self.connectCompletion(fragParams, nil);
    }
    
    [self finishLogin];
    
    return YES;
}

- (BOOL) canHandleOpenUrl:(NSURL *) url
{
    NSString * redirectBackFromMisfitAppSchema = [NSString stringWithFormat:@"mfc-%@", self.appId];
    return [url.scheme isEqualToString:redirectBackFromMisfitAppSchema];
}

- (void)handleDidBecomeActive
{
    if (self.isConnected) {
        //maintain the http request queue?
    }
}

- (BOOL) isMisfitAppInstalled
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:kMisfitAppUrlScheme]];
}

- (void) finishLogin
{
    self.connectCompletion = nil;
}

- (void) getProfileWithCompletion:(MFCCompletion) completion
{
    [[MFCAPIClient sharedClient] sendRequestToMisfitRelativePath:@"user/me/profile"
                                                      httpMethod:@"GET"
                                                      parameters:@{}
                                                         success:^(id responseObject) {
                                                             completion(responseObject,nil);
                                                         } failure:^(MFCError * error) {
                                                             completion(nil,error);
                                                         }];
}
- (void) getProfileStatisticsWithCompletion:(MFCCompletion) completion
{
    [[MFCAPIClient sharedClient] sendRequestToMisfitRelativePath:@"user/me/profile/statistics"
                                                      httpMethod:@"GET"
                                                      parameters:@{}
                                                         success:^(id responseObject) {
                                                             completion(responseObject,nil);
                                                         } failure:^(MFCError * error) {
                                                             completion(nil,error);
                                                         }];
}
- (void) getSettingWithCompletion:(MFCCompletion) completion
{
    [[MFCAPIClient sharedClient] sendRequestToMisfitRelativePath:@"user/me/profile/settings"
                                                      httpMethod:@"GET"
                                                      parameters:@{}
                                                         success:^(id responseObject) {
                                                             completion(responseObject,nil);
                                                         } failure:^(MFCError * error) {
                                                             completion(nil,error);
                                                         }];
}
- (void) getDeviceWithCompletion:(MFCCompletion) completion
{
    [[MFCAPIClient sharedClient] sendRequestToMisfitRelativePath:@"user/me/device/list"
                                                      httpMethod:@"GET"
                                                      parameters:@{}
                                                         success:^(id responseObject) {
                                                             completion(responseObject,nil);
                                                         } failure:^(MFCError * error) {
                                                             completion(nil,error);
                                                         }];
}

- (void) getActivitySummaryWithCompletionByDate:(NSDate *)date range:(MFCQuerySummaryRange)range completion:(MFCCompletion) completion
{
    [[MFCAPIClient sharedClient] sendRequestToMisfitRelativePath:@"user/me/activity/summary"
                                                      httpMethod:@"GET"
                                                      parameters:@{@"date":[self getDateStr:date],
                                                                   @"period":[self getRangeStringByType:range]}
                                                         success:^(id responseObject) {
                                                             completion(responseObject,nil);
                                                         } failure:^(MFCError * error) {
                                                             completion(nil,error);
                                                         }];
}

- (void) getActivityGraphWithCompletionByDate:(NSDate *)date completion:(MFCCompletion) completion
{
    [[MFCAPIClient sharedClient] sendRequestToMisfitRelativePath:@"user/me/activity/graph"
                                                      httpMethod:@"GET"
                                                      parameters:@{@"date":[self getDateStr:date]}
                                                         success:^(id responseObject) {
                                                             completion(responseObject,nil);
                                                         } failure:^(MFCError * error) {
                                                             completion(nil,error);
                                                         }];
}

- (void) getActivityDetailWithCompletionByDate:(NSDate *)date completion:(MFCCompletion) completion
{
    [[MFCAPIClient sharedClient] sendRequestToMisfitRelativePath:@"user/me/activity"
                                                      httpMethod:@"GET"
                                                      parameters:@{@"date":[self getDateStr:date]}
                                                         success:^(id responseObject) {
                                                             completion(responseObject,nil);
                                                         } failure:^(MFCError * error) {
                                                             completion(nil,error);
                                                         }];
}
- (void) getSleepSummaryWithCompletionByDate:(NSDate *)date range:(MFCQuerySummaryRange)range completion:(MFCCompletion) completion
{
    [[MFCAPIClient sharedClient] sendRequestToMisfitRelativePath:@"user/me/sleep/summary"
                                                      httpMethod:@"GET"
                                                      parameters:@{@"date":[self getDateStr:date],
                                                                   @"period":[self getRangeStringByType:range]}
                                                         success:^(id responseObject) {
                                                             completion(responseObject,nil);
                                                         } failure:^(MFCError * error) {
                                                             completion(nil,error);
                                                         }];

}
- (void) getSleepDetailWithCompletionByDate:(NSDate *)date completion:(MFCCompletion) completion
{
    [[MFCAPIClient sharedClient] sendRequestToMisfitRelativePath:@"user/me/sleep"
                                                      httpMethod:@"GET"
                                                      parameters:@{@"date": [self getDateStr:date]}
                                                         success:^(id responseObject) {
                                                             completion(responseObject,nil);
                                                         } failure:^(MFCError * error) {
                                                             completion(nil,error);
                                                         }];
}
- (void) getWeightSummaryWithCompletionByDate:(NSDate *)date range:(MFCQuerySummaryRange)range completion:(MFCCompletion) completion
{
    [[MFCAPIClient sharedClient] sendRequestToMisfitRelativePath:@"user/me/weight/summary"
                                                      httpMethod:@"GET"
                                                      parameters:@{@"date":[self getDateStr:date],
                                                                   @"period":[self getRangeStringByType:range]}
                                                         success:^(id responseObject) {
                                                             completion(responseObject,nil);
                                                         } failure:^(MFCError * error) {
                                                             completion(nil,error);
                                                         }];

}

- (NSString*)getDateStr:(NSDate*)date
{
    NSDateFormatter* fmt = [[NSDateFormatter alloc] init];
    fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en"];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSString* dateString = [fmt stringFromDate:date];
    MFSLogInfo(@"%@", dateString);
    return dateString;
}
- (NSString*)getRangeStringByType:(MFCQuerySummaryRange)range
{
    switch (range) {
        case MFCQuerySummaryRangeWeek:
            return @"week";
        case MFCQuerySummaryRangeMonth:
            return @"month";
        default:
            return @"week";
    }
}



@end