//
//  FMBackgroundRun.h
//  FMMarket
//
//  Created by dangfm on 15/10/15.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMBackgroundRun : NSObject
@property (nonatomic,retain) NSOperationQueue *queue;
@property (nonatomic,assign) int startIndex;
@property (nonatomic,retain) NSArray* datas;
+ (FMBackgroundRun *)instance;
-(void)start;

#pragma mark -
#pragma mark 自选股任务

// 每次启动下载最新的自选股
-(void)firstDownloadMySelfStocksWithBlock:(void(^)(BOOL issuccess))block;
// 批量上传更新自选
-(void)uploadMySelfStocksWithBlock:(void(^)(BOOL issuccess))block;
// 添加一个股票
-(void)uploadAddSingleOneSelfStockWithCode:(NSString*)code block:(void(^)(BOOL issuccess))block;
// 删除一个股票
-(void)deleteSingleOneSelfStockWithCode:(NSString*)code block:(void(^)(BOOL issuccess))block;
@end
