//
//  FMBaseView.m
//  FMStockChart
//
//  Created by dangfm on 15/7/25.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMBaseView.h"
#import "HttpManager.h"
#import "FMHeader.h"
#import "FMStockLoadingView.h"
#import "FMStockDaysModel.h"
#import "FMStockMinuteModel.h"
#import "FMStockMaxMinValues.h"
#import "FMStockTransformDatas.h"

#define fmFMBaseTipViewsHeight 15

@interface FMBaseView()
<UIScrollViewDelegate>
{
    
}

@end

@implementation FMBaseView

-(void)dealloc{
    FMLog(@"FMBaseView dealloc");
}

-(void)clear{
    [self removeFromSuperview];
    self.model = nil;
    self.gestureRecognizers = nil;
    self.delegate = nil;
}

-(instancetype)init{
    if (self==[super init]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame Model:(FMStockModel*)model{
    if (self==[super initWithFrame:frame]) {
        self.model = model;
        if (self.model.stockChartDirectionStyle==FMStockDirection_Horizontal) {
            self.layer.borderColor = self.model.stage.lineColor.CGColor;
            self.layer.borderWidth = self.model.stage.lineWidth;
            self.model.stage.topHeight = self.frame.size.height/4*3;
            self.model.stage.bottomHeight = self.frame.size.height/4-self.model.stage.padding.middle;
        }else{
            self.model.stage.topHeight = self.frame.size.height/4*3;
            self.model.stage.bottomHeight = self.frame.size.height/4-self.model.stage.padding.middle;
           
        }
        [self createGestureViews];
        
        
    }
    return self;
}

-(void)updateWithModel:(FMStockModel *)model{
    // 拿最后一个有数据的点
    FMStockMinuteModel *m;
    for (FMStockMinuteModel *item in model.prices) {
        if (item.volumn>0) {
            m = item;
        }
    }
    // 第一次更新提示信息
    [self updateTipsWithModel:_model.prices.lastObject];
//        if (_model.type==FMStockType_MinuteChart) {
//            FMLog(@"第一次创建分时图成交量显示区域")
//            
//        }
    // 底部成交量显示
    // [self createMinuteVolumnTipWithModel:m];
}

-(void)createGestureViews{
    // 长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] init];
    [longPress addTarget:self action:@selector(longPressHandle:)];
    [longPress setMinimumPressDuration:0.2f];
    [longPress setAllowableMovement:50.0];
    [self addGestureRecognizer:longPress];
    longPress = nil;
    
    // 点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    [tap addTarget:self action:@selector(tapHandle:)];
    [self addGestureRecognizer:tap];
    tap = nil;
    if (_model.type==FMStockType_MinuteChart) {
        [self createBottomTipsWithPoint:CGPointZero Prices:nil];
    }
    [self updateTipsWithModel:_model.prices.lastObject];
}

-(void)longPressHandle:(UILongPressGestureRecognizer*)longResture{
    if (_model.points.count<=0) {
        return;
    }

    CGPoint touchViewPoint = [longResture locationInView:self];
    // 手指长按开始时更新一遍
    if(longResture.state == UIGestureRecognizerStateBegan){

        [self createCrossLineWithTouchPoint:touchViewPoint];
    }
    // 手指移动时候开始显示十字线
    if (longResture.state == UIGestureRecognizerStateChanged) {
        _model.isPressing = YES;
        [self createCrossLineWithTouchPoint:touchViewPoint];
    }
    
    // 手指离开的时候移除十字线
    if (longResture.state == UIGestureRecognizerStateEnded) {
        _model.isPressing = NO;
//        __FMWeakSelf;
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            // 需要停留等待数据进来
//            [NSThread sleepForTimeInterval:2];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                FMLog(@"%d",(int)longResture.state);
//                if (longResture.state == UIGestureRecognizerStatePossible) {
//                    [__weakSelf removeCrossLine];
//                    
//                }
//            });
//        });
        // 底部成交量显示
        if (_model.type==FMStockType_MinuteChart) {
            [self createBottomTipsWithPoint:CGPointZero Prices:nil];
            [self updateTipsWithModel:_model.prices.lastObject];
        }
    }
}

//  点击
-(void)tapHandle:(UITapGestureRecognizer*)tap{
//    if (tap.state == UIGestureRecognizerStateEnded) {
//        __FMWeakSelf;
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            // 需要停留等待数据进来
//            [NSThread sleepForTimeInterval:2];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                // 回到主线程更新界面
//                if (tap.state == UIGestureRecognizerStatePossible) {
//                    [__weakSelf removeCrossLine];
//                    [__weakSelf updateWithModel:_model];
//                }
//            });
//        });
//    }
    
    // 如果没有显示十字线就传送代理,如果正在显示十字线，那么此次点击就仅仅删除十字线
    if (!_vTip) {
        // 传送代理
        if ([self.delegate respondsToSelector:@selector(FMBaseViewSingleClickAction:)]) {
            [self.delegate FMBaseViewSingleClickAction:self];
        }
        if ([tap locationInView:self].y>self.model.stage.topHeight) {
            if ([self.delegate respondsToSelector:@selector(FMBaseViewSingleClickBottomViewAction:)]) {
                [self.delegate FMBaseViewSingleClickBottomViewAction:self];
            }
        }
    }else{
        
        [self removeCrossLine];
        // 底部成交量显示
        if (_model.type==FMStockType_MinuteChart) {
            [self createBottomTipsWithPoint:CGPointZero Prices:nil];
            [self updateTipsWithModel:_model.prices.lastObject];
        }
        
    }
}

//  移除十字线
-(void)removeCrossLine{
    [_hLine removeFromSuperview];
    [_hTip removeFromSuperview];
    [_vLine removeFromSuperview];
    [_vTip removeFromSuperview];
    [_topTips removeFromSuperview];
    [_bottomTips removeFromSuperview];
    [_dateTips removeFromSuperview];
    [_tipViews removeFromSuperview];
    _tipViews = nil;
    _dateTips = nil;
    _hLine = nil;
    _hTip = nil;
    _vLine = nil;
    _vTip = nil;
    _topTips = nil;
    _bottomTips = nil;
    
    _model.isPressing = NO;
    
    //  代理
    NSArray *points = _model.points.firstObject;
    
    if ([self.delegate respondsToSelector:@selector(FMBaseViewMovingFinger:model:isHide:)]) {
        [self.delegate FMBaseViewMovingFinger:self model:points.lastObject isHide:YES];
    }
 
}

//  判断并在十字线上显示提示信息
-(void)createCrossLineWithTouchPoint:(CGPoint)point{
    if (_model.points.count<=0) {
        return;
    }
    CGFloat itemPointX = 0;
    CGPoint itemPoint; // 当前位置
    NSArray *items; // 当前k线数据
    NSArray *points = _model.points;
    for (NSArray *item in points) {
        itemPoint = CGPointFromString([item firstObject]);  // 收盘价的坐标
        itemPointX = itemPoint.x;
        int itemX = (int)itemPointX;
        int pointX = (int)point.x;
        if (itemX==pointX || (point.x-itemX<=(_model.klineWidth+_model.klinePadding) && point.x-itemX>0)) {
            items = item;
            break;
        }
    }
    if (items==nil) {
        return;
    }
    
    
    if (_model.type==FMStockType_MinuteChart || _model.type==FMStockType_FiveDaysChart) {
        [self createCrossLineWithPoint:itemPoint Price:[items lastObject]];
    }else{
        itemPoint = CGPointMake(itemPoint.x, point.y);
        [self createTipsWithPoint:itemPoint Prices:[items lastObject]];
        [self createCrossLineWithPoint:itemPoint Price:[items lastObject]];
        
    }
    
    
    //  代理
    if ([self.delegate respondsToSelector:@selector(FMBaseViewMovingFinger:model:)]) {
        [self.delegate FMBaseViewMovingFinger:self model:[items lastObject]];
    }
    if ([self.delegate respondsToSelector:@selector(FMBaseViewMovingFinger:model:isHide:)]) {
        [self.delegate FMBaseViewMovingFinger:self model:[items lastObject] isHide:NO];
    }
    
    items = nil;
    
    _tipViews.hidden = YES;
    
    
}
//  画十字线
-(void)createCrossLineWithPoint:(CGPoint)point Price:(FMStockDaysModel*)m{
    
    // 横线对应价格
    CGFloat price = CGFLOAT_MAX;
    if (point.y>=0 && point.y<=_model.stage.topHeight) {
        price = _model.maxPrice - ((point.y)/(_model.stage.topHeight)) * (_model.maxPrice - _model.minPrice);
        
        if (price>_model.maxPrice) {
            price = _model.maxPrice;
        }
        if (price<_model.minPrice) {
            price = _model.minPrice;
        }
    }
    
    if(point.y>=_model.stage.topHeight+_model.stage.padding.middle && point.y<=_model.stage.height){
        price = _model.bottomMinPrice + ((_model.stage.height-point.y)/(_model.stage.bottomHeight)) * (_model.bottomMaxPrice - _model.bottomMinPrice);
        
        if (price>_model.bottomMaxPrice) {
            price = _model.bottomMaxPrice;
        }
        if (price<_model.bottomMinPrice) {
            price = _model.bottomMinPrice;
        }
        if (_model.stockIndexBottomType==FMStockIndexType_VOL) {
            price = price / 1000000;
        }
    }
    
    if (point.y>_model.stage.height || point.y<0) {
        return;
    }
    
    
    if (!_hLine) {
        _hLine = [FMCommon drawLineWithSuperView:self Color:_model.klineGreyColor Location:0];
    }
    if (!_hTip) {
        _hTip = [[UILabel alloc] init];
        _hTip.font = _model.stage.font;
        _hTip.textColor = [UIColor whiteColor];
        _hTip.backgroundColor = _model.stage.fontColor;
        _hTip.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_hTip];
    }
    if (!_vLine) {
        _vLine = [FMCommon drawLineWithSuperView:self Color:_model.klineGreyColor Location:0];
        _vLine.frame = CGRectMake(0, 0, 0.5, _model.stage.height);
    }
    if (!_vTip) {
        _vTip = [[UILabel alloc] init];
        _vTip.font = _model.stage.font;
        _vTip.textColor = [UIColor whiteColor];
        _vTip.backgroundColor = _model.stage.fontColor;
        _vTip.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_vTip];
    }
    
    _hLine.hidden = NO;
    _hTip.hidden = NO;
    if (price==CGFLOAT_MAX) {
        _hLine.hidden = YES;
        _hTip.hidden = YES;
    }
    
    _hLine.frame = CGRectMake(0, point.y, _model.stage.width, _hLine.frame.size.height);
    _vLine.frame = CGRectMake(point.x-_model.klineWidth/2, 0, _vLine.frame.size.width, _model.stage.height);
    
    CGFloat x = 0;
    _hTip.text = [NSString stringWithFormat:@" %.2f",price];
    [_hTip sizeToFit];
    if (point.x<_model.stage.width/2) {
        x = _model.stage.width-_hTip.frame.size.width;
    }
    _hTip.frame = CGRectMake(x, point.y-_hTip.frame.size.height/2, _hTip.frame.size.width+2, _hTip.frame.size.height+2);
    
    if (_model.type==FMStockType_MinuteChart) {
        _vTip.text = m.datetime;
        [_vTip sizeToFit];
        x = point.x-_vTip.frame.size.width/2-_model.klineWidth/2-1;
        if (x+_vTip.frame.size.width>_model.stage.width) {
            x = _model.stage.width-_vTip.frame.size.width;
        }
        if (x<0) {
            x = 0;
        }
        _vTip.frame = CGRectMake(x, _model.stage.topHeight, _vTip.frame.size.width+2, _vTip.frame.size.height+2);
    }
    
    [self pressedCreateTipViews:m];
    [self bringSubviewToFront:_hTip];
    [self bringSubviewToFront:_vTip];
}

