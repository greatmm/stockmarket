//
//  MKUserDefault.h
//  FMStockChart
//
//  Created by GKK on 2017/9/12.
//  Copyright © 2017年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>

#define fmFMUserDefault_SMA_N1 @"FMUserDefault_SMA_N1"
#define fmFMUserDefault_SMA_N2 @"FMUserDefault_SMA_N2"
#define fmFMUserDefault_SMA_N3 @"FMUserDefault_SMA_N3"
#define fmFMUserDefault_MACD_N1 @"FMUserDefault_MACD_N1"
#define fmFMUserDefault_MACD_N2 @"FMUserDefault_MACD_N2"
#define fmFMUserDefault_MACD_P @"FMUserDefault_MACD_P"
#define fmFMUserDefault_KDJ_N @"FMUserDefault_KDJ_N"
#define fmFMUserDefault_RSI_N1 @"FMUserDefault_RSI_N1"
#define fmFMUserDefault_RSI_N2 @"FMUserDefault_RSI_N2"
#define fmFMUserDefault_RSI_N3 @"FMUserDefault_RSI_N3"
#define fmFMUserDefault_BOLL_K @"FMUserDefault_BOLL_K"
#define fmFMUserDefault_BOLL_N @"FMUserDefault_BOLL_N"
#define fmFMUserDefault_EMA_N @"FMUserDefault_EMA_N"
#define fmFMUserDefault_VOL_N1 @"FMUserDefault_VOL_N1"
#define fmFMUserDefault_VOL_N2 @"FMUserDefault_VOL_N2"
#define fmFMUserDefault_VOL_N3 @"FMUserDefault_VOL_N3"
#define fmFMUserDefault_OBV_N1 @"FMUserDefault_OBV_N1"
#define fmFMUserDefault_DMI_N @"FMUserDefault_DMI_N"
#define fmFMUserDefault_DMI_M @"FMUserDefault_DMI_M"
#define fmFMUserDefault_SAR_N @"FMUserDefault_SAR_N"
#define fmFMUserDefault_SAR_S @"FMUserDefault_SAR_S"
#define fmFMUserDefault_SAR_M @"FMUserDefault_SAR_M"


@interface MKUserDefault : NSObject
#pragma mark -
#pragma mark UserDefaults Actioin
+(void)setSeting:(NSString *)key Value:(NSString*)value;
+(NSString *)getSeting:(NSString*)key;
+(NSString *)userId;
+(BOOL)isVIP;
//  设置指标变量默认值
+(void)setStockIndexDefaultValue;
#pragma mark - SMA
+(float)getSMA_N1;
+(float)getSMA_N2;
+(float)getSMA_N3;

#pragma mark - EMA
+(float)getEMA_N1;
#pragma mark - BOLL
+(float)getBOLL_N;
+(float)getBOLL_K;
#pragma mark - MACD
+(float)getMACD_N1;
+(float)getMACD_N2;
+(float)getMACD_P;
#pragma mark - KDJ
+(float)getKDJ_N;
#pragma mark -RSI
+(float)getRSI_N1;
+(float)getRSI_N2;
+(float)getRSI_N3;
#pragma mark - VOL
+(float)getVOL_N1;
+(float)getVOL_N2;
+(float)getVOL_N3;
#pragma mark - OBV
+(float)getOBV_N1;
#pragma mark - DMI
+(float)getDMI_N;
+(float)getDMI_M;
#pragma mark - SAR
+(float)getSAR_N;
+(float)getSAR_S;
+(float)getSAR_M;
@end
