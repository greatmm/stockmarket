//
//  FMStockModel.m
//  FMStockChart
//
//  Created by dangfm on 15/7/26.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMStockModel.h"

// K线颜色
#define kKLineUpColor kFMColor(0xf33f58)
#define kKLineDownColor kFMColor(0x18c062)
#define kKLineGreyColor kFMColor(0x666666)

// 分时图
#define kStockMinuteLineColor kFMColor(0x469cff)
#define kStockMinuteLinePathFillColor kFMColor(0xe3f0ff)
#define kStockMinuteLineAverageColor kFMColor(0xffbf00)
// MA线
#define kStockMA5Color kFMColor(0x1a9801)                     // 绿色
#define kStockMA10Color kFMColor(0xfe4a87)                    // 红色
#define kStockMA20Color kFMColor(0xffbf00)                    // 黄色
// EMA
#define kStockEMAColor kFMColor(0xFF0000)
// VOL
#define kStockVOL_N1Color kFMColor(0x1a9801)
#define kStockVOL_N2Color kFMColor(0xfe4a87)
#define kStockVOL_N3Color kFMColor(0xffbf00)
// BOLL
#define kStockBOLL_UPColor kFMColor(0x1a9801)
#define kStockBOLL_MIDDLEColor kFMColor(0xfe4a87)
#define kStockBOLL_DOWNColor kFMColor(0xffbf00)
// MACD
#define kStockMACD_DIFColor kFMColor(0x1a9801)
#define kStockMACD_DEAColor kFMColor(0xfe4a87)
// KDJ
#define kStockKDJ_KColor kFMColor(0x1a9801)
#define kStockKDJ_DColor kFMColor(0xfe4a87)
#define kStockKDJ_JColor kFMColor(0xffbf00)
// RSI
#define kStockRSI_N1Color kFMColor(0x1a9801)
#define kStockRSI_N2Color kFMColor(0xfe4a87)
#define kStockRSI_N3Color kFMColor(0xffbf00)
// OBV
#define kStockOBVColor kFMColor(0xFF0000)
// DMI
#define kStockDMI_PDIColor kFMColor(0x1a9801)
#define kStockDMI_MDIColor kFMColor(0xfe4a87)
#define kStockDMI_ADXColor kFMColor(0xffbf00)
#define kStockDMI_ADXRColor kFMColor(0x008cdc)
// 虚线
#define kStockDottedLineColor kFMColor(0xfe4a87)
// 逃顶王
#define kStockTDW_JDMCColor kFMColor(0xC6C600)
#define kStockTDW_QCMCColor kFMColor(0xFF75FF)
#define kStockTDW_BOTTOMColor kFMColor(0x70DB93)
#define kStockTDW_GZColor kFMColor(0xffbf00)
#define kStockTDW_QRFJXColor kFMColor(0x70DB93)
#define kStockTDW_SZColor kFMColor(0xA8A8A8)

#define kStockPointsKey_KLineMinute @"kline_minute"
#define kStockPointsKey_KLine @"kline"
#define kStockPointsKey_SMA_N1 @"sma_n1"
#define kStockPointsKey_SMA_N2 @"sma_n2"
#define kStockPointsKey_SMA_N3 @"sma_n3"
#define kStockPointsKey_EMA @"ema"
#define kStockPointsKey_BOLL @"boll"
#define kStockPointsKey_MACD @"macd"
#define kStockPointsKey_KDJ @"kdj"
#define kStockPointsKey_RSI @"rsi"


#define kSmallLineWith 1.0

@implementation FMStockModel


-(instancetype)init{
    if (self==[super init]) {
        // 初始化
        self.type = FMStockType_MinuteChart;
        self.marketType = FMMarketType_A;
        self.isChangeData = NO;
        self.isFinished = YES;
        self.isShowMiddleLine = NO;
        self.isStopDraw = NO;
        self.isZooming = NO;
        self.isShadow = NO;
        self.isReset = YES;
        self.isShowBottomViews = YES;
        self.isOpenSignal = NO;
        self.isShowLeftText = YES;
        self.isShowRightText = YES;
        self.isScrolling = NO;
        self.isPressing = NO;
        
        self.maxPrice = 0;
        self.minPrice = CGFLOAT_MAX;
        self.bottomMaxPrice = 0;
        self.bottomMinPrice = CGFLOAT_MAX;
        self.minuteRefreshTime = 30;
        
        self.klineWidth = 4;
        self.klinePadding = 1.5;
        
        self.prices = [NSMutableArray new];
        self.points = [NSMutableArray new];
        self.allPoints = [NSMutableArray new];
        self.times = [NSMutableArray new];
        self.subPrices = [NSMutableArray new];
        self.drawDatas = [NSMutableDictionary new];
        
        self.stockIndexType = FMStockIndexType_SMA;
        self.stockIndexBottomType = FMStockIndexType_VOL;
        self.type = FMStockType_MinuteChart;
        self.stockChartDirectionStyle = FMStockDirection_Vertical;
        
        self.offsetStart = -1;
        self.drawOffsetStart = 0;
        
        self.leftEmptyKline = 5;
        self.rightEmptyKline = 5;
        
        self.klineUpColor = kKLineUpColor;
        self.klineDownColor = kKLineDownColor;
        self.klineGreyColor = kKLineGreyColor;
        self.klineMAN1Color = kStockMA5Color;
        self.klineMAN2Color = kStockMA10Color;
        self.klineMAN3Color = kStockMA20Color;
        self.klineEMAColor = kStockEMAColor;
        self.klineBOLLDownColor = kStockBOLL_DOWNColor;
        self.klineBOLLMiddleColor = kStockBOLL_MIDDLEColor;
        self.klineBOLLUpColor = kStockBOLL_UPColor;
        self.klineMACDDEAColor = kStockMACD_DEAColor;
        self.klineMACDDIFColor = kStockMACD_DIFColor;
        self.klineKDJDColor = kStockKDJ_DColor;
        self.klineKDJJColor = kStockKDJ_JColor;
        self.klineKDJKColor = kStockKDJ_KColor;
        self.klineRSIN1Color = kStockRSI_N1Color;
        self.klineRSIN2Color = kStockRSI_N2Color;
        self.klineRSIN3Color = kStockRSI_N3Color;
        self.klineMinuteColor = kStockMinuteLineColor;
        self.klineMinutePathFillColor = kStockMinuteLinePathFillColor;
        self.klineMinuteAverageColor = kStockMinuteLineAverageColor;
        self.klineMinuteDashColor = kStockDottedLineColor;
        self.klineVOLN1Color = kStockVOL_N1Color;
        self.klineVOLN2Color = kStockVOL_N2Color;
        self.klineVOLN3Color = kStockVOL_N3Color;
        self.klineOBVColor = kStockOBVColor;
        self.klineDMIPDIColor = kStockDMI_PDIColor;
        self.klineDMIMDIColor = kStockDMI_MDIColor;
        self.klineDMIADXColor = kStockDMI_ADXColor;
        self.klineDMIADXRColor = kStockDMI_ADXRColor;
        self.klineTDWBOTTOMColor = kStockTDW_BOTTOMColor;
        self.klineTDWGZColor = kStockTDW_GZColor;
        self.klineTDWJDMCColor = kStockTDW_JDMCColor;
        self.klineTDWQCMCColor = kStockTDW_QCMCColor;
        self.klineTDWQRFJXColor = kStockTDW_QRFJXColor;
        self.klineTDWSZColor = kStockTDW_SZColor;
        
        // 舞台初始化
        FMStageModel *stage = [[FMStageModel alloc] init];
        self.stage = stage;
        
    }
    return self;
}


@end