//  主视图一些指标显示
-(void)createTipsWithPoint:(CGPoint)point Prices:(FMStockDaysModel*)m{
    if (_topTips) {
        [_topTips removeFromSuperview];
        _topTips = nil;
    }
    if (_dateTips) {
        [_dateTips removeFromSuperview];
        _dateTips = nil;
    }
    CGFloat x = 0;
    _topTips = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 15)];
    _topTips.backgroundColor = [UIColor clearColor];
    [self addSubview:_topTips];
    UIView *box = [[UIView alloc] initWithFrame:_topTips.bounds];
    box.backgroundColor = [UIColor whiteColor];
    box.alpha = 0.8;
    [_topTips addSubview:box];
    [self updateTipsWithModel:m];
    UIView *last = [_topTips.subviews lastObject];
    box.frame = CGRectMake(0, 0, last.frame.size.width+last.frame.origin.x, box.frame.size.height);
    if (point.x<_model.stage.width/2) {
        x = _model.stage.width-box.frame.size.width;
    }
    _topTips.frame = CGRectMake(x, 1, box.frame.size.width, box.frame.size.height);
    box = nil;
    last = nil;
    
    _dateTips = [[UILabel alloc] init];
    _dateTips.font = _model.stage.font;
    _dateTips.textColor = [UIColor whiteColor];
    NSString *firstTime = m.datetime;
    NSString *time = firstTime;
    if (firstTime.length>=8) {
        NSString *year = [firstTime substringToIndex:4];
        NSString *month = [firstTime substringWithRange:NSMakeRange(4, 2)];
        NSString *day = [firstTime substringWithRange:NSMakeRange(6, 2)];
        // 显示日期
        time = [NSString stringWithFormat:@"%@-%@-%@",year,month,day];
        if (_model.type == FMStockType_DaysChart) {
            time = [NSString stringWithFormat:@"%@-%@-%@",year,month,day];
        }
        if (_model.type == FMStockType_WeekChart) {
            time = [NSString stringWithFormat:@"%@-%@-%@",year,month,day];
        }
        if (_model.type == FMStockType_MonthChart) {
            time = [NSString stringWithFormat:@"%@-%@",year,month];
        }
    }
    if (firstTime.length>=12) {
        NSString *year = [firstTime substringToIndex:4];
        NSString *month = [firstTime substringWithRange:NSMakeRange(4, 2)];
        NSString *day = [firstTime substringWithRange:NSMakeRange(6, 2)];
        NSString *hour = [firstTime substringWithRange:NSMakeRange(8, 2)];
        NSString *minute = [firstTime substringWithRange:NSMakeRange(10, 2)];
        
        // 显示时间
        time = [NSString stringWithFormat:@"%@-%@ %@:%@",month,day,hour,minute];
        if (_model.type == FMStockType_1MinuteChart) {
//            time = [NSString stringWithFormat:@"%@:%@",hour,minute];
        }
    }
    
    _dateTips.text = time;
    _dateTips.textAlignment = NSTextAlignmentCenter;
    [_dateTips sizeToFit];
    x = point.x-_dateTips.frame.size.width/2-_model.klineWidth/2-1;
    if (x+_dateTips.frame.size.width>_model.stage.width) {
        x = _model.stage.width-_dateTips.frame.size.width;
    }
    if (x<0) {
        x = 0;
    }
    _dateTips.frame = CGRectMake(x, _model.stage.topHeight, _dateTips.frame.size.width+2, _dateTips.frame.size.height+2);
    _dateTips.backgroundColor = _model.stage.fontColor;
    [self addSubview:_dateTips];
    
    [self createBottomTipsWithPoint:point Prices:m];
}

