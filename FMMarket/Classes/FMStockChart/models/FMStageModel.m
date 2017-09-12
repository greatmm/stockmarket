//
//  FMStageModel.m
//  FMStockChart
//
//  Created by dangfm on 15/7/26.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMStageModel.h"

// 舞台颜色
#define kStageLineColor [FMCommon colorWithHex:0xE8E8E8]            // 舞台装饰线颜色
#define kStageMiddleLineColor [FMCommon colorWithHex:0xE8E8E8]      // 舞台收盘线颜色
#define kStageLeftTextColor [FMCommon colorWithHex:0x666666]        // 左边文本颜色
#define kStageRightTextColor [FMCommon colorWithHex:0x666666]       // 舞台右边文本颜色
#define kStageBottomTextColor [FMCommon colorWithHex:0x666666]      // 舞台底部文本颜色
#define kStageMiddleTextColor [FMCommon colorWithHex:0x666666]      // 舞台中间收盘价横线文本颜色
#define kStageLineWidth 0.5                                         // 舞台线宽度
#define kStageHorizontalLine 4                                      // 舞台横线数量
#define kStageVerticalLine 3                                        // 舞台竖线数量
#define kStageMinuteHorizontalLine 4                                // 舞台分时图横线数量
#define kStageMinuteVerticalLine 3                                  // 舞台分时图竖线数量
#define kStagePadding 10.0                                          // 舞台内边距
#define kStagePaddingMiddle 15                                      // 舞台主图幅图间距
#define kStageTextFontSize 11                                       // 舞台文本大小
#define kStageTipTextFontSize 11                                     // 舞台提示文字大小

@implementation FMStageModel

//  初始化
-(instancetype)init{
    if (self==[super init]) {
        self.lineColor = kStageLineColor;
        self.middleLineColor = kStageMiddleLineColor;
        self.lineWidth = kStageLineWidth;
        self.horizontalLines = kStageHorizontalLine;
        self.verticalLines = kStageVerticalLine;
        FMStagePadding padding = {kStagePadding,0,kStagePadding,0,kStagePaddingMiddle};
        self.padding = padding;
        self.fontColor = kStageLeftTextColor;
        self.font = [UIFont systemFontOfSize:kStageTextFontSize];
        self.tipFont = [UIFont systemFontOfSize:kStageTipTextFontSize];
    }
    return self;
}
@end
