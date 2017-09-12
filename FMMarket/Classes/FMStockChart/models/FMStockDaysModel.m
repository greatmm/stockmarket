//
//  FMStockDaysModel.m
//  FMStockChart
//
//  Created by dangfm on 15/8/21.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMStockDaysModel.h"
#import "FMCommon.h"
@implementation FMStockDaysModel

-(instancetype)initWithDic:(NSMutableDictionary *)dic{
    if (self==[super init]) {
        [FMCommon reflectDataFromOtherObject:dic WithTarget:self];
    }
    return self;
}


@end