//  幅图一些指标显示
-(void)createBottomTipsWithPoint:(CGPoint)point Prices:(FMStockDaysModel*)m{
    if (_bottomTips) {
        [_bottomTips removeFromSuperview];
        _bottomTips = nil;
    }
    CGFloat x = 0;
    
    _bottomTips = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, _model.stage.tipFont.pointSize)];
    _bottomTips.backgroundColor = [UIColor clearColor];
    [self addSubview:_bottomTips];
    UIView *box = [[UIView alloc] initWithFrame:_bottomTips.bounds];
    box.backgroundColor = [UIColor whiteColor];
    box.alpha = 0.8;
    [_bottomTips addSubview:box];
    [self updateTipsWithModel:m];
    
    UIView *last = [_bottomTips.subviews lastObject];
    box.frame = CGRectMake(0, 0, last.frame.size.width+last.frame.origin.x, box.frame.size.height);
    if (point.x<_model.stage.width/2) {
        x = _model.stage.width-box.frame.size.width;
    }
    CGFloat w = box.frame.size.width;
    CGFloat h = box.frame.size.height;
    
    x = 0;
    w = self.frame.size.width;
    h = _model.stage.padding.middle;
    
    // 如果是分时图，就固定在左边
    if (_model.type==FMStockType_MinuteChart) {
        x = 0;
        w = self.frame.size.width;
        h = _model.stage.padding.middle;
    
    }
    
    _bottomTips.frame = CGRectMake(x, _model.stage.topHeight+_model.stage.padding.middle, w, h);
    box = nil;
    last = nil;
}

