//
//  FMStockRemindModel.m
//  FMMarket
//
//  Created by dangfm on 15/12/2.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMStockRemindModel.h"

@implementation FMStockRemindModel
-(instancetype)initWithDic:(NSDictionary *)dic{
    if (self==[super init]) {
        [fn reflectDataFromOtherObject:dic WithTarget:self];
    }
    return self;
}
@end
