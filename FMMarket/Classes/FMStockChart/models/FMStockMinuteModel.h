//
//  FMStockMinuteModel.h
//  FMStockChart
//
//  Created by dangfm on 15/8/29.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMStockMinuteModel : NSObject

@property (nonatomic,retain) NSString *price;
@property (nonatomic,retain) NSString *datetime;
@property (nonatomic,retain) NSString *changeRate;
@property (nonatomic,retain) NSString *averagePrice;
@property (nonatomic,retain) NSString *volumn;
@property (nonatomic,retain) NSString *volumnPrice;
@property (nonatomic,retain) NSString *yestodayClosePrice;
@property (nonatomic,retain) NSString *color;
@property (nonatomic,retain) NSString *lastTime;
@property (nonatomic,assign) double upPower;
@property (nonatomic,assign) double downPower;
@property (nonatomic,assign) double powerRate;
-(instancetype)initWithDic:(NSMutableDictionary*)dic;
@end
