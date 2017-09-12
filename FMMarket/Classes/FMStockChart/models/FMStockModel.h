//
//  FMStockModel.h
//  FMStockChart
//
//  Created by dangfm on 15/7/26.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FMHeader.h"
#import "FMStageModel.h"
#import "FMCommon.h"


typedef enum{
    FMStockIndexType_VOL,           // 成交量
    FMStockIndexType_MACD,          // MACD指标
    FMStockIndexType_KDJ,           // KDJ指标
    FMStockIndexType_RSI,           // RSI指标
    FMStockIndexType_BOLL,          // BOLL指标
    FMStockIndexType_EMA,           // EMA均线
    FMStockIndexType_SMA,           // SMA军线
    FMStockIndexType_OBV,           // OBV指标
    FMStockIndexType_DMI,           // DMI指标
    FMStockIndexType_SAR            // SAR指标
} FMKLineStockIndexType;


typedef enum {
    FMStockDirection_Horizontal,    // 横屏
    FMStockDirection_Vertical       // 竖屏
} FMStockDirectionStyle;

typedef enum{
    FMStockType_MinuteChart,        // 分时图
    FMStockType_FiveDaysChart,      // 5日分时图
    FMStockType_DaysChart,          // 日K
    FMStockType_WeekChart,          // 周k
    FMStockType_MonthChart,         // 月K
    FMStockType_1MinuteChart,       // 1分钟k线
    FMStockType_5MinuteChart,       // 5分钟K线
    FMStockType_15MinuteChart,      // 15分钟k线
    FMStockType_30MinuteChart,      // 30分钟k线
    FMStockType_60MinuteChart       // 60分钟k线
} FMStockChartType;


typedef enum{
    FMMarketType_A,                 // A股
    FMMarketType_B,                 // B股
    FMMarketType_HK,                // 港股
    FMMarketType_US,                // 每股
    FMMarketType_AH                 // AH股
} FMMarketType;

typedef enum{
    FMMarketFuquan_None,                 // 不复权
    FMMarketFuquan_Before,               // 前复权
    FMMarketFuquan_Back,                 // 后复权
    
} FMMarketFuquan_Type;

@interface FMStockModel : NSObject

@property (nonatomic,retain) FMStageModel *stage;           // 舞台模型
@property (nonatomic,assign) FMStockChartType type;         // 股票图表类型
@property (nonatomic,assign) FMMarketType marketType;       // 市场行情类型
@property (nonatomic,assign) FMMarketFuquan_Type fuquanType;       // k线图复权类型

@property (nonatomic,retain) UIColor *klineUpColor;         // 红涨
@property (nonatomic,retain) UIColor *klineDownColor;       // 绿跌
@property (nonatomic,retain) UIColor *klineGreyColor;       // 不涨不跌
@property (nonatomic,retain) UIColor *klineMinuteColor;     // 分时线颜色
@property (nonatomic,retain) UIColor *klineMinutePathFillColor;     // 分时线填充颜色
@property (nonatomic,retain) UIColor *klineMinuteAverageColor;      // 分时图均线颜色
@property (nonatomic,retain) UIColor *klineMinuteDashColor;         // 分时图虚线颜色
@property (nonatomic,retain) UIColor *klineMAN1Color;       // MAN1颜色
@property (nonatomic,retain) UIColor *klineMAN2Color;       // MAN2颜色
@property (nonatomic,retain) UIColor *klineMAN3Color;       // MAN3颜色
@property (nonatomic,retain) UIColor *klineEMAColor;        // EMA颜色
@property (nonatomic,retain) UIColor *klineBOLLUpColor;     // BOLLUP颜色
@property (nonatomic,retain) UIColor *klineBOLLMiddleColor; // BOLLMIDDLE颜色
@property (nonatomic,retain) UIColor *klineBOLLDownColor;   // BOLLDOWN颜色
@property (nonatomic,retain) UIColor *klineMACDDIFColor;    // MACDDIF颜色
@property (nonatomic,retain) UIColor *klineMACDDEAColor;    // MACDDEA颜色
@property (nonatomic,retain) UIColor *klineKDJKColor;       // KDJK颜色
@property (nonatomic,retain) UIColor *klineKDJDColor;       // KDJD颜色
@property (nonatomic,retain) UIColor *klineKDJJColor;       // KDJJ颜色
@property (nonatomic,retain) UIColor *klineRSIN1Color;      // RSIN1颜色
@property (nonatomic,retain) UIColor *klineRSIN2Color;      // RSIN2颜色
@property (nonatomic,retain) UIColor *klineRSIN3Color;      // RSIN3颜色
@property (nonatomic,retain) UIColor *klineVOLN1Color;      // VOLN1颜色
@property (nonatomic,retain) UIColor *klineVOLN2Color;      // VOLN2颜色
@property (nonatomic,retain) UIColor *klineVOLN3Color;      // VOLN3颜色
@property (nonatomic,retain) UIColor *klineOBVColor;        // OBV颜色
@property (nonatomic,retain) UIColor *klineDMIPDIColor;     // DMI_PDI颜色
@property (nonatomic,retain) UIColor *klineDMIMDIColor;     // DMI_MDI颜色
@property (nonatomic,retain) UIColor *klineDMIADXColor;     // DMI_ADX颜色
@property (nonatomic,retain) UIColor *klineDMIADXRColor;    // DMI_ADXR颜色
@property (nonatomic,retain) UIColor *klineTDWJDMCColor;    // TDW_JDMC颜色
@property (nonatomic,retain) UIColor *klineTDWQCMCColor;    // TDW_QCMC颜色
@property (nonatomic,retain) UIColor *klineTDWBOTTOMColor;  // TDW_BOTTOM颜色
@property (nonatomic,retain) UIColor *klineTDWGZColor;      // TDW_GZ颜色
@property (nonatomic,retain) UIColor *klineTDWQRFJXColor;   // TDW_QRFJX颜色
@property (nonatomic,retain) UIColor *klineTDWSZColor;      // TDW_SZ颜色

