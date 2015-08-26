//
//  NSData+HexString.m
//  Misfit-BLE-iOS-SDK
//
//  Created by Minh Nguyen on 5/28/14.
//  Copyright (c) 2014 Misfit Wearables. All rights reserved.
//

#import "NSData+HexString.h"

@implementation NSData (HexString)

- (NSString *)hexadecimalString
{
    const uint8_t *dataBuffer = (const uint8_t *)[self bytes];
    
    if (!dataBuffer)
        return [NSString string];
    
    NSUInteger dataLength = [self length];
    NSMutableString *hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
    {
        [hexString appendString:[NSString stringWithFormat:@"%02x", dataBuffer[i]]];
    }
    
    return [NSString stringWithString:hexString];
}

@end
