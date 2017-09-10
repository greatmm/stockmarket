//
//  FMLogManager.h
//  FMMarket
//
//  Created by dangfm on 15/8/7.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMLogManager : NSObject

+ (instancetype)sharedManager;

- (void)start;

@end
