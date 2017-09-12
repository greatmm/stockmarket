//
//  MKUserDefault.m
//  FMStockChart
//
//  Created by GKK on 2017/9/12.
//  Copyright © 2017年 dangfm. All rights reserved.
//

#import "MKUserDefault.h"
#import "FMHeader.h"

@implementation MKUserDefault
+(void)setSeting:(NSString *)key Value:(NSString*)value{
    if ([value isEqual:[NSNull null]] || !value) {
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:key];
    [defaults synchronize];
    defaults = nil;
}

+(NSString *)getSeting:(NSString*)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *value=[defaults objectForKey:key];
    defaults = nil;
    return value;
}

+(NSString *)userId{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *v = [ud valueForKey:fmUserIdKey];
    v = [ud valueForKey:v];
    return v;
}
+(BOOL)isVIP{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *v = [ud valueForKey:fmUserIsPayKey];
    BOOL vv = [[ud valueForKey:v] boolValue];
    return vv;
}

//  设置默认值
+(void)setStockIndexDefaultValue{
    // 简单均线
    if ([[self getSeting:fmFMUserDefault_SMA_N1] isEqualToString:@""] || ![self getSeting:fmFMUserDefault_SMA_N1]) {
        [self setSeting:fmFMUserDefault_SMA_N1 Value:@"5"];
    }
    if ([[self getSeting:fmFMUserDefault_SMA_N2] isEqualToString:@""] || ![self getSeting:fmFMUserDefault_SMA_N2]) {
        [self setSeting:fmFMUserDefault_SMA_N2 Value:@"10"];
    }
    if ([[self getSeting:fmFMUserDefault_SMA_N3] isEqualToString:@""] || ![self getSeting:fmFMUserDefault_SMA_N3]) {
        [self setSeting:fmFMUserDefault_SMA_N3 Value:@"20"];
    }
    // BOLL布林轨道
    if ([[self getSeting:fmFMUserDefault_BOLL_N] isEqualToString:@""] || ![self getSeting:fmFMUserDefault_BOLL_N]) {
        [self setSeting:fmFMUserDefault_BOLL_N Value:@"20"];
    }
    if ([[self getSeting:fmFMUserDefault_BOLL_K] isEqualToString:@""] || ![self getSeting:fmFMUserDefault_BOLL_K]) {
        [self setSeting:fmFMUserDefault_BOLL_K Value:@"2"];
    }
    // EMA(指数平均指标)
    if ([[self getSeting:fmFMUserDefault_EMA_N] isEqualToString:@""] || ![self getSeting:fmFMUserDefault_EMA_N]) {
        [self setSeting:fmFMUserDefault_EMA_N Value:@"20"];
    }
    // MACD 指数平滑异同平均线
    if ([[self getSeting:fmFMUserDefault_MACD_N1] isEqualToString:@""] || ![self getSeting:fmFMUserDefault_MACD_N1]) {
        [self setSeting:fmFMUserDefault_MACD_N1 Value:@"12"];
    }
    if ([[self getSeting:fmFMUserDefault_MACD_N2] isEqualToString:@""] || ![self getSeting:fmFMUserDefault_MACD_N2]) {
        [self setSeting:fmFMUserDefault_MACD_N2 Value:@"26"];
    }
    if ([[self getSeting:fmFMUserDefault_MACD_P] isEqualToString:@""] || ![self getSeting:fmFMUserDefault_MACD_P]) {
        [self setSeting:fmFMUserDefault_MACD_P Value:@"9"];
    }
    
    // KDJ 随机指标
    if ([[self getSeting:fmFMUserDefault_KDJ_N] isEqualToString:@""] || ![self getSeting:fmFMUserDefault_KDJ_N]) {
        [self setSeting:fmFMUserDefault_KDJ_N Value:@"9"];
    }
    // RSI 相对强弱指标
    if ([[self getSeting:fmFMUserDefault_RSI_N1] isEqualToString:@""] || ![self getSeting:fmFMUserDefault_RSI_N1]) {
        [self setSeting:fmFMUserDefault_RSI_N1 Value:@"6"];
    }
    if ([[self getSeting:fmFMUserDefault_RSI_N2] isEqualToString:@""] || ![self getSeting:fmFMUserDefault_RSI_N2]) {
        [self setSeting:fmFMUserDefault_RSI_N2 Value:@"12"];
    }
    if ([[self getSeting:fmFMUserDefault_RSI_N3] isEqualToString:@""] || ![self getSeting:fmFMUserDefault_RSI_N3]) {
        [self setSeting:fmFMUserDefault_RSI_N3 Value:@"24"];
    }
    // VOL 量能
    if ([[self getSeting:fmFMUserDefault_VOL_N1] isEqualToString:@""] || ![self getSeting:fmFMUserDefault_VOL_N1]) {
        [self setSeting:fmFMUserDefault_VOL_N1 Value:@"5"];
    }
    if ([[self getSeting:fmFMUserDefault_VOL_N2] isEqualToString:@""] || ![self getSeting:fmFMUserDefault_VOL_N2]) {
        [self setSeting:fmFMUserDefault_VOL_N2 Value:@"35"];
    }
    if ([[self getSeting:fmFMUserDefault_VOL_N3] isEqualToString:@""] || ![self getSeting:fmFMUserDefault_VOL_N3]) {
        [self setSeting:fmFMUserDefault_VOL_N3 Value:@"135"];
    }
    // OBV
    if ([[self getSeting:fmFMUserDefault_OBV_N1] isEqualToString:@""] || ![self getSeting:fmFMUserDefault_OBV_N1]) {
        [self setSeting:fmFMUserDefault_OBV_N1 Value:@"30"];
    }
    // DMI
    if ([[self getSeting:fmFMUserDefault_DMI_N] isEqualToString:@""] || ![self getSeting:fmFMUserDefault_DMI_N]) {
        [self setSeting:fmFMUserDefault_DMI_N Value:@"14"];
    }
    if ([[self getSeting:fmFMUserDefault_DMI_M] isEqualToString:@""] || ![self getSeting:fmFMUserDefault_DMI_M]) {
        [self setSeting:fmFMUserDefault_DMI_M Value:@"6"];
    }
    // SAR
    if ([[self getSeting:fmFMUserDefault_SAR_N] isEqualToString:@""] || ![self getSeting:fmFMUserDefault_SAR_N]) {
        [self setSeting:fmFMUserDefault_SAR_N Value:@"4"];
    }
    if ([[self getSeting:fmFMUserDefault_SAR_S] isEqualToString:@""] || ![self getSeting:fmFMUserDefault_SAR_S]) {
        [self setSeting:fmFMUserDefault_SAR_S Value:@"2"];
    }
    if ([[self getSeting:fmFMUserDefault_SAR_M] isEqualToString:@""] || ![self getSeting:fmFMUserDefault_SAR_M]) {
        [self setSeting:fmFMUserDefault_SAR_M Value:@"20"];
    }
    
}