@property (nonatomic,assign) int offsetLastStart;           // 上一个数据偏移起点
@property (nonatomic,assign) int offsetStart;               // 数据偏移起点
@property (nonatomic,assign) int offsetEnd;                 // 数据偏移终点
@property (nonatomic,assign) int offsetMiddle;              // 数据偏移中间点
@property (nonatomic,assign) int drawOffsetStart;           // 画K线数据偏移起点
@property (nonatomic,assign) int leftEmptyKline;            // 左边空的k线数量
@property (nonatomic,assign) int rightEmptyKline;           // 右边空的k线数量
@property (nonatomic,assign) int counts;                    // k线总数
@property (nonatomic,assign) int upCounts;                  // 分时图上半场数量
@property (nonatomic,assign) int downCounts;                // 分时图下半场数量

@property (nonatomic,retain) NSString *startTime;           // 分时图开始时间
@property (nonatomic,retain) NSString *middleTime;          // 分时图中间时间
@property (nonatomic,retain) NSString *endTime;             // 分时图结束时间
@property (nonatomic,retain) NSString *stockCode;           // 品种编码
@property (nonatomic,retain) NSString *stockType;           // 股票类型 0=普通股票 1=指数
@property (nonatomic,retain) NSString *realtimeData;           // 实时行情日期

@property (nonatomic,assign) CGPoint scrollOffset;          // 滚动偏移距离

@property (nonatomic,assign) BOOL isChangeData;             // 是否变更过数据

@property (nonatomic,assign) BOOL isStopDraw;               // 停止画图
@property (nonatomic,assign) BOOL isFinished;               // 是否画图完成
@property (nonatomic,assign) BOOL isShowMiddleLine;         // 是否画中间横线（主要针对分时图）
@property (nonatomic,assign) BOOL isZooming;                // 是否正在放大缩小
@property (nonatomic,assign) BOOL isShadow;                 // 是否显示阴影
@property (nonatomic,assign) BOOL isReset;                  // 是否重置
@property (nonatomic,assign) BOOL isShowBottomViews;        // 是否显示副图指标
@property (nonatomic,assign) BOOL isOpenSignal;             // 是否开启信号
@property (nonatomic,assign) BOOL isShowLeftText;               // 是否显示周边文本
@property (nonatomic,assign) BOOL isShowRightText;               // 是否显示周边文本
@property (nonatomic,assign) BOOL isScrolling;              // 是否正在滚动
@property (nonatomic,assign) BOOL isPressing;               // 是否正在按压

@property (nonatomic,assign) CGFloat maxPrice;              // 最高价
@property (nonatomic,assign) CGFloat minPrice;              // 最低价
@property (nonatomic,assign) CGFloat maxMinSubPrice;        // 最低最高价加了多少
@property (nonatomic,assign) CGFloat bottomMaxPrice;        // 副图指标最高价
@property (nonatomic,assign) CGFloat bottomMinPrice;        // 副图指标最低价
@property (nonatomic,assign) CGFloat maxPower;              // 量能最大值
@property (nonatomic,assign) CGFloat minPower;              // 量能最小值
@property (nonatomic,assign) CGFloat upMinutes;             // 上午分钟数
@property (nonatomic,assign) CGFloat downMinutes;           // 下午分钟数
@property (nonatomic,assign) CGFloat lastClosePrice;        // k线最后一个收盘价
@property (nonatomic,assign) CGFloat klineWidth;            // k线宽度
@property (nonatomic,assign) CGFloat klinePadding;          // k线相隔距离
@property (nonatomic,assign) CGFloat yestodayClosePrice;    // 昨日收盘价
@property (nonatomic,assign) CGFloat scale;                 // 放大缩小倍数
@property (nonatomic,assign) CGFloat minuteRefreshTime;     // 分时图刷新时间 默认30秒


@property (nonatomic,retain) NSMutableArray *points;                // 坐标集合
@property (nonatomic,retain) NSMutableArray *allPoints;             // 坐标集合
@property (nonatomic,retain) NSMutableArray *prices;                // 价格集合
@property (nonatomic,retain) NSMutableArray *subPrices;             // 显示的价格集合
@property (nonatomic,retain) NSMutableArray *times;                 // 时间集合
@property (nonatomic,retain) NSMutableArray *bottomTimes;           // 时间集合 用来画底部的
@property (nonatomic,retain) NSMutableArray *lastPoints;            // 最后一个k线数据集合
@property (nonatomic,retain) NSMutableDictionary *firstMonthDay;    // 每月第一个交易日
@property (nonatomic,retain) NSMutableDictionary *drawDatas;             // 画图命令集合

@property (nonatomic,assign) FMKLineStockIndexType stockIndexType;           // k线图指标类型
@property (nonatomic,assign) FMKLineStockIndexType stockIndexBottomType;     // 副图指标类型

@property (nonatomic,assign) FMStockDirectionStyle stockChartDirectionStyle;      // 横竖屏状态

@end

