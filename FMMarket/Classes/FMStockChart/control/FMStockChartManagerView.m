//
//  FMStockChartManagerView.m
//  FMStockChart
//
//  Created by dangfm on 15/8/19.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMStockChartManagerView.h"

@implementation FMStockChartManagerView

static FMStockChartManagerView *instance=nil;

+(FMStockChartManagerView*)manager{
    instance = [[FMStockChartManagerView alloc] init];
    return instance;
}

-(void)dealloc{
    FMLog(@"FMStockChartManagerView dealloc");
}

-(void)clear{
    [_baseView removeFromSuperview];
    [_baseView clear];
    _baseView.delegate = nil;
    _baseView = nil;
}

+ (void)destroyDealloc
{
    //instance = nil;
}

-(FMBaseView*)createWithFrame:(CGRect)frame Model:(FMStockModel *)model SuperView:(UIView*)superView{
    switch ((int)model.type) {
        case FMStockType_MinuteChart:
            _baseView = [[FMKLineMinuteView alloc] initWithFrame:frame Model:model];
            break;
        case FMStockType_FiveDaysChart:
            _baseView = [[FMKLineFiveDaysView alloc] initWithFrame:frame Model:model];
            break;
        case FMStockType_DaysChart:
            _baseView = [[FMKLineDaysView alloc] initWithFrame:frame Model:model];
            break;
        case FMStockType_1MinuteChart:
        case FMStockType_5MinuteChart:
        case FMStockType_15MinuteChart:
        case FMStockType_30MinuteChart:
        case FMStockType_60MinuteChart:
            _baseView = [[FMKLineMLineView alloc] initWithFrame:frame Model:model];
            break;
        case FMStockType_WeekChart:
            _baseView = [[FMKLineWeekView alloc] initWithFrame:frame Model:model];
            break;
        case FMStockType_MonthChart:
            _baseView = [[FMKLineMonthView alloc] initWithFrame:frame Model:model];
            break;
        default:
            _baseView = [[FMKLineMinuteView alloc] initWithFrame:frame Model:model];
            break;
    }
    if (superView) {
        [superView addSubview:_baseView];
    }
    superView = nil;
    
    return _baseView;
}

@end
