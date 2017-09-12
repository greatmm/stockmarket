//
//  FMStockDaysModel.h
//  FMStockChart
//
//  Created by dangfm on 15/8/21.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    FMKLineSignleType_None,
    FMKLineSignleType_Up,
    FMKLineSignleType_Down
} FMKLineSignleType;

@interface FMStockDaysModel : NSObject

@property (nonatomic,retain) NSString *closePrice;
@property (nonatomic,retain) NSString *code;
@property (nonatomic,retain) NSString *datetime;
@property (nonatomic,retain) NSString *heightPrice;
@property (nonatomic,retain) NSString *lowPrice;
@property (nonatomic,retain) NSString *openPrice;
@property (nonatomic,retain) NSString *volPrice;
@property (nonatomic,retain) NSString *volumn;
@property (nonatomic,retain) NSString *yestodayClosePrice;
// 指标
// 指标
@property (nonatomic,retain) NSString *MA5;
@property (nonatomic,retain) NSString *MA10;
@property (nonatomic,retain) NSString *MA20;
@property (nonatomic,retain) NSString *MA30;
@property (nonatomic,retain) NSString *MA60;
@property (nonatomic,retain) NSString *MA120;
@property (nonatomic,retain) NSString *volMA_N1;
@property (nonatomic,retain) NSString *volMA_N2;
@property (nonatomic,retain) NSString *volMA_N3;
@property (nonatomic,retain) NSString *MACD_DIF;
@property (nonatomic,retain) NSString *MACD_DEA;
@property (nonatomic,retain) NSString *MACD_M;
@property (nonatomic,retain) NSString *MACD_12EMA;
@property (nonatomic,retain) NSString *MACD_26EMA;
@property (nonatomic,retain) NSString *KDJ_K;
@property (nonatomic,retain) NSString *KDJ_D;
@property (nonatomic,retain) NSString *KDJ_J;
@property (nonatomic,retain) NSString *RSI_1;
@property (nonatomic,retain) NSString *RSI_2;
@property (nonatomic,retain) NSString *RSI_3;
@property (nonatomic,retain) NSString *EMA;
@property (nonatomic,retain) NSString *EMA_S;
@property (nonatomic,retain) NSString *BOLL_UP;
@property (nonatomic,retain) NSString *BOLL_MIDDLE;
@property (nonatomic,retain) NSString *BOLL_DOWN;
@property (nonatomic,retain) NSString *SMA;
@property (nonatomic,retain) NSString *OBV;
@property (nonatomic,retain) NSString *OBV_N1;
@property (nonatomic,retain) NSString *SAR;
@property (nonatomic,retain) NSString *SAR_ORI;
@property (nonatomic,retain) NSString *SAR_T;
@property (nonatomic,retain) NSString *SAR_BUY;
@property (nonatomic,retain) NSString *SAR_RATE;
@property (nonatomic,retain) NSString *DMI_PDI;
@property (nonatomic,retain) NSString *DMI_MDI;
@property (nonatomic,retain) NSString *DMI_ADX;
@property (nonatomic,retain) NSString *DMI_ADXR;
@property (nonatomic,retain) NSString *CYE0;
@property (nonatomic,retain) NSString *CYEL;
@property (nonatomic,retain) NSString *CYES;

@property (nonatomic,assign) int index;

@property (nonatomic,assign) FMKLineSignleType signleType;

-(instancetype)initWithDic:(NSMutableDictionary*)dic;
@end
