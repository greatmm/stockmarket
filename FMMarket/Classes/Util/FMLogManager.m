//
//  FMLogManager.m
//  FMMarket
//
//  Created by dangfm on 15/8/7.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMLogManager.h"

@interface FMLogManager(){
    DDFileLogger *_fileLogger;
}

@end

@implementation FMLogManager

+ (instancetype)sharedManager
{
    static FMLogManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FMLogManager alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        [DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
        _fileLogger = [[DDFileLogger alloc] init];
        _fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
        _fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
        [DDLog addLogger:_fileLogger];
        // 打印日志文件目录
        //DDLogInfo(@"log path is %@", _fileLogger.logFileManager.logsDirectory);
        
    }
    return self;
}

- (void)start
{
    NSLog(@"App Started Log");
}

@end
