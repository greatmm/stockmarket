//
//  FMStockInfoModel.h
//  FMMarket
//
//  Created by dangfm on 15/8/18.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMStockInfoModel : NSObject

@property (nonatomic,retain) NSString *openPrice;            // 开盘价
@property (nonatomic,retain) NSString *closePrice;           // 昨收
@property (nonatomic,retain) NSString *volumn;               // 成交量
@property (nonatomic,retain) NSString *volumnPrice;          // 成交额
@property (nonatomic,retain) NSString *turnoverRate;         // 换手率
@property (nonatomic,retain) NSString *highPrice;            // 最高价
@property (nonatomic,retain) NSString *lowPrice;             // 最低价
@property (nonatomic,retain) NSString *circulationValue;     // 流通市值
@property (nonatomic,retain) NSString *totalValue;           // 总市值
@property (nonatomic,retain) NSString *peRatio;              // 市盈率
@property (nonatomic,retain) NSString *cityNetRate;          // 市净率
@property (nonatomic,retain) NSString *swing;                // 振幅
@property (nonatomic,retain) NSString *signal;               // 信号
@property (nonatomic,retain) NSString *lastDate;             // 最后更新日期
@property (nonatomic,retain) NSString *lastTime;             // 最后更新时间

-(instancetype)initWithDic:(NSDictionary*)dic;
@end
