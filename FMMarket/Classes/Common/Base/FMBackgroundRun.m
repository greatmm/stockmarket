//
//  FMBackgroundRun.m
//  FMMarket
//
//  Created by dangfm on 15/10/15.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMBackgroundRun.h"
#import "FMSelfStocksModel.h"

#define kFMBackgroundRunTime 60

@implementation FMBackgroundRun

+ (FMBackgroundRun *)instance {
    static FMBackgroundRun *sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedObject) {
            sharedObject = [[[self class] alloc] init];
        }
    });
    
    return sharedObject;
}

-(instancetype)init{
    if (self==[super init]) {
        _queue = [[NSOperationQueue alloc] init];
        _queue.maxConcurrentOperationCount = 1;
    }
    return self;
}

#pragma mark -
#pragma mark 自选股任务
// 每次启动下载最新的自选股
-(void)firstDownloadMySelfStocksWithBlock:(void(^)(BOOL issuccess))block{
    if ([[FMUserDefault getUserId]floatValue]<=0) {
        return;
    }
    WEAKSELF
    [http getSelfStocksWithAction:@"s" codes:nil Start:^{
    
    } failure:^{
        // 失败重新获取
        NSLog(@"下载自选超时，重新下载中");
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            sleep(5);
            [__weakSelf firstDownloadMySelfStocksWithBlock:block];
        });
    } success:^(NSDictionary*dic){
        NSArray *list = (NSArray*)[dic objectForKey:@"data"];
        if (list && ![list isEqual:[NSNull null]]) {
            NSLog(@"下载自选成功");
            // 删除用户自选
            [db delete:[FMSelfStocksModel class]
                 Where:[NSString stringWithFormat:@" userId='%@'",[FMUserDefault getUserId]]];
            // 重新添加
            int j = 0;
            for (NSDictionary*item in list) {
                FMSelfStocksModel *m = [[FMSelfStocksModel alloc] initWithDic:item];
                m.orderValue = [NSString stringWithFormat:@"%d",j];
                [db insert:m FinishBlock:^(bool issuccess){}];
                m = nil;
                j++;
            }
//            int j = 0;
//            for (int i=((int)list.count-1);i>=0;i--) {
//                FMSelfStocksModel *m = [[FMSelfStocksModel alloc] initWithDic:list[i]];
//                m.orderValue = [NSString stringWithFormat:@"%d",j];
//                [db insert:m FinishBlock:^(bool issuccess){}];
//                j ++;
//            }
            list = nil;
            // 回调
            if (block) {
                block(YES);
            }
        }
        
    }];
}

// 删除一个股票
-(void)deleteSingleOneSelfStockWithCode:(NSString*)code block:(void(^)(BOOL issuccess))block{
    if ([[FMUserDefault getUserId]floatValue]<=0) {
        return;
    }
    if (code) {
        WEAKSELF
        [http getSelfStocksWithAction:@"d" codes:code Start:^{
            
        } failure:^{
            // 失败重新获取
            NSLog(@"单个删除自选超时，重新下载中");
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                sleep(5);
                [__weakSelf deleteSingleOneSelfStockWithCode:code block:block];
            });
        } success:^(NSDictionary*dic){
            BOOL success = [[dic objectForKey:@"success"]boolValue];
            // 回调
            if (block) {
                block(YES);
            }
            if (success) {
                NSLog(@"单个删除成功");
            }else{
                NSLog(@"单个删除失败：%@",[dic objectForKey:@"msg"]);
                
            }
        }];
    }
}