// 手指按压总览视图
-(void)pressedCreateTipViews:(id)m{
    if (!_tipViews) {
        _tipViews = [[UIView alloc] initWithFrame:CGRectMake(0, -fmFMBaseTipViewsHeight+0.5, _model.stage.width, fmFMBaseTipViewsHeight)];
        _tipViews.backgroundColor = [UIColor whiteColor];
        _tipViews.layer.borderColor = _model.stage.lineColor.CGColor;
        _tipViews.layer.borderWidth = _model.stage.lineWidth;
        [self addSubview:_tipViews];
    }
    for (UIView *item in _tipViews.subviews) {
        [item removeFromSuperview];
    }
    
    if (_model.type==FMStockType_MinuteChart) {
        // 13:20 价格12:34 涨幅+0.4% 成交2.4万手 均价12:1
        FMStockMinuteModel *min = (FMStockMinuteModel*)m;
        NSString *price = [NSString stringWithFormat:@"%.2f",[min.price floatValue]];
        NSString *changeRate = [NSString stringWithFormat:@"%.2f%%",[min.changeRate floatValue]];
        NSString *volumn = [NSString stringWithFormat:@"%.f手",[min.volumn floatValue]/100];
        NSString *average = [NSString stringWithFormat:@"%.2f",[min.averagePrice floatValue]];
        UIColor *color = _model.klineUpColor;
        if ([changeRate floatValue]<0) {
            color = _model.klineDownColor;
        }
        CGPoint point = CGPointMake(3, 3);
        CGSize size = [self createLableWithSize:_model.stage.font.pointSize
                                          Color:_model.stage.fontColor
                                          Point:point
                                           Text:min.datetime
                                      SuperView:_tipViews
                                            Tag:-1];
        point = CGPointMake(size.width+10, point.y);
        size = [self createLableWithSize:_model.stage.font.pointSize
                                   Color:_model.stage.fontColor
                                   Point:point
                                    Text:@"价格"
                               SuperView:_tipViews
                                     Tag:-1];
        
        point = CGPointMake(size.width, point.y);
        size = [self createLableWithSize:_model.stage.font.pointSize
                                   Color:color
                                   Point:point
                                    Text:price
                               SuperView:_tipViews
                                     Tag:-1];
        point = CGPointMake(size.width+10, point.y);
        size = [self createLableWithSize:_model.stage.font.pointSize
                                   Color:_model.stage.fontColor
                                   Point:point
                                    Text:@"涨幅"
                               SuperView:_tipViews
                                     Tag:-1];
        point = CGPointMake(size.width, point.y);
        size = [self createLableWithSize:_model.stage.font.pointSize
                                   Color:color
                                   Point:point
                                    Text:changeRate
                               SuperView:_tipViews
                                     Tag:-1];
        point = CGPointMake(size.width+10, point.y);
        size = [self createLableWithSize:_model.stage.font.pointSize
                                   Color:_model.stage.fontColor
                                   Point:point
                                    Text:@"成交"
                               SuperView:_tipViews
                                     Tag:-1];
        point = CGPointMake(size.width, point.y);
        size = [self createLableWithSize:_model.stage.font.pointSize
                                   Color:_model.stage.fontColor
                                   Point:point
                                    Text:volumn
                               SuperView:_tipViews
                                     Tag:-1];
        color = _model.klineUpColor;
        if ([average floatValue]<0) {
            color = _model.klineDownColor;
        }
        point = CGPointMake(size.width+10, point.y);
        size = [self createLableWithSize:_model.stage.font.pointSize
                                   Color:_model.stage.fontColor
                                   Point:point
                                    Text:@"均价"
                               SuperView:_tipViews
                                     Tag:-1];
        point = CGPointMake(size.width, point.y);
        size = [self createLableWithSize:_model.stage.font.pointSize
                                   Color:color
                                   Point:point
                                    Text:average
                               SuperView:_tipViews
                                     Tag:-1];
    
    }
    if (_model.type!=FMStockType_MinuteChart && _model.type!=FMStockType_FiveDaysChart) {
        // 10-20 开12:34 高15:32 低11.43 收12:1 涨幅+3.9%
        FMStockDaysModel *min = (FMStockDaysModel*)m;
        NSString *openPrice = [NSString stringWithFormat:@"%.2f",[min.openPrice floatValue]];
        NSString *heightPrice = [NSString stringWithFormat:@"%.2f",[min.heightPrice floatValue]];
        NSString *lowPrice = [NSString stringWithFormat:@"%.2f",[min.lowPrice floatValue]];
        NSString *closePrice = [NSString stringWithFormat:@"%.2f",[min.closePrice floatValue]];
        NSString *changeRate = [NSString stringWithFormat:@"%.2f%%",([min.closePrice floatValue]-[min.yestodayClosePrice floatValue]) / [min.yestodayClosePrice floatValue]*100];
        float yestodayClose = [min.yestodayClosePrice floatValue];
        UIColor *color = _model.klineUpColor;
        if ([openPrice floatValue]<yestodayClose) {
            color = _model.klineDownColor;
        }
        CGPoint point = CGPointMake(3, 3);
        CGSize size = [self createLableWithSize:_model.stage.font.pointSize
                                          Color:_model.stage.fontColor
                                          Point:point
                                           Text:min.datetime
                                      SuperView:_tipViews
                                            Tag:-1];
        point = CGPointMake(size.width+10, point.y);
        size = [self createLableWithSize:_model.stage.font.pointSize
                                   Color:_model.stage.fontColor
                                   Point:point
                                    Text:@"开"
                               SuperView:_tipViews
                                     Tag:-1];
        
        point = CGPointMake(size.width, point.y);
        size = [self createLableWithSize:_model.stage.font.pointSize
                                   Color:color
                                   Point:point
                                    Text:openPrice
                               SuperView:_tipViews
                                     Tag:-1];
        color = _model.klineUpColor;
        if ([heightPrice floatValue]<yestodayClose) {
            color = _model.klineDownColor;
        }
        point = CGPointMake(size.width+10, point.y);
        size = [self createLableWithSize:_model.stage.font.pointSize
                                   Color:_model.stage.fontColor
                                   Point:point
                                    Text:@"高"
                               SuperView:_tipViews
                                     Tag:-1];
        point = CGPointMake(size.width, point.y);
        size = [self createLableWithSize:_model.stage.font.pointSize
                                   Color:color
                                   Point:point
                                    Text:heightPrice
                               SuperView:_tipViews
                                     Tag:-1];
        color = _model.klineUpColor;
        if ([lowPrice floatValue]<yestodayClose) {
            color = _model.klineDownColor;
        }
        point = CGPointMake(size.width+10, point.y);
        size = [self createLableWithSize:_model.stage.font.pointSize
                                   Color:_model.stage.fontColor
                                   Point:point
                                    Text:@"低"
                               SuperView:_tipViews
                                     Tag:-1];
        point = CGPointMake(size.width, point.y);
        size = [self createLableWithSize:_model.stage.font.pointSize
                                   Color:color
                                   Point:point
                                    Text:lowPrice
                               SuperView:_tipViews
                                     Tag:-1];
        color = _model.klineUpColor;
        if ([closePrice floatValue]<yestodayClose) {
            color = _model.klineDownColor;
        }
        point = CGPointMake(size.width+10, point.y);
        size = [self createLableWithSize:_model.stage.font.pointSize
                                   Color:_model.stage.fontColor
                                   Point:point
                                    Text:@"收"
                               SuperView:_tipViews
                                     Tag:-1];
        point = CGPointMake(size.width, point.y);
        size = [self createLableWithSize:_model.stage.font.pointSize
                                   Color:color
                                   Point:point
                                    Text:closePrice
                               SuperView:_tipViews
                                     Tag:-1];
        color = _model.klineUpColor;
        if ([changeRate floatValue]<0) {
            color = _model.klineDownColor;
        }
        point = CGPointMake(size.width+10, point.y);
        size = [self createLableWithSize:_model.stage.font.pointSize
                                   Color:_model.stage.fontColor
                                   Point:point
                                    Text:@"涨幅"
                               SuperView:_tipViews
                                     Tag:-1];
        point = CGPointMake(size.width, point.y);
        size = [self createLableWithSize:_model.stage.font.pointSize
                                   Color:color
                                   Point:point
                                    Text:changeRate
                               SuperView:_tipViews
                                     Tag:-1];
        
    }
    
    UILabel *last = _tipViews.subviews.lastObject;
    float w = last.frame.origin.x+last.frame.size.width+6;
    float x = _vLine.frame.origin.x - w/2;
    
    if (x>=_model.stage.width - w) {
        x = _model.stage.width - w;
    }
    
    if (x<=0) {
        x = 0;
    }
    
    _tipViews.frame = CGRectMake(x, _tipViews.frame.origin.y, w, _tipViews.frame.size.height);
}

