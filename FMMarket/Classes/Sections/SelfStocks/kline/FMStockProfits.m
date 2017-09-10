//
//  FMStockProfits.m
//  FMMarket
//
//  Created by dangfm on 15/10/6.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMStockProfits.h"
#import "UILabel+stocking.h"

@implementation FMProfitModel

-(instancetype)initWithDic:(NSDictionary *)dic{
    if (self==[super init]) {
        [fn reflectDataFromOtherObject:dic WithTarget:self];
    }
    return self;
}
@end

@interface FMStockProfits(){
    UILabel *_title;
    UIView *_chartViews;
    NSArray *_datas;
    double _maxValue;
    double _minValue;
    double _totalValue;
}

@end

@implementation FMStockProfits

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
                            Frame:CGRectMake(kFMStockProfits_Padding, kFMStockProfits_Padding, UIScreenWidth-2*kFMStockProfits_Padding, 0.5)];
        _title = [UILabel createWithTitle:@"利润同比增长率"
                                    Frame:CGRectMake(kFMStockProfits_Padding,10,UIScreenWidth-2*kFMStockProfits_Padding,kNavigationHeight)];
        _title.font = kFontBold(16);
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
        _chartViews = [[UIView alloc] initWithFrame:CGRectMake(_title.frame.origin.x+kFMStockProfits_Padding,
                                                               _title.frame.origin.y+_title.frame.size.height+10,
                                                               _title.frame.size.width-2*kFMStockProfits_Padding,
                                                               kFMStockProfits_ChartViewsHeight)];
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
    CGFloat y = kFMStockProfits_ChartViewsHeight-50;
    if (_maxValue<=0) {
        return;
    }
    [fn drawLineWithSuperView:_chartViews
                        Color:FMBottomLineColor
                        Frame:CGRectMake(0, y, _chartViews.frame.size.width, 0.5)];
    CGFloat w = _chartViews.frame.size.width / (2*_datas.count);
    CGFloat x = w/2;
    CGFloat h = kFMStockProfits_ChartViewsHeight-50;
    for (FMProfitModel *m in _datas) {
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
    for (FMProfitModel *m in _datas) {
        //_totalValue += fabs(m.incomeRate)+fabs(m.profitRate);
        if (fabs(m.incomeRate)>_maxValue) {
            _maxValue = fabs(m.incomeRate);
        }
        if (fabs(m.incomeRate)<_minValue) {
            _minValue = fabs(m.incomeRate);
        }
        if (fabs(m.profitRate)>_maxValue) {
            _maxValue = fabs(m.profitRate);
        }
        if (fabs(m.profitRate)<_minValue) {
            _minValue = fabs(m.profitRate);
        }
    }
}

-(void)createSignleChartWithModel:(FMProfitModel*)model frame:(CGRect)frame{
    CGFloat total = fabs(_maxValue)-fabs(_minValue);
    // 营业收入
    CGFloat h = (fabs(model.incomeRate)-fabs(_minValue)) / total * frame.size.height;
    if (h<1) {
        h=1;
    }
    CGFloat y = frame.origin.y - h;
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x, y, frame.size.width/2-1, h)];
    v.backgroundColor = FMRedColor;
    if (model.incomeRate<0) {
        v.backgroundColor = FMGreenColor;
    }
    [_chartViews addSubview:v];
    
    NSString *inflowTitle = [NSString stringWithFormat:@"%.2f%%",model.incomeRate];
    CGFloat tw = [inflowTitle sizeWithAttributes:@{NSFontAttributeName:kFontNumber(10)}].width;
    UILabel *inflow = [UILabel createWithTitle:inflowTitle
                                         Frame:CGRectMake(frame.origin.x+(frame.size.width/2-tw)/2+1, y-15, tw, 15)];
    inflow.font = kFontNumber(8);
    inflow.textColor = v.backgroundColor;
    inflow.textAlignment = NSTextAlignmentLeft;
    [_chartViews addSubview:inflow];
    
    // 营业／利润
    UILabel *yy = [UILabel createWithTitle:@"营\n业\n收\n入" Frame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width/2, 50)];
    yy.font = kFont(10);
    yy.textAlignment = NSTextAlignmentCenter;
    yy.textColor = v.backgroundColor;
    [_chartViews addSubview:yy];
    
    
    inflow = nil;
    v = nil;
    // 净利润
    h = (fabs(model.profitRate)-fabs(_minValue)) / total * frame.size.height;
    if (h<1) {
        h=1;
    }
    y = frame.origin.y-h;
    UIView *vr = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.x+frame.size.width/2+1, y, frame.size.width/2-1, h)];
    vr.backgroundColor = FMRedColor;
    if (model.profitRate<0) {
        vr.backgroundColor = FMGreenColor;
    }
    [_chartViews addSubview:vr];
    
    NSString *flowOutTitle = [NSString stringWithFormat:@"%.2f%%",model.profitRate];
    tw = [flowOutTitle sizeWithAttributes:@{NSFontAttributeName:kFontNumber(10)}].width;
    UILabel *flowout = [UILabel createWithTitle:flowOutTitle
                                          Frame:CGRectMake(frame.origin.x+frame.size.width/2+1, y-15, tw, 15)];
    flowout.font = kFontNumber(8);
    flowout.textColor = vr.backgroundColor;
    flowout.textAlignment = NSTextAlignmentLeft;
    [_chartViews addSubview:flowout];
    // 利润
    UILabel *lr = [UILabel createWithTitle:@"净\n利\n润" Frame:CGRectMake(frame.origin.x+frame.size.width/2+1, frame.origin.y, frame.size.width/2, 50)];
    lr.font = kFont(10);
    lr.textAlignment = NSTextAlignmentCenter;
    lr.textColor = vr.backgroundColor;
    [_chartViews addSubview:lr];
    flowout = nil;
    vr = nil;
    // 文字
    model.title = [NSString stringWithFormat:@"%@\n%@",[model.title substringToIndex:4],[model.title substringFromIndex:4]];
    tw = [model.title sizeWithAttributes:@{NSFontAttributeName:kFont(12)}].width;
    UILabel *title = [UILabel createWithTitle:model.title
                                        Frame:CGRectMake(frame.origin.x+(frame.size.width-tw)/2,
                                                         _chartViews.frame.size.height,tw,15)];
    title.font = kFont(12);
    //title.textColor = FMGreyColor;
    title.numberOfLines = 0;
    [title sizeToFit];
    title.textAlignment = NSTextAlignmentCenter;
    [_chartViews addSubview:title];
    
    
}


@end