#pragma mark - SMA
+(float)getSMA_N1{
    float v = [[self getSeting:fmFMUserDefault_SMA_N1]floatValue];
    if (v<=0) {
        v = 5;
    }
    return v;
}
+(float)getSMA_N2{
    float v = [[self getSeting:fmFMUserDefault_SMA_N2]floatValue];
    if (v<=0) {
        v = 10;
    }
    return v;
}
+(float)getSMA_N3{
    float v = [[self getSeting:fmFMUserDefault_SMA_N3]floatValue];
    if (v<=0) {
        v = 20;
    }
    return v;
}
#pragma mark - EMA
+(float)getEMA_N1{
    float v = [[self getSeting:fmFMUserDefault_EMA_N]floatValue];
    if (v<=0) {
        v = 20;
    }
    return v;
}
#pragma mark - BOLL
+(float)getBOLL_N{
    float v = [[self getSeting:fmFMUserDefault_BOLL_N]floatValue];
    if (v<=0) {
        v = 20;
    }
    return v;
}
+(float)getBOLL_K{
    float v = [[self getSeting:fmFMUserDefault_BOLL_K]floatValue];
    if (v<=0) {
        v = 2;
    }
    return v;
}
#pragma mark - MACD
+(float)getMACD_N1{
    float v = [[self getSeting:fmFMUserDefault_MACD_N1]floatValue];
    if (v<=0) {
        v = 12;
    }
    return v;
}
+(float)getMACD_N2{
    float v = [[self getSeting:fmFMUserDefault_MACD_N2]floatValue];
    if (v<=0) {
        v = 26;
    }
    return v;
}
+(float)getMACD_P{
    float v = [[self getSeting:fmFMUserDefault_MACD_P]floatValue];
    if (v<=0) {
        v = 9;
    }
    return v;
}
#pragma mark - KDJ
+(float)getKDJ_N{
    float v = [[self getSeting:fmFMUserDefault_KDJ_N]floatValue];
    if (v<=0) {
        v = 9;
    }
    return v;
}
#pragma mark - RSI
+(float)getRSI_N1{
    float v = [[self getSeting:fmFMUserDefault_RSI_N1]floatValue];
    if (v<=0) {
        v = 6;
    }
    return v;
}
+(float)getRSI_N2{
    float v = [[self getSeting:fmFMUserDefault_RSI_N2]floatValue];
    if (v<=0) {
        v = 12;
    }
    return v;
}
+(float)getRSI_N3{
    float v = [[self getSeting:fmFMUserDefault_RSI_N3]floatValue];
    if (v<=0) {
        v = 24;
    }
    return v;
}
#pragma mark - VOL
+(float)getVOL_N1{
    float v = [[self getSeting:fmFMUserDefault_VOL_N1]floatValue];
    if (v<=0) {
        v = 5;
    }
    return v;
}
+(float)getVOL_N2{
    float v = [[self getSeting:fmFMUserDefault_VOL_N2]floatValue];
    if (v<=0) {
        v = 35;
    }
    return v;
}
+(float)getVOL_N3{
    float v = [[self getSeting:fmFMUserDefault_VOL_N3]floatValue];
    if (v<=0) {
        v = 135;
    }
    return v;
}
#pragma mark - OBV
+(float)getOBV_N1{
    float v = [[self getSeting:fmFMUserDefault_OBV_N1]floatValue];
    if (v<=0) {
        v = 30;
    }
    return v;
}

#pragma mark - DMI
+(float)getDMI_N{
    float v = [[self getSeting:fmFMUserDefault_DMI_N]floatValue];
    if (v<=0) {
        v = 14;
    }
    return v;
}
+(float)getDMI_M{
    float v = [[self getSeting:fmFMUserDefault_DMI_M]floatValue];
    if (v<=0) {
        v = 6;
    }
    return v;
}
#pragma mark - SAR
+(float)getSAR_S{
    float v = [[self getSeting:fmFMUserDefault_SAR_S]floatValue];
    if (v<=0) {
        v = 2;
    }
    return v;
}
+(float)getSAR_N{
    float v = [[self getSeting:fmFMUserDefault_SAR_N]floatValue];
    if (v<=0) {
        v = 4;
    }
    return v;
}
+(float)getSAR_M{
    float v = [[self getSeting:fmFMUserDefault_SAR_M]floatValue];
    if (v<=0) {
        v = 20;
    }
    return v;
}
@end
