//
//  FMStockChartManagerView.h
//  FMStockChart
//
//  Created by dangfm on 15/8/19.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//
#import "HttpManager.h"
#import "FMStockModel.h"
#import "FMKLineMinuteView.h"
#import "FMKLineFiveDaysView.h"
#import "FMKLineDaysView.h"
#import "FMKLineWeekView.h"
#import "FMKLineMonthView.h"
#import "FMKLineMLineView.h"
#import "FMStockLoadingView.h"

@interface FMStockChartManagerView : NSObject

@property (nonatomic,retain) FMBaseView *baseView;

+(FMStockChartManagerView*)manager;
+(void)destroyDealloc;

/**
 *  视图管理器
 *
 *  @param frame 位置
 *  @param model 模型
 *
 *  @return 相应的视图
 */
-(FMBaseView*)createWithFrame:(CGRect)frame Model:(FMStockModel *)model SuperView:(UIView*)superView;
-(void)clear;
@end
