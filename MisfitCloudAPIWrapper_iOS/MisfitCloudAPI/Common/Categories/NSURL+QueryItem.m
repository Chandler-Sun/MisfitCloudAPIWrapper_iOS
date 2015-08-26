//
//  NSURL+QueryItem.m
//  MFLButtonSDK
//
//  Created by ASeign on 7/31/15.
//  Copyright (c) 2015 Misfit. All rights reserved.
//

#import "NSURL+QueryItem.h"

@implementation NSURL (QueryItem)

- (NSDictionary*)queryItems {
    NSString * query = self.query;
    if([query length]==0) return nil;
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    for(NSString* parameter in [query componentsSeparatedByString:@"&"]) {
        NSRange range = [parameter rangeOfString:@"="];
        if(range.location!=NSNotFound)
            [parameters setObject:[[parameter substringFromIndex:range.location+range.length] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:[[parameter substringToIndex:range.location] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        else [parameters setObject:[[NSString alloc] init] forKey:[parameter stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    return [parameters copy];
}

- (NSDictionary*)fragmentItems {
    NSString * query = self.fragment;
    if([query length]==0) return nil;
    NSMutableDictionary* parameters = [NSMutableDictionary dictionary];
    for(NSString* parameter in [query componentsSeparatedByString:@"&"]) {
        NSRange range = [parameter rangeOfString:@"="];
        if(range.location!=NSNotFound)
            [parameters setObject:[[parameter substringFromIndex:range.location+range.length] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:[[parameter substringToIndex:range.location] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        else [parameters setObject:[[NSString alloc] init] forKey:[parameter stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    return [parameters copy];
}

@end