#pragma mark -
#pragma mark 指标视图
-(void)updateTipsWithModel:(FMStockDaysModel*)m{
    if (_model.type!=FMStockType_MinuteChart) {
        // 判断主图指标类型并更新显示提示
        // 判断主图指标类型并更新显示提示
        if (_model.stockIndexType==FMStockIndexType_SMA) {
            [self createSMATipWithModel:m];
        }
        if (_model.stockIndexType==FMStockIndexType_EMA) {
            [self createEMATipWithModel:m];
        }
        if (_model.stockIndexType==FMStockIndexType_BOLL) {
            [self createBOLLTipWithModel:m];
        }
        // 判断幅图指标类型并更新显示提示
        if (_model.stockIndexBottomType==FMStockIndexType_MACD) {
            [self createMACDTipWithModel:m];
        }
        if (_model.stockIndexBottomType==FMStockIndexType_KDJ) {
            [self createKDJTipWithModel:m];
        }
        if (_model.stockIndexBottomType==FMStockIndexType_RSI) {
            [self createRSITipWithModel:m];
        }
        if (_model.stockIndexBottomType==FMStockIndexType_VOL) {
            [self createVolumnTipWithModel:m];
        }
        if (_model.stockIndexBottomType==FMStockIndexType_OBV) {
            [self createOBVTipWithModel:m];
        }
        if (_model.stockIndexBottomType==FMStockIndexType_DMI) {
            [self createDMITipWithModel:m];
        }
        
    }else{
        [self createVolumnTipWithModel:m];
    }
    
}
#pragma mark 指标视图
-(void)createSMATipWithModel:(FMStockDaysModel*)m{
    NSString *SMA5 = @"SMA5=0.00";
    NSString *SMA10 = @"SMA10=0.00";
    NSString *SMA20 = @"SMA20=0.00";
    if (m) {
        SMA5 = [NSString stringWithFormat:@"SMA5=%.2f",[m.MA5 floatValue]];
        SMA10 = [NSString stringWithFormat:@"SMA10=%.2f",[m.MA10 floatValue]];
        SMA20 = [NSString stringWithFormat:@"SMA20=%.2f",[m.MA20 floatValue]];
        CGSize size = [self createLableWithSize:_model.stage.tipFont.pointSize
                                          Color:_model.klineMAN1Color
                                          Point:CGPointMake(0, 0)
                                           Text:SMA5
                                      SuperView:_topTips
                                            Tag:1001];
        size = [self createLableWithSize:_model.stage.tipFont.pointSize
                                   Color:_model.klineMAN2Color
                                   Point:CGPointMake(size.width+5, 0)
                                    Text:SMA10
                               SuperView:_topTips
                                     Tag:1002];
        size = [self createLableWithSize:_model.stage.tipFont.pointSize
                                   Color:_model.klineMAN3Color
                                   Point:CGPointMake(size.width+5, 0)
                                    Text:SMA20
                               SuperView:_topTips
                                     Tag:1003];
    }
    
}