// 添加一个股票
-(void)uploadAddSingleOneSelfStockWithCode:(NSString*)code block:(void(^)(BOOL issuccess))block{
    if ([[FMUserDefault getUserId]floatValue]<=0) {
        return;
    }
    if (code) {
        WEAKSELF
        [http getSelfStocksWithAction:@"a" codes:code Start:^{
            
        } failure:^{
            // 失败重新获取
            NSLog(@"单个添加自选超时，重新添加中");
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                sleep(5);
                [__weakSelf uploadAddSingleOneSelfStockWithCode:code block:block];
            });
        } success:^(NSDictionary*dic){
            BOOL success = [[dic objectForKey:@"success"]boolValue];
            // 回调
            if (block) {
                block(YES);
            }
            if (success) {
                NSLog(@"单个添加成功");
            }else{
                NSLog(@"单个添加失败：%@",[dic objectForKey:@"msg"]);
                
            }
        }];
    }
}

-(void)uploadMySelfStocksWithBlock:(void(^)(BOOL issuccess))block{
    if ([[FMUserDefault getUserId]floatValue]<=0) {
        return;
    }
    WEAKSELF
    // 查询
    NSString *where = [NSString stringWithFormat:@" userId='%@'",[FMUserDefault getUserId]];
    NSArray *rs = [db select:[FMSelfStocksModel class] Where:where Order:@" abs(orderValue) asc" Limit:nil];
    // 批量添加
    NSMutableArray *codes = [NSMutableArray new];
    for (FMSelfStocksModel *m in rs) {
        [codes addObject:m.code];
    }
    NSString *cs = [codes componentsJoinedByString:@","];
    // 发送请求
    [http getSelfStocksWithAction:@"u" codes:cs Start:^{
        
    } failure:^{
        // 失败重新获取
        NSLog(@"批量更新超时，重新更新");
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            sleep(5);
            [__weakSelf uploadMySelfStocksWithBlock:block];
        });
    } success:^(NSDictionary*dic){
        BOOL success = [[dic objectForKey:@"success"]boolValue];
        // 回调
        if (block) {
            block(YES);
        }
        if (success) {
            NSLog(@"批量更新成功");
        }else{
            NSLog(@"批量更新失败：%@",[dic objectForKey:@"msg"]);
            
        }
    }];
}

-(void)start{
    [_queue waitUntilAllOperationsAreFinished];
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        // 运行线程
        [self backgoundRun];
    }];
    [_queue addOperation:operation];
}

-(void)backgoundRun{
    NSString *openTime = [FMUserDefault getDapanDatas].lastTime;
    if (!openTime || [openTime isEqualToString:@""] || [openTime isEqual:[NSNull null]]) {
        openTime = @"0";
    }
    if ([openTime rangeOfString:@":"].location!=NSNotFound) {
        NSArray *temp = [openTime componentsSeparatedByString:@":"];
        openTime = [temp firstObject];
    }
    if ([openTime intValue]<9 || [openTime intValue]>=15 || [[FMUserDefault getUserId]floatValue]<=0) {
        // 9点之前和15点以后不工作
        NSLog(@"signal->...");
        sleep(kFMBackgroundRunTime);
        [self backgoundRun];
    }
    // 拿到自选数据
    if (_startIndex<=0) {
        NSArray *selfStocks = [db select:[FMSelfStocksModel class] Where:nil Order:nil Limit:nil];
        _startIndex = (int)selfStocks.count;
        _datas = selfStocks;
        selfStocks = nil;
        sleep(kFMBackgroundRunTime);
        [self backgoundRun];
        return;
    }
    
    if (_startIndex>0) {
        _startIndex --;
        FMSelfStocksModel *m = (FMSelfStocksModel*)[_datas objectAtIndex:_startIndex];
        NSLog(@"signal->%@",m.code);
        if (![m.code isEqualToString:@""]) {
            [http checkStockSignalWithCode:m.code start:^{
                
            } failure:^{
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    sleep(5);
                    [self backgoundRun];
                });
                
            } success:^(NSDictionary*dic){
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    BOOL success = [[dic objectForKey:@"success"] boolValue];
                    if (success) {
                        // 成功 表示运行成功
                        NSLog(@"signal->success");
                    }
                    // 不管成功与否都会运行下一个检测
                    sleep(5);
                    [self backgoundRun];
                });
                
            }];
        }
        
    }
}

@end
