//
//  SecondViewController.m
//  MisfitCloudAPIWrapperDemo_iOS
//
//  Created by ASeign on 8/11/15.
//  Copyright (c) 2015 Misfit. All rights reserved.
//

#import "SecondViewController.h"
#import <MisfitCloudAPI/MisfitCloudAPI.h>

@interface SecondViewController ()
@property (strong, nonatomic) IBOutlet UITextView *tvMsg;

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)getData:(UIButton *)sender {
    if([MFCSession sharedInstance].isConnected){
        NSString* action = sender.currentTitle;
        if([action isEqualToString:@"Profile"]){
            [[MFCSession sharedInstance] getProfileWithCompletion:^(NSDictionary *data, MFCError *error) {
                if(error){
                    return [self appendMessage:error.localizedMessage];
                }
                [self appendMessage:[self getJSONStringFromDict:data]];
            }];
        }else if([action isEqualToString:@"Statistics"]){
            [[MFCSession sharedInstance] getProfileStatisticsWithCompletion:^(NSDictionary *data, MFCError *error) {
                if(error){
                    return [self appendMessage:error.localizedMessage];
                }
                [self appendMessage:[self getJSONStringFromDict:data]];
            }];
        }else if([action isEqualToString:@"Settings"]){
            [[MFCSession sharedInstance] getSettingWithCompletion:^(NSDictionary *data, MFCError *error) {
                if(error){
                    return [self appendMessage:error.localizedMessage];
                }
                [self appendMessage:[self getJSONStringFromDict:data]];
            }];
        }else if([action isEqualToString:@"Activity"]){
            [[MFCSession sharedInstance] getActivityDetailWithCompletionByDate:[NSDate date] completion:^(NSDictionary *data, MFCError *error) {
                if(error){
                    return [self appendMessage:error.localizedMessage];
                }
                [self appendMessage:[self getJSONStringFromDict:data]];
            }];
        }else if([action isEqualToString:@"Activity Summary"]){
            [[MFCSession sharedInstance] getActivitySummaryWithCompletionByDate:[NSDate date] range:MFCQuerySummaryRangeWeek completion:^(NSDictionary *data, MFCError *error) {
                if(error){
                    return [self appendMessage:error.localizedMessage];
                }
                [self appendMessage:[self getJSONStringFromDict:data]];
            }];
        }else if([action isEqualToString:@"Sleep"]){
            [[MFCSession sharedInstance] getSleepDetailWithCompletionByDate:[NSDate date] completion:^(NSDictionary *data, MFCError *error) {
                if(error){
                    return [self appendMessage:error.localizedMessage];
                }
                [self appendMessage:[self getJSONStringFromDict:data]];
            }];
        }else if([action isEqualToString:@"Sleep Summary"]){
            [[MFCSession sharedInstance] getSleepSummaryWithCompletionByDate:[NSDate date] range:MFCQuerySummaryRangeWeek completion:^(NSDictionary *data, MFCError *error) {
                if(error){
                    return [self appendMessage:error.localizedMessage];
                }
                [self appendMessage:[self getJSONStringFromDict:data]];
            }];
        }else if([action isEqualToString:@"Weight Summary"]){
            [[MFCSession sharedInstance] getWeightSummaryWithCompletionByDate:[NSDate date]  range:MFCQuerySummaryRangeWeek completion:^(NSDictionary *data, MFCError *error) {
                if(error){
                    return [self appendMessage:error.localizedMessage];
                }
                [self appendMessage:[self getJSONStringFromDict:data]];
            }];
        }
    }
}

- (NSString*)getJSONStringFromDict:(NSDictionary*)dict{
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&err];
    NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return myString;
}
- (void)appendMessage:(NSString*)theMsg {
    if ([NSThread isMainThread] == NO)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* newString = [NSString stringWithFormat:@"%@ --- %@\n\n %@",[NSDate date],theMsg,self.tvMsg.text];
            [self.tvMsg setText:newString];
        });
        return;
    }
    NSString* newString = [NSString stringWithFormat:@"%@ --- %@\n\n %@",[NSDate date],theMsg,self.tvMsg.text];
    [self.tvMsg setText:newString];
}

@end