-(void)createEMATipWithModel:(FMStockDaysModel*)m{
    NSString *EMA20 = @"EMA20=0.00";
    if (m) {
        EMA20 = [NSString stringWithFormat:@"EMA20=%.2f",[m.EMA floatValue]];
        [self createLableWithSize:_model.stage.tipFont.pointSize
                            Color:_model.klineEMAColor
                            Point:CGPointMake(0, 0)
                             Text:EMA20
                        SuperView:_topTips
                              Tag:1004];
    }
    
}
-(void)createBOLLTipWithModel:(FMStockDaysModel*)m{
    NSString *Boll = [NSString stringWithFormat:@"BOLL(%@,%@)",[MKUserDefault getSeting:fmFMUserDefault_BOLL_N],[MKUserDefault getSeting:fmFMUserDefault_BOLL_K]];
    if (m) {
        Boll = [NSString stringWithFormat:@"BOLL(%.2f,%.2f,%.2f)",[m.BOLL_UP floatValue],[m.BOLL_MIDDLE floatValue],[m.BOLL_DOWN floatValue]];
   
        [self createLableWithSize:_model.stage.tipFont.pointSize
                            Color:_model.stage.fontColor
                            Point:CGPointMake(0, 0)
                             Text:Boll
                        SuperView:_topTips
                              Tag:1005];
    }
    
}
-(void)createMACDTipWithModel:(FMStockDaysModel*)m{
    NSString *MACD = [NSString stringWithFormat:@"MACD(%@,%@,%@)",[MKUserDefault getSeting:fmFMUserDefault_MACD_P],[MKUserDefault getSeting:fmFMUserDefault_MACD_N1],[MKUserDefault getSeting:fmFMUserDefault_MACD_N2]];
    NSString *DIF = @"DIF=0.00";
    NSString *DEA = @"DEA=0.00";
    NSString *M = @"MACD=0.00";
    UIColor *color = _model.klineDownColor;
    if (m) {
        DIF = [NSString stringWithFormat:@"DIF=%.2f",[m.MACD_DIF floatValue]];
        DEA = [NSString stringWithFormat:@"DEA=%.2f",[m.MACD_DEA floatValue]];
        M = [NSString stringWithFormat:@"MACD=%.2f",[m.MACD_M floatValue]];
        if ([m.MACD_M floatValue]>0) {
            color = _model.klineUpColor;
        }
        CGSize size = [self createLableWithSize:_model.stage.tipFont.pointSize
                                          Color:_model.stage.fontColor
                                          Point:CGPointMake(0, 0)
                                           Text:MACD
                                      SuperView:_bottomTips
                                            Tag:1006];
        size = [self createLableWithSize:_model.stage.tipFont.pointSize
                                   Color:_model.klineMACDDIFColor
                                   Point:CGPointMake(size.width+5, 0)
                                    Text:DIF
                               SuperView:_bottomTips
                                     Tag:1007];
        size = [self createLableWithSize:_model.stage.tipFont.pointSize
                                   Color:_model.klineMACDDEAColor
                                   Point:CGPointMake(size.width+5, 0)
                                    Text:DEA
                               SuperView:_bottomTips
                                     Tag:1008];
        size = [self createLableWithSize:_model.stage.tipFont.pointSize
                                   Color:color
                                   Point:CGPointMake(size.width+5, 0)
                                    Text:M
                               SuperView:_bottomTips
                                     Tag:1009];
    }
    
}
-(void)createKDJTipWithModel:(FMStockDaysModel*)m{
    NSString *KDJ = @"KDJ(9,3,3)";
    NSString *K = [NSString stringWithFormat:@"K:0.00"];
    NSString *D = [NSString stringWithFormat:@"D:0.00"];
    NSString *J = [NSString stringWithFormat:@"J:0.00"];
    if (m) {
        K = [NSString stringWithFormat:@"K:%.2f",[m.KDJ_K floatValue]];
        D = [NSString stringWithFormat:@"D:%.2f",[m.KDJ_D floatValue]];
        J = [NSString stringWithFormat:@"J:%.2f",[m.KDJ_J floatValue]];
        CGSize size = [self createLableWithSize:_model.stage.tipFont.pointSize
                                          Color:_model.stage.fontColor
                                          Point:CGPointMake(0, 0)
                                           Text:KDJ
                                      SuperView:_bottomTips
                                            Tag:1020];
        size = [self createLableWithSize:_model.stage.tipFont.pointSize
                                   Color:_model.klineKDJKColor
                                   Point:CGPointMake(size.width+5, 0)
                                    Text:K
                               SuperView:_bottomTips
                                     Tag:1021];
        size = [self createLableWithSize:_model.stage.tipFont.pointSize
                                   Color:_model.klineKDJDColor
                                   Point:CGPointMake(size.width+5, 0)
                                    Text:D
                               SuperView:_bottomTips
                                     Tag:1022];
        size = [self createLableWithSize:_model.stage.tipFont.pointSize
                                   Color:_model.klineKDJJColor
                                   Point:CGPointMake(size.width+5, 0)
                                    Text:J
                               SuperView:_bottomTips
                                     Tag:10222];
    }
    
    
}
-(void)createRSITipWithModel:(FMStockDaysModel*)m{
    NSString *RSI = [NSString stringWithFormat:@"RSI(%@,%@,%@)",[MKUserDefault getSeting:fmFMUserDefault_RSI_N1],[MKUserDefault getSeting:fmFMUserDefault_RSI_N2],[MKUserDefault getSeting:fmFMUserDefault_RSI_N3]];
    NSString *N1 = [NSString stringWithFormat:@"RSI%@:0.00",[MKUserDefault getSeting:fmFMUserDefault_RSI_N1]];
    NSString *N2 = [NSString stringWithFormat:@"RSI%@:0.00",[MKUserDefault getSeting:fmFMUserDefault_RSI_N2]];
    NSString *N3 = [NSString stringWithFormat:@"RSI%@:0.00",[MKUserDefault getSeting:fmFMUserDefault_RSI_N3]];
    
    if (m) {
        N1 = [NSString stringWithFormat:@"RSI%@:%.2f",[MKUserDefault getSeting:fmFMUserDefault_RSI_N1],[m.RSI_1 floatValue]];
        N2 = [NSString stringWithFormat:@"RSI%@:%.2f",[MKUserDefault getSeting:fmFMUserDefault_RSI_N2],[m.RSI_2 floatValue]];
        N3 = [NSString stringWithFormat:@"RSI%@:%.2f",[MKUserDefault getSeting:fmFMUserDefault_RSI_N3],[m.RSI_3 floatValue]];
        CGSize size = [self createLableWithSize:_model.stage.tipFont.pointSize
                                          Color:_model.stage.fontColor
                                          Point:CGPointMake(0, 0)
                                           Text:RSI
                                      SuperView:_bottomTips
                                            Tag:1010];
        size = [self createLableWithSize:_model.stage.tipFont.pointSize
                                   Color:_model.klineRSIN1Color
                                   Point:CGPointMake(size.width+5, 0)
                                    Text:N1
                               SuperView:_bottomTips
                                     Tag:1011];
        size = [self createLableWithSize:_model.stage.tipFont.pointSize
                                   Color:_model.klineRSIN2Color
                                   Point:CGPointMake(size.width+5, 0)
                                    Text:N2
                               SuperView:_bottomTips
                                     Tag:1012];
        size = [self createLableWithSize:_model.stage.tipFont.pointSize
                                   Color:_model.klineRSIN3Color
                                   Point:CGPointMake(size.width+5, 0)
                                    Text:N3
                               SuperView:_bottomTips
                                     Tag:1013];
    }
    
}



