//
//  FMDBManager.h
//  FMMarket
//
//  Created by dangfm on 15/8/8.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
#import "FMSelfStocksModel.h"
#import "FMStocksModel.h"
#import "FMStockRemindModel.h"

#define kFMDBName @"FMMarketDatabase.db"

@interface FMDBManager : NSObject
+(instancetype)shareManager;
/**
 *  插入数据
 *
 *  @param model       模型
 *  @param finishBlock 插入完成回调
 */
-(void)insert:(id)model FinishBlock:(void (^)(bool issuccess))finishBlock;
/**
 *  更新数据库
 *
 *  @param model 模型
 *  @param where 条件
 *  @param finishBlock 更新完成回调
 *
 *  @return 是否成功
 */
-(void)update:(id)model Where:(NSString*)where FinishBlock:(void (^)(bool issuccess))finishBlock;
/**
 *  查询数据库
 *
 *  @param model 模型
 *  @param where 条件
 *  @param order 排序
 *  @param limit 限制行数
 *
 *  @return 模型数组
 */
-(NSArray*)select:(id)model Where:(NSString*)where Order:(NSString*)order Limit:(NSString*)limit;

/**
 *  删除
 *
 *  @param model 模型
 *  @param where 条件
 *
 *  @return 删除是否成功
 */
-(BOOL)delete:(id)model Where:(NSString*)where;

/**
 *  查询表总记录数
 *
 *  @param model 模型
 *
 *  @return 总数
 */
-(NSInteger)getCount:(id)model;
-(NSInteger)getCount:(id)model where:(NSString*)where;
-(NSInteger)getSum:(id)model Filed:(NSString*)filed where:(NSString*)where;
//  表是否存在
-(BOOL)isExit:(id)model;
//  删除表数据
-(void)clearTable:(id)model;
@end
