//
//  FMStockNewDataModel.h
//  FMStockChart
//
//  Created by dangfm on 15/9/15.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMStockNewDataModel : NSObject
@property (nonatomic,retain) NSString *name;            // 股票名称
@property (nonatomic,retain) NSString *code;            // 代码
@property (nonatomic,retain) NSString *type;            // 类型 sh sz hg us
@property (nonatomic,retain) NSString *price;           // 当前价
@property (nonatomic,retain) NSString *openPrice;       // 开盘
@property (nonatomic,retain) NSString *closePrice;      // 收盘
@property (nonatomic,retain) NSString *highPrice;       // 最高
@property (nonatomic,retain) NSString *lowPrice;        // 最低
@property (nonatomic,retain) NSString *buy_1;           // 买一
@property (nonatomic,retain) NSString *buy_2;
@property (nonatomic,retain) NSString *buy_3;
@property (nonatomic,retain) NSString *buy_4;
@property (nonatomic,retain) NSString *buy_5;
@property (nonatomic,retain) NSString *buy_1_s;         // 买一股数
@property (nonatomic,retain) NSString *buy_2_s;
@property (nonatomic,retain) NSString *buy_3_s;
@property (nonatomic,retain) NSString *buy_4_s;
@property (nonatomic,retain) NSString *buy_5_s;
@property (nonatomic,retain) NSString *sell_1;          // 卖一
@property (nonatomic,retain) NSString *sell_2;
@property (nonatomic,retain) NSString *sell_3;
@property (nonatomic,retain) NSString *sell_4;
@property (nonatomic,retain) NSString *sell_5;
@property (nonatomic,retain) NSString *sell_1_s;        // 卖一股数
@property (nonatomic,retain) NSString *sell_2_s;
@property (nonatomic,retain) NSString *sell_3_s;
@property (nonatomic,retain) NSString *sell_4_s;
@property (nonatomic,retain) NSString *sell_5_s;
@property (nonatomic,retain) NSString *volumn;          // 成交股数
@property (nonatomic,retain) NSString *volumnPrice;     // 成交金额
@property (nonatomic,retain) NSString *lastDate;        // 最后更新日期
@property (nonatomic,retain) NSString *lastTime;        // 对应的最后更新时间
@property (nonatomic,retain) NSString *isStop;          // 是否停牌
@property (nonatomic,retain) NSString *change;          // 涨跌额
@property (nonatomic,retain) NSString *changeRate;      // 涨跌幅
@property (nonatomic,retain) NSString *signal;          // 信号
@property (nonatomic,assign) NSString *orderValue;      // 排序 由低到高
@property (nonatomic,retain) NSString *timestamp;       // 时间戳

-(instancetype)initWithDic:(NSDictionary*)dic;
-(NSString*)change;
-(NSString*)changeRate;
@end
