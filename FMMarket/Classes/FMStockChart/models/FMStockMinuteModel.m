//
//  FMStockMinuteModel.m
//  FMStockChart
//
//  Created by dangfm on 15/8/29.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMStockMinuteModel.h"
#import "FMCommon.h"
@implementation FMStockMinuteModel

-(instancetype)initWithDic:(NSMutableDictionary *)dic{
    if (self==[super init]) {
        [FMCommon reflectDataFromOtherObject:dic WithTarget:self];
        [self changeRate];
        //[self averagePrice];
    }
    return self;
}

-(NSString*)changeRate{
    NSString *changeRate = @"0";
    float yestoday = [self.yestodayClosePrice floatValue];
    float price = [self.price floatValue];
    if (yestoday>0 && price>0 && price!=yestoday) {
        changeRate = [NSString stringWithFormat:@"%.2f",(price-yestoday)/yestoday * 100];
    }
    self.changeRate = changeRate;
    return changeRate;
}

//-(NSString*)averagePrice{
//    NSString *averagePrice = @"0";
//    float volumnPrice = [self.volumnPrice floatValue];
//    float volumn = [self.volumn floatValue];
//    if (volumn>0 && volumnPrice>0 && volumn!=volumnPrice) {
//        averagePrice = [NSString stringWithFormat:@"%.2f",volumnPrice/volumn];
//    }
//    self.averagePrice = averagePrice;
//    return averagePrice;
//}

@end
