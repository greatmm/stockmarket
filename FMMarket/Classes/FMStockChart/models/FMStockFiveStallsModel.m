//
//  FMStockFiveStallsModel.m
//  FMStockChart
//
//  Created by dangfm on 15/10/29.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMStockFiveStallsModel.h"
#import "FMCommon.h"
@implementation FMStockFiveStallsModel
-(instancetype)initWithDic:(NSDictionary *)dic{
    if (self==[super init]) {
        [FMCommon reflectDataFromOtherObject:dic WithTarget:self];
    }
    return self;
}
@end
