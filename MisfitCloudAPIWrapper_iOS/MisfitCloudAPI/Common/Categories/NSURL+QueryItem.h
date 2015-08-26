//
//  NSURL+QueryItem.h
//  MFLButtonSDK
//
//  Created by ASeign on 7/31/15.
//  Copyright (c) 2015 Misfit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (QueryItem)

- (NSDictionary*)queryItems;
- (NSDictionary*)fragmentItems;
@end
