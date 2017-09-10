//
//  FMPostSignalToServer.m
//  FMMarket
//
//  Created by dangfm on 15/9/20.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMPostSignalToServer.h"
#import <FMStockChart/FMStockChart.h>

@implementation FMSignalModel

-(instancetype)initWithDic:(NSDictionary *)dic{
    if (self==[super init]) {
        [fn reflectDataFromOtherObject:dic WithTarget:self];
    }
    return self;
}

@end


@implementation FMPostSignalToServer

+(instancetype)shareManager{
    static FMPostSignalToServer *instance = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        instance = [[FMPostSignalToServer alloc] init];
    });
    return instance;
}

-(instancetype)init{
    if (self==[super init]) {
        _datas = [NSMutableArray array];
    }
    return self;
}


-(void)postStartWithPrices:(NSArray*)prices{
    WEAKSELF
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    mainQueue.maxConcurrentOperationCount = 1;
    [mainQueue cancelAllOperations];
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [__weakSelf sendPost];
        });
    }];
    [mainQueue addOperation:operation];
    mainQueue = nil;
    operation = nil;
}



-(void)sendPost{
    NSString *tel = [FMUserDefault getSeting:kUserDefault_Mobile];
    if ([[tel class]isSubclassOfClass:[NSString class]]) {
        if (![tel isEqualToString:@""]) {
            WEAKSELF
            // 目前只是每次启动自动登录
            [http updateUserLoginWithTel:tel start:^{
                
            } failure:^{
                [fn sleepSeconds:10 finishBlock:^{
                    [__weakSelf sendPost];
                }];
            } success:^(NSDictionary*dic){
                NSLog(@"自动登录：%@",dic);
            }];
        }
        
    }
    
}
@end
