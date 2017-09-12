//
//  FMSelfStocksModel.m
//  FMMarket
//
//  Created by dangfm on 15/8/11.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMSelfStocksModel.h"

@implementation FMSelfStocksModel
-(instancetype)initWithDic:(NSDictionary *)dic{
    if (self==[super init]) {
        [fn reflectDataFromOtherObject:dic WithTarget:self];
    }
    return self;
}


-(NSString*)change{
    if ([_change doubleValue]==0) {
        _change = [NSString stringWithFormat:@"%.2f",[self.price floatValue] - [self.closePrice floatValue]];
        if ([self.price floatValue]<=0 || [self.closePrice floatValue]<=0) _change = @"0";
    }
    
    return _change;
}

-(NSString*)changeRate{
    if ([_changeRate doubleValue]==0) {
        NSString *change = [self change];
        CGFloat result = [change floatValue]/[self.closePrice floatValue] * 100;
        _changeRate = [NSString stringWithFormat:@"%.2f",result];
        if ([self.closePrice floatValue]<=0) {
            _changeRate = @"-100.0";
        }
    }
    
    return _changeRate;
}
@end
