//
//  FirstViewController.m
//  MisfitCloudAPIWrapperDemo_iOS
//
//  Created by ASeign on 8/11/15.
//  Copyright (c) 2015 Misfit. All rights reserved.
//

#import "FirstViewController.h"
#import <MisfitCloudAPI/MisfitCloudAPI.h>

@interface FirstViewController ()

@property (strong, nonatomic) IBOutlet UIButton *btnConnectToMisfit;
@property (strong, nonatomic) IBOutlet UIButton *btnDisconnectFromMisfit;
@property (strong, nonatomic) IBOutlet UITextView *tvMessage;
@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.btnDisconnectFromMisfit.hidden = ![MFCSession sharedInstance].isConnected;
    self.btnConnectToMisfit.hidden = [MFCSession sharedInstance].isConnected;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onDisconnectTapped:(id)sender {
    [[MFCSession sharedInstance] disconnectWithCompletion:^(NSDictionary * data, MFCError* error){
        self.btnDisconnectFromMisfit.hidden = ![MFCSession sharedInstance].isConnected;
        self.btnConnectToMisfit.hidden = [MFCSession sharedInstance].isConnected;
        if(error){
            self.tvMessage.text = error.localizedMessage;
        }
    }];
}

- (IBAction)onConnectTapped:(id)sender {
    BOOL isConnected = [MFCSession sharedInstance].isConnected;
    if(!isConnected){
        [[MFCSession sharedInstance] connectWithAppId:@"test"
                                            appSecret:@"uLJkp51haavnHdxGI3xjpEFCx5VrDy2j"
                                         responseType:@"token"
                                           completion:^(NSDictionary * data, MFCError* error)
        {
            if (error)
            {
                self.tvMessage.text = error.localizedMessage;
                self.btnConnectToMisfit.titleLabel.text = error.description;
                return;
            }
            self.tvMessage.text = @"success";
            NSString * token = [data objectForKey:@"access_token"];
            // do whatever you want.
            self.btnConnectToMisfit.titleLabel.text = token;
            self.btnDisconnectFromMisfit.hidden = NO;
            self.btnConnectToMisfit.hidden = YES;
        }];
    }else{
        self.btnConnectToMisfit.titleLabel.text = @"Already connected";
    }
}
@end
