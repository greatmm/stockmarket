//
//  FMStockRemindModel.h
//  FMMarket
//
//  Created by dangfm on 15/12/2.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMStockRemindModel : NSObject

@property (nonatomic,retain) NSString *userId;
@property (nonatomic,retain) NSString *code;
@property (nonatomic,retain) NSString *upToPrice;
@property (nonatomic,retain) NSString *downToPrice;
@property (nonatomic,retain) NSString *upRateToValue;
@property (nonatomic,retain) NSString *downRateToValue;

-(instancetype)initWithDic:(NSDictionary*)dic;

@end
