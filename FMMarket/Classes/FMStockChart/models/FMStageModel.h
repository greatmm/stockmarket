//
//  FMStageModel.h
//  FMStockChart
//
//  Created by dangfm on 15/7/26.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FMCommon.h"

typedef struct {
    float top;
    float right;
    float bottom;
    float left;
    float middle;
} FMStagePadding;

typedef struct {
    float maxValue;
    float minValue;
    float bottomMinValue;
    float bottomMaxValue;
} FMStagePrices;

@interface FMStageModel : NSObject

@property (nonatomic,assign) CGFloat width;                 // 舞台宽度
@property (nonatomic,assign) CGFloat height;                // 舞台高度
@property (nonatomic,assign) CGFloat topHeight;             // 顶部视图高度
@property (nonatomic,assign) CGFloat bottomHeight;          // 底部视图高度
@property (nonatomic,assign) CGFloat lineWidth;             // 舞台线条宽度
@property (nonatomic,assign) FMStagePadding padding;        // 舞台内边距
@property (nonatomic,assign) FMStagePrices prices;          // 左边价格集合

@property (nonatomic,assign) BOOL isShowSide;               // 是否显示边框周边指示 默认否 不显示
@property (nonatomic,assign) BOOL isHideRight;              // 是否显示边框右边文字提示 默认否 不显示
@property (nonatomic,assign) BOOL isHideLeft;               // 是否显示边框左边文字提示 默认否 不显示

@property (nonatomic,assign) NSInteger horizontalLines;     // 舞台横线数量
@property (nonatomic,assign) NSInteger verticalLines;       // 舞台竖线数量

@property (nonatomic,retain) UIColor * lineColor;           // 舞台线条颜色
@property (nonatomic,retain) UIColor * middleLineColor;     // 舞台中间收盘价横线颜色
@property (nonatomic,retain) UIFont *font;                  // 文本字体
@property (nonatomic,retain) UIFont *tipFont;               // 文本字体
@property (nonatomic,retain) UIColor *fontColor;            // 文本颜色




@end