/**
 *  分时图成交量显示
 *
 *  @param m 分时模型
 */
-(void)createVolumnTipWithModel:(FMStockDaysModel*)m{
    // 如果没有底部提示视图，得创建一遍
    //[self createBottomTipsWithPoint:CGPointMake(0, 0) Prices:m];
    if (_model.type==FMStockType_MinuteChart) {
        float lastVolumn = 0;
        for (FMStockMinuteModel *item in _model.prices) {
            if ([item.volumn floatValue]>lastVolumn) {
                m = item;
                lastVolumn = [item.volumn floatValue];
            }
        }
    }
    
    
    
//    FMLog(@"%@",_bottomTips);
    NSString *title = @"VOL";
    NSString *volume = @"量: ";
    NSString *volumePrice = @"额: ";
    float x = 0;
    if (m) {
        
        if ([[m class] isSubclassOfClass:[FMStockDaysModel class]]) {
            FMStockDaysModel *nm = (FMStockDaysModel*)m;
            title = [NSString stringWithFormat:@"VOL(%.f,%.f,%.f)",[MKUserDefault getVOL_N1],[MKUserDefault getVOL_N2],[MKUserDefault getVOL_N3]];
            volume = [NSString stringWithFormat:@" %@手",[FMCommon moneyWithPrice:[NSString stringWithFormat:@"%.f",[nm.volumn floatValue]]]];
            volumePrice = [NSString stringWithFormat:@"额: %@",[FMCommon moneyWithPrice:nm.volPrice]];
        }else{
            title = @"";
            FMStockMinuteModel *nm = (FMStockMinuteModel*)m;
            volume = [NSString stringWithFormat:@"%@",[FMCommon moneyWithPrice:[NSString stringWithFormat:@"%.f",[nm.volumn floatValue]/100]]];
            x = self.model.stage.width - [volume sizeWithFont:_model.stage.tipFont constrainedToSize:CGSizeMake(MAXFLOAT, _model.stage.tipFont.pointSize)].width-5;
            x = -5;
//            volumePrice = [NSString stringWithFormat:@"额: %@",[FMCommon moneyWithPrice:nm.volumnPrice]];
            volumePrice = @"";
            
        }
        

        // 量
        CGSize size = [self createLableWithSize:_model.stage.tipFont.pointSize
                                          Color:_model.stage.fontColor
                                          Point:CGPointMake(x, 0)
                                           Text:title
                                      SuperView:_bottomTips
                                            Tag:10041];
        size = [self createLableWithSize:_model.stage.tipFont.pointSize
                                          Color:_model.stage.fontColor
                                          Point:CGPointMake(size.width+5, 0)
                                           Text:volume
                                      SuperView:_bottomTips
                                            Tag:10042];
        size = [self createLableWithSize:_model.stage.tipFont.pointSize
                                   Color:_model.stage.fontColor
                                   Point:CGPointMake(size.width+5, 0)
                                    Text:volumePrice
                               SuperView:_bottomTips
                                     Tag:10043];
        
        if ([[m class] isSubclassOfClass:[FMStockDaysModel class]]) {
            NSString *vol_n1 = [NSString stringWithFormat:@"%@手",[FMCommon moneyWithPrice:[NSString stringWithFormat:@"%.f",[m.volMA_N1 floatValue]]]];
            NSString *vol_n2 = [NSString stringWithFormat:@"%@手",[FMCommon moneyWithPrice:[NSString stringWithFormat:@"%.f",[m.volMA_N2 floatValue]]]];
            NSString *vol_n3 = [NSString stringWithFormat:@"%@手",[FMCommon moneyWithPrice:[NSString stringWithFormat:@"%.f",[m.volMA_N3 floatValue]]]];
            size = [self createLableWithSize:_model.stage.tipFont.pointSize
                                       Color:_model.klineVOLN1Color
                                       Point:CGPointMake(size.width+5, 0)
                                        Text:vol_n1
                                   SuperView:_bottomTips
                                         Tag:10044];
            size = [self createLableWithSize:_model.stage.tipFont.pointSize
                                       Color:_model.klineVOLN2Color
                                       Point:CGPointMake(size.width+5, 0)
                                        Text:vol_n2
                                   SuperView:_bottomTips
                                         Tag:10045];
            size = [self createLableWithSize:_model.stage.tipFont.pointSize
                                       Color:_model.klineVOLN3Color
                                       Point:CGPointMake(size.width+5, 0)
                                        Text:vol_n3
                                   SuperView:_bottomTips
                                         Tag:10046];
        }
        
    }
    
}

