//
//  FMKLineRecentlyMainForce.m
//  FMMarket
//
//  Created by dangfm on 15/9/1.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMKLineRecentlyMainForce.h"
#import "UILabel+stocking.h"

@implementation FMRecentlyModel
-(instancetype)initWithDic:(NSDictionary *)dic{
    if (self==[super init]) {
        [fn reflectDataFromOtherObject:dic WithTarget:self];
    }
    return self;
}
@end

@interface FMKLineRecentlyMainForce(){
    UILabel *_title;
    UIView *_chartViews;
    NSArray *_datas;
    double _maxValue;
    double _minValue;
    double _totalValue;
}

@end

@implementation FMKLineRecentlyMainForce

-(instancetype)initWithFrame:(CGRect)frame datas:(NSArray*)datas{
    if (self==[super initWithFrame:frame]) {
        _datas = datas;
        [self findMaxMinValue];
        [self createViews];
    }
    return self;
}

-(void)startWithDatas:(NSArray*)datas title:(NSString *)title{
    _datas = datas;
    _titler = title;
    [self createCharts];
}

-(void)createViews{
    
    [self createTitleViews];
    [self createCharts];
}

-(void)createTitleViews{
    if (!_title) {
        [fn drawLineWithSuperView:self
                            Color:FMBottomLineColor
                            Frame:CGRectMake(kFMKLineRecentlyMainForce_Padding, kFMKLineRecentlyMainForce_Padding, UIScreenWidth-2*kFMKLineRecentlyMainForce_Padding, 0.5)];
        _title = [UILabel createWithTitle:@"实时成交分布(万元)"
                                    Frame:CGRectMake(kFMKLineRecentlyMainForce_Padding,10,UIScreenWidth-2*kFMKLineRecentlyMainForce_Padding,kNavigationHeight)];
        [self addSubview:_title];
    }
}

-(void)createCharts{
    if (!_datas) {
        return;
    }
    if (_chartViews) {
        [_chartViews removeFromSuperview];
        _chartViews = nil;
    }
    if (_titler) {
        _title.text = _titler;
    }
    if (!_chartViews) {
        _chartViews = [[UIView alloc] initWithFrame:CGRectMake(_title.frame.origin.x+kFMKLineRecentlyMainForce_Padding,
                                                               _title.frame.origin.y+_title.frame.size.height+10,
                                                               _title.frame.size.width-2*kFMKLineRecentlyMainForce_Padding,
                                                               kFMKLineRecentlyMainForce_ChartViewsHeight)];
        _chartViews.backgroundColor = [UIColor clearColor];
        [self addSubview:_chartViews];
        [self drawCharts];
    }
}

-(void)drawCharts{
    if (!_datas) {
        return;
    }
    [self findMaxMinValue];
    // 画分割线
    CGFloat y = _maxValue/(fabs(_maxValue)+fabs(_minValue)) * kFMKLineRecentlyMainForce_ChartViewsHeight/2;
    if (_maxValue<=0) {
        return;
    }
    [fn drawLineWithSuperView:_chartViews
                        Color:FMBottomLineColor
                        Frame:CGRectMake(0, y, _chartViews.frame.size.width, 0.5)];
    CGFloat w = _chartViews.frame.size.width / (2*_datas.count);
    CGFloat x = w/2;
    CGFloat h = kFMKLineRecentlyMainForce_ChartViewsHeight;
    for (FMRecentlyModel *m in _datas) {
        [self createSignleChartWithModel:m frame:CGRectMake(x, y, w, h)];
        x += 2*w;
    }
}

-(void)findMaxMinValue{
    if (!_datas) {
        return;
    }
    _maxValue = 0;
    _minValue = CGFLOAT_MAX;
    for (FMRecentlyModel *m in _datas) {
        _totalValue += fabs(m.inflow)+fabs(m.flowOut);
        if (m.inflow>_maxValue) {
            _maxValue = m.inflow;
        }
        if (m.inflow<_minValue) {
            _minValue = m.inflow;
        }
        if (m.flowOut>_maxValue) {
            _maxValue = m.flowOut;
        }
        if (m.flowOut<_minValue) {
            _minValue = m.flowOut;
        }
    }
}

-(void)createSignleChartWithModel:(FMRecentlyModel*)model frame:(CGRect)frame{
    CGFloat total = fabs(_maxValue)+fabs(_minValue);
    // 流入
    CGFloat h = fabs(model.inflow) / total * frame.size.height/2;
    if (h<1) {
        h=1;
    }
    CGFloat y = frame.origin.y - h;
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x, y, frame.size.width, h)];
    v.backgroundColor = FMRedColor;
    [_chartViews addSubview:v];
    v = nil;
    NSString *inflowTitle = [NSString stringWithFormat:@"%.f",model.inflow];
    CGFloat tw = [inflowTitle sizeWithAttributes:@{NSFontAttributeName:kFontNumber(10)}].width;
    UILabel *inflow = [UILabel createWithTitle:inflowTitle
                                         Frame:CGRectMake(frame.origin.x+(frame.size.width-tw)/2, y-15, tw, 15)];
    inflow.font = kFontNumber(10);
    inflow.textColor = FMRedColor;
    inflow.textAlignment = NSTextAlignmentCenter;
    [_chartViews addSubview:inflow];
    inflow = nil;
    
    // 流出
    h = fabs(model.flowOut) / total * frame.size.height/2;
    if (h<1) {
        h=1;
    }
    y = frame.origin.y;
    UIView *vr = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x, y, frame.size.width, h)];
    vr.backgroundColor = FMGreenColor;
    [_chartViews addSubview:vr];
    vr = nil;
    NSString *flowOutTitle = [NSString stringWithFormat:@"%.f",model.flowOut];
    tw = [flowOutTitle sizeWithAttributes:@{NSFontAttributeName:kFontNumber(10)}].width;
    UILabel *flowout = [UILabel createWithTitle:flowOutTitle
                                         Frame:CGRectMake(frame.origin.x+(frame.size.width-tw)/2, y+h, tw, 15)];
    flowout.font = kFontNumber(10);
    flowout.textColor = FMGreenColor;
    flowout.textAlignment = NSTextAlignmentCenter;
    [_chartViews addSubview:flowout];
    flowout = nil;
    
    // 文字
    tw = [model.title sizeWithAttributes:@{NSFontAttributeName:kFont(12)}].width;
    UILabel *title = [UILabel createWithTitle:model.title
                                        Frame:CGRectMake(frame.origin.x+(frame.size.width-tw)/2,
                                                         _chartViews.frame.size.height+20,tw,15)];
    title.font = kFont(12);
    title.textAlignment = NSTextAlignmentCenter;
    [_chartViews addSubview:title];
}

@end
