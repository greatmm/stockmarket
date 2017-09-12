//
//  FMStockFiveStallsModel.h
//  FMStockChart
//
//  Created by dangfm on 15/10/29.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMStockFiveStallsModel : NSObject

@property (nonatomic,retain) NSString *code;
@property (nonatomic,retain) NSString *buy_1;
@property (nonatomic,retain) NSString *buy_2;
@property (nonatomic,retain) NSString *buy_3;
@property (nonatomic,retain) NSString *buy_4;
@property (nonatomic,retain) NSString *buy_5;
@property (nonatomic,retain) NSString *buy_1_s;
@property (nonatomic,retain) NSString *buy_2_s;
@property (nonatomic,retain) NSString *buy_3_s;
@property (nonatomic,retain) NSString *buy_4_s;
@property (nonatomic,retain) NSString *buy_5_s;
@property (nonatomic,retain) NSString *sell_1;
@property (nonatomic,retain) NSString *sell_2;
@property (nonatomic,retain) NSString *sell_3;
@property (nonatomic,retain) NSString *sell_4;
@property (nonatomic,retain) NSString *sell_5;
@property (nonatomic,retain) NSString *sell_1_s;
@property (nonatomic,retain) NSString *sell_2_s;
@property (nonatomic,retain) NSString *sell_3_s;
@property (nonatomic,retain) NSString *sell_4_s;
@property (nonatomic,retain) NSString *sell_5_s;
@property (nonatomic,retain) NSString *price;
@property (nonatomic,retain) NSString *closePrice;

-(instancetype)initWithDic:(NSDictionary *)dic;
@end