-(void)createDMITipWithModel:(FMStockDaysModel*)m{
    NSString *RSI = [NSString stringWithFormat:@"DMI(%@,%@)",[MKUserDefault getSeting:fmFMUserDefault_DMI_N],[MKUserDefault getSeting:fmFMUserDefault_DMI_M]];
    
    
    if (m) {
        NSString *PDI = [NSString stringWithFormat:@"PDI:%.2f",[m.DMI_PDI floatValue]];
        NSString *MDI = [NSString stringWithFormat:@"MDI:%.2f",[m.DMI_MDI floatValue]];
        NSString *ADX = [NSString stringWithFormat:@"ADX:%.2f",[m.DMI_ADX floatValue]];
        NSString *ADXR = [NSString stringWithFormat:@"ADXR:%.2f",[m.DMI_ADXR floatValue]];
        CGSize size = [self createLableWithSize:_model.stage.tipFont.pointSize
                                          Color:_model.stage.fontColor
                                          Point:CGPointMake(0, 0)
                                           Text:RSI
                                      SuperView:_bottomTips
                                            Tag:10101];
        size = [self createLableWithSize:_model.stage.tipFont.pointSize
                                   Color:_model.klineDMIPDIColor
                                   Point:CGPointMake(size.width+5, 0)
                                    Text:PDI
                               SuperView:_bottomTips
                                     Tag:10111];
        size = [self createLableWithSize:_model.stage.tipFont.pointSize
                                   Color:_model.klineRSIN2Color
                                   Point:CGPointMake(size.width+5, 0)
                                    Text:MDI
                               SuperView:_bottomTips
                                     Tag:10121];
        size = [self createLableWithSize:_model.stage.tipFont.pointSize
                                   Color:_model.klineDMIADXColor
                                   Point:CGPointMake(size.width+5, 0)
                                    Text:ADX
                               SuperView:_bottomTips
                                     Tag:10131];
        size = [self createLableWithSize:_model.stage.tipFont.pointSize
                                   Color:_model.klineDMIADXRColor
                                   Point:CGPointMake(size.width+5, 0)
                                    Text:ADXR
                               SuperView:_bottomTips
                                     Tag:10141];
    }
    
}

-(void)createOBVTipWithModel:(FMStockDaysModel*)m{
    //NSString *OBV = [NSString stringWithFormat:@"OBV"];
    NSString *N1 = [NSString stringWithFormat:@"OBV(%.f):0.00",[MKUserDefault getOBV_N1]];
    
    
    if (m) {
        N1 = [NSString stringWithFormat:@"OBV(%.f):%.2f",[MKUserDefault getOBV_N1],[m.OBV_N1 floatValue]];
        
        CGSize size = [self createLableWithSize:_model.stage.tipFont.pointSize
                                          Color:_model.klineOBVColor
                                          Point:CGPointMake(0, 0)
                                           Text:N1
                                      SuperView:_bottomTips
                                            Tag:10101];
        
    }
    
}

-(CGSize)createLableWithSize:(CGFloat)size Color:(UIColor*)color Point:(CGPoint)point Text:(NSString*)text SuperView:(UIView *)view Tag:(NSInteger)tag{
    
    UILabel *l;
    if (tag>=0) {
        l = (UILabel*)[view viewWithTag:tag];
    }
    if (!l) {
        l = [[UILabel alloc] init];
        [view addSubview:l];
    }
    if (tag>=0) l.tag = tag;
    l.text = text;
    l.textColor = color;
    l.font = _model.stage.tipFont;
    l.frame = CGRectMake(point.x, point.y, self.frame.size.width, 0);
    [l sizeToFit];
    CGSize sizes = CGSizeMake(l.frame.size.width+l.frame.origin.x, l.frame.size.height);
    l = nil;
    return sizes;
    
}
@end
