//
//  FMStockNewDataModel.m
//  FMStockChart
//
//  Created by dangfm on 15/9/15.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMStockNewDataModel.h"
#import "FMCommon.h"

@implementation FMStockNewDataModel

-(instancetype)initWithDic:(NSDictionary *)dic{
    if (self==[super init]) {
        [FMCommon reflectDataFromOtherObject:dic WithTarget:self];
    }
    return self;
}


-(NSString*)change{
    _change = [NSString stringWithFormat:@"%.2f",[self.price floatValue] - [self.closePrice floatValue]];
    if ([self.price floatValue]<=0) _change = @"0";
    return _change;
}

-(NSString*)changeRate{
    NSString *change = [self change];
    CGFloat result = [change floatValue]/[self.closePrice floatValue] * 100;
    _changeRate = [NSString stringWithFormat:@"%.2f",result];
    return _changeRate;
}

@end
