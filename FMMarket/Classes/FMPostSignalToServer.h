//
//  FMPostSignalToServer.h
//  FMMarket
//
//  Created by dangfm on 15/9/20.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMPostSignalToServer : NSObject
@property (nonatomic,retain) NSMutableArray *datas;
/**
 *  初始化
 *
 *  @return FMPostSignalToServer
 */
+(instancetype)shareManager;
/**
 *  开始发送数据
 *
 *  @param prices 周期模型
 */
-(void)postStartWithPrices:(NSArray*)prices;

@end

@interface FMSignalModel : NSObject

@property (nonatomic,retain) NSString *code;
@property (nonatomic,retain) NSString *bsDate;
@property (nonatomic,assign) NSInteger type;
@property (nonatomic,assign) NSInteger nextDayStatus;

-(instancetype)initWithDic:(NSDictionary *)dic;

@end