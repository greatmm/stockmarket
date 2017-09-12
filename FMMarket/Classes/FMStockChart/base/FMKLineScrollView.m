//
//  FMKLineScrollView.m
//  FMStockChart
//
//  Created by dangfm on 15/8/21.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMKLineScrollView.h"
#import "FMBaseView.h"
#import "FMStockModel.h"
#import "FMHeader.h"
#import "FMStockMaxMinValues.h"
#import "FMStockDaysModel.h"
#import "FMStockMaxMinValues.h"
#import "FMStockMinuteModel.h"
#import "FMStockIndexAlgorithm.h"
#import "MKUserDefault.h"

//把角度转换为弧度的计算公式
static inline float radians(double degrees) { return degrees * M_PI / 180; }

@interface FMKLineScrollView(){
    BOOL _first_SMA_N1;
    BOOL _first_SMA_N2;
    BOOL _first_SMA_N3;
    BOOL _first_SMA_N4;
    BOOL _first_SMA_N5;
    BOOL _first_SMA_N6;
    BOOL _first_EMA;
    BOOL _first_EMA_S;
    BOOL _first_BOLL_DOWN;
    BOOL _first_BOLL_MIDDLE;
    BOOL _first_BOLL_UP;
    BOOL _first_MACD_DIF;
    BOOL _first_MACD_DEA;
    BOOL _first_vol_MA_N1;        // 5日成交量
    BOOL _first_vol_MA_N2;        // 10日成交量
    BOOL _first_vol_MA_N3;        // 60日成交量
    
    BOOL _first_KDJ_K;
    BOOL _first_KDJ_D;
    BOOL _first_KDJ_J;
    BOOL _first_RSI_N1;
    BOOL _first_RSI_N2;
    BOOL _first_RSI_N3;
    BOOL _first_DMI_PDI;
    BOOL _first_DMI_MDI;
    BOOL _first_DMI_ADX;
    BOOL _first_DMI_ADXR;
    
    BOOL _first_OBV;
    
    BOOL _zoomingFinished;
    
    // 是否画过最高值提示了
    BOOL _isDrawHighTipView;
    // 是否画过最低值提示了
    BOOL _isDrawLowTipView;
    
    CGFloat _lastScale;
    NSString *_preMonth;
    NSInteger _preNumber;
    CGFloat _lastDateX;
    
}

@end

@implementation FMKLineScrollView

#pragma mark -
#pragma mark 重写

-(void)dealloc{
    NSLog(@"FMKLineScrollView dealloc");
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self==[super initWithFrame:frame]) {
        _zoomingFinished = YES;
        _preNumber = 1;
        // 尽可能将视图区域标识为不透明,  opaque设置为YES
        // 滚动过程中如果清除缓冲区，那么代价很大， 可以将clearsContextBeforeDrawing属性设置为NO.
        self.clearsContextBeforeDrawing = NO;
        self.opaque = YES;
    }
    return self;
}

//+(Class)layerClass{
//    return [CAShapeLayer class];
//}

//-(CALayer *)layer{
//   
//    if (!_shapeLayer) {
//        _shapeLayer = [CAShapeLayer layer];
//        _shapeLayer.shouldRasterize = YES;
//        _shapeLayer.masksToBounds = YES;
//        //_shapeLayer.backgroundColor = kFMColor(0xeeeeee).CGColor;
//    }
//    if ([[[UIDevice currentDevice] systemVersion ]floatValue]<8.0) {
//        _shapeLayer.bounds = CGRectMake(self.contentOffset.x, 0, self.model.stage.width,self.contentSize.height);
//    }
//    
//
//    //_shapeLayer.position = CGPointMake(0, 0);
//    //_shapeLayer.bounds = self.frame;
//    //FMLog(@"%@",NSStringFromCGRect(_shapeLayer.bounds));
//    return _shapeLayer;
//}

//-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx{
//    [self drawAllKLineWithContext:ctx Prices:self.model.subPrices];
//}

-(void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    //FMLog(@"drawRect:%@ max=%f",NSStringFromCGRect(rect),self.model.maxPrice);
    if (!_model) {
        return;
    }
    if (_model.type==FMStockType_MinuteChart) {
        [self drawMinuteLine:context Prices:_model.prices];
        return;
    }
    if (_model.type==FMStockType_FiveDaysChart) {
        [self drawMinuteLine:context Prices:_model.prices];
        return;
    }
    // 画日k周k月k
    [self drawAllKLineWithContext:context Prices:self.model.subPrices];
}

/**
 *  重写ScrollView放大缩小事件
 *
 *  @param pinch 缩放手势
 */
-(void)handlePinch:(UIPinchGestureRecognizer*)pinch{
    //NSLog(@"handlePinch:%lu",(unsigned long)pinch.numberOfTouches);
    _model.isZooming = YES;
    if (_model.type==FMStockType_MinuteChart) {
        return;
    }
    if (isnan(_model.klineWidth)) {
        return;
    }
    //当手指离开屏幕时,将lastscale设置为1.0
    if([(UIPinchGestureRecognizer*)pinch state] == UIGestureRecognizerStateEnded) {
        _model.isZooming = NO;
        // 计算偏移距离
        CGFloat w = (_model.klineWidth*_model.prices.count + _model.klinePadding*(_model.prices.count-1));
        CGFloat offsetStart = _model.offsetStart;
        CGFloat count = _model.prices.count;
        CGFloat start = offsetStart / count * 1.00;
        //NSLog(@"startIndex:%d",startIndex);
        CGFloat offsetWith = w * start;
        offsetWith = offsetWith<=0?0:offsetWith;
        self.contentOffset = CGPointMake(offsetWith, 0);
        // 更新偏移标识
        _model.scrollOffset = self.contentOffset;
        return;
    }
    

    if ([(UIPinchGestureRecognizer*)pinch state] == UIGestureRecognizerStateChanged && pinch.numberOfTouches==2) {
        // 手指速度
        CGFloat speed = pinch.velocity/2;
        _lastScale = speed;
        if (_lastScale>3) _lastScale = 3;
        if (_lastScale<-3) _lastScale = -3;
        ///NSLog(@"lastScale=%f",_lastScale);
        _model.scale = _lastScale;
        _model.klineWidth += _lastScale;
        _model.klineWidth = _model.klineWidth>20?20:_model.klineWidth;
        _model.klineWidth = _model.klineWidth<1?1:_model.klineWidth;
        
        int pointCounts = floor((_model.stage.width) / (_model.klineWidth + _model.klinePadding));
        if (_model.prices.count<=0) {
            pointCounts = 0;
        }
        _model.offsetStart = _model.offsetMiddle - pointCounts/2;
        if (_model.offsetStart<=0) {
            _model.offsetStart = 0;
        }
        if (_model.offsetStart!=_model.offsetLastStart || _model.offsetStart==0) {
            _model.offsetLastStart = _model.offsetStart;
            // 更新局部数据
            [self setZoomingNeedsDisplayWithModel:_model];
        }
 
    }
    if (pinch.numberOfTouches<2) {
        
    }
}


/**
 *  手指触摸开始开关
 *  父视图是否可以将消息传递给子视图，yes是将事件传递给子视图，否则不滚动，no是不传递则继续滚动
 *
 *  @param touches touch对象
 *  @param event   事件
 *  @param view    视图
 *
 *  @return 是否响应触摸
 */
- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    NSSet *allTouches=[event allTouches];
    if (allTouches.count==2) {
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark 自定义方法
//  重绘
-(void)setNeedsDisplayWithModel:(FMStockModel*)model{

    self.model = model;
    if (model.type==FMStockType_MinuteChart) {
        [self setNeedsDisplay];
        return;
    }
    if (model.type==FMStockType_FiveDaysChart) {
        [self setNeedsDisplay];
        return;
    }
    
    if (model.prices.count<=0) {
        return;
    }
    
    [self setScrollViewContentSize];
    // 偏移
    [FMStockMaxMinValues setOffsetWithModel:self.model];
    //[self zoomingOffset];
    CGFloat count = self.model.offsetEnd-self.model.offsetStart;
    CGFloat index = self.model.offsetStart;
    if (index<0) {
        index = 0;
    }
    NSArray *prices = [self.model.prices subarrayWithRange:NSMakeRange(index, count)];
    self.model.subPrices = [NSMutableArray arrayWithArray:prices];
    prices = nil;
    // 计算最大最小值
    [FMStockMaxMinValues createWithModel:self.model];
    [self setNeedsDisplay];
}

-(void)setZoomingNeedsDisplayWithModel:(FMStockModel*)model{
    self.model = model;
    if (model.type==FMStockType_MinuteChart) {
        [self setNeedsDisplay];
        return;
    }
    
    if (model.prices.count<=0) {
        return;
    }
    
    [self setScrollViewContentSize];
    // 偏移
    [FMStockMaxMinValues setOffsetWithModel:self.model];
    [self zoomingOffset];
    CGFloat count = self.model.offsetEnd-self.model.offsetStart;
    CGFloat index = self.model.offsetStart;
    if (index<0) {
        index = 0;
    }
    NSArray *prices = [self.model.prices subarrayWithRange:NSMakeRange(index, count)];
    self.model.subPrices = [NSMutableArray arrayWithArray:prices];
    prices = nil;
    // 计算最大最小值
    [FMStockMaxMinValues createWithModel:self.model];
    [self setNeedsDisplay];
}

//  设置内容宽度
-(void)setScrollViewContentSize{
    CGFloat w = self.model.counts * (self.model.klineWidth + self.model.klinePadding);
    if (w<self.model.stage.width) {
        w = self.model.stage.width +0.5;
    }
    self.contentSize = CGSizeMake(w, self.frame.size.height);
    if (self.contentOffset.x>=0) {
        CGFloat offsetStart = self.contentOffset.x / (self.model.klineWidth + self.model.klinePadding);
        self.model.offsetStart = offsetStart;
    }
    
    //FMLog(@"scroll-x=%f  start=%d",self.contentOffset.x,self.model.offsetStart);
    
}
//  放大保持偏移
-(void)zoomingOffset{
    if (_model.isZooming) {
        
        //if ([[NSString stringWithFormat:@"%f",_model.klineWidth] isEqualToString:@"nan"]) return;
        // 计算偏移距离
        _model.offsetStart = _model.offsetMiddle - (_model.offsetEnd-_model.offsetStart+1)/2;
        if (_model.offsetStart<=0) {
            _model.offsetStart = 0;
        }
        // 中间点离左边边界距离
        CGFloat left =  (_model.offsetMiddle) * (_model.klinePadding+_model.klineWidth);
        left = left - _model.stage.width/2;
        if (left<=0) {
            left = 0;
        }
        if (_model.offsetEnd==_model.prices.count-1) {
            left = (_model.offsetEnd) * (_model.klinePadding+_model.klineWidth) - _model.stage.width;
        }
        //NSLog(@"left:%f",left);
        if (isnan(left)) {
            return;
        }
        self.contentOffset = CGPointMake(left, 0);
        // 更新偏移标识
        _model.scrollOffset = self.contentOffset;
    }
}

#pragma mark -
#pragma mark Draw All

-(void)drawAllKLineWithContext:(CGContextRef)context Prices:(NSArray*)prices{
    
    CGFloat x = self.contentOffset.x;
    CGFloat textX = self.contentOffset.x;
    if (x<0) {
        x = fabs(x)/2;
        
    }
    if (x>(self.contentSize.width-self.frame.size.width)) {
        CGFloat w = x-(self.contentSize.width-self.frame.size.width);
        x -= w/2;
    }
    x += _model.klineWidth;
    
    CGMutablePathRef path_SMA_N1 = CGPathCreateMutable();
    CGMutablePathRef path_SMA_N2 = CGPathCreateMutable();
    CGMutablePathRef path_SMA_N3 = CGPathCreateMutable();
    CGMutablePathRef path_SMA_N4 = CGPathCreateMutable();
    CGMutablePathRef path_SMA_N5 = CGPathCreateMutable();
    CGMutablePathRef path_SMA_N6 = CGPathCreateMutable();
    CGMutablePathRef path_EMA = CGPathCreateMutable();
    CGMutablePathRef path_EMA_S = CGPathCreateMutable();
    CGMutablePathRef path_BOLL_DOWN = CGPathCreateMutable();
    CGMutablePathRef path_BOLL_MIDDLE = CGPathCreateMutable();
    CGMutablePathRef path_BOLL_UP = CGPathCreateMutable();
    CGMutablePathRef path_MACD_DIF = CGPathCreateMutable();
    CGMutablePathRef path_MACD_DEA = CGPathCreateMutable();
    CGMutablePathRef path_KDJ_K = CGPathCreateMutable();
    CGMutablePathRef path_KDJ_D = CGPathCreateMutable();
    CGMutablePathRef path_KDJ_J = CGPathCreateMutable();
    CGMutablePathRef path_RSI_N1 = CGPathCreateMutable();
    CGMutablePathRef path_RSI_N2 = CGPathCreateMutable();
    CGMutablePathRef path_RSI_N3 = CGPathCreateMutable();
    CGMutablePathRef path_VOL_N1 = CGPathCreateMutable();
    CGMutablePathRef path_VOL_N2 = CGPathCreateMutable();
    CGMutablePathRef path_VOL_N3 = CGPathCreateMutable();
    CGMutablePathRef path_OBV = CGPathCreateMutable();
    CGMutablePathRef path_DMI_PDI = CGPathCreateMutable();
    CGMutablePathRef path_DMI_MDI = CGPathCreateMutable();
    CGMutablePathRef path_DMI_ADX = CGPathCreateMutable();
    CGMutablePathRef path_DMI_ADXR = CGPathCreateMutable();
    // 消除锯齿
    CGContextSetShouldAntialias(context, NO);
    
    _first_SMA_N1 = NO;
    _first_SMA_N2 = NO;
    _first_SMA_N3 = NO;
    _first_SMA_N4 = NO;
    _first_SMA_N5 = NO;
    _first_SMA_N6 = NO;
    _first_EMA = NO;
    _first_EMA_S = NO;
    _first_BOLL_DOWN = NO;
    _first_BOLL_MIDDLE = NO;
    _first_BOLL_UP = NO;
    _first_MACD_DEA = NO;
    _first_MACD_DIF = NO;
    
    _first_KDJ_K = NO;
    _first_KDJ_D = NO;
    _first_KDJ_J = NO;
    _first_RSI_N1 = NO;
    _first_RSI_N2 = NO;
    _first_RSI_N3 = NO;
    
    _first_OBV = NO;
    _first_vol_MA_N1 = NO;
    _first_vol_MA_N2 = NO;
    _first_vol_MA_N3 = NO;
    _first_DMI_PDI = NO;
    _first_DMI_MDI = NO;
    _first_DMI_ADX = NO;
    _first_DMI_ADXR = NO;
    
    _isDrawLowTipView = NO;
    _isDrawHighTipView = NO;
    
    // 清楚坐标集合
    [_model.points removeAllObjects];
    
    [self drawMaxMinTextWithContext:context ScrollX:textX];
    
    NSLog(@"最高价：%f 最低价：%f",self.model.maxPrice,self.model.minPrice);
    
    // 找最大最小值
    float maxP = 0;
    float minP = 1000000;
    for (FMStockDaysModel *m in prices) {
        float high = [m.heightPrice floatValue];
        float low = [m.lowPrice floatValue];
        if (high>maxP) {
            maxP = high;
        }
        if (low<minP) {
            minP = low;
        }
    }
    
    for (FMStockDaysModel *m in prices) {
        if (x==NAN) {
            continue;
        }
        [self drawDateLineWithContext:context Prices:m ScrollX:x];
        [self drawSignleOneKLineWithContext:context Prices:m moveX:x];
        // 画k线是否有最高最低价提示
        [self drawMaxMinKlineTipView:context Prices:m moveX:x maxP:maxP minP:minP];
        // 画SAR点
        if (self.model.stockIndexType==FMStockIndexType_SAR) {
            [self drawPointWithContext:context Prices:m moveX:x];
        }
        
        
        if (self.model.stockIndexType==FMStockIndexType_SMA) {
            [self addPath:context Path:path_SMA_N1 Price:m.MA5 IsFirst:&_first_SMA_N1 ScrollX:x];
            [self addPath:context Path:path_SMA_N2 Price:m.MA10 IsFirst:&_first_SMA_N2 ScrollX:x];
            [self addPath:context Path:path_SMA_N3 Price:m.MA20 IsFirst:&_first_SMA_N3 ScrollX:x];
            
        }
        
        if (_model.stockIndexType==FMStockIndexType_EMA) {
            [self addPath:context Path:path_EMA Price:m.EMA IsFirst:&_first_EMA ScrollX:x];
        }
        
        if (_model.stockIndexType==FMStockIndexType_BOLL) {
            [self addPath:context Path:path_BOLL_DOWN Price:m.BOLL_DOWN IsFirst:&_first_BOLL_DOWN ScrollX:x];
            [self addPath:context Path:path_BOLL_MIDDLE Price:m.BOLL_MIDDLE IsFirst:&_first_BOLL_MIDDLE ScrollX:x];
            [self addPath:context Path:path_BOLL_UP Price:m.BOLL_UP IsFirst:&_first_BOLL_UP ScrollX:x];
        }
        
        if (_model.isShowBottomViews) {
            if (_model.stockIndexBottomType==FMStockIndexType_VOL) {
                [self drawVolumnLineWithContext:context Prices:m moveX:x];
                [self addBottomPath:context Path:path_VOL_N1 Price:m.volMA_N1 IsFirst:&_first_vol_MA_N1 ScrollX:x];
                [self addBottomPath:context Path:path_VOL_N2 Price:m.volMA_N2 IsFirst:&_first_vol_MA_N2 ScrollX:x];
                [self addBottomPath:context Path:path_VOL_N3 Price:m.volMA_N3 IsFirst:&_first_vol_MA_N3 ScrollX:x];
            }
            if (_model.stockIndexBottomType==FMStockIndexType_MACD) {
                [self drawMACDMLineWithContext:context Prices:m moveX:x];
                [self addBottomPath:context Path:path_MACD_DIF Price:m.MACD_DIF IsFirst:&_first_MACD_DIF ScrollX:x];
                [self addBottomPath:context Path:path_MACD_DEA Price:m.MACD_DEA IsFirst:&_first_MACD_DEA ScrollX:x];
            }
            if (_model.stockIndexBottomType==FMStockIndexType_KDJ) {
                [self addBottomPath:context Path:path_KDJ_K Price:m.KDJ_K IsFirst:&_first_KDJ_K ScrollX:x];
                [self addBottomPath:context Path:path_KDJ_D Price:m.KDJ_D IsFirst:&_first_KDJ_D ScrollX:x];
                [self addBottomPath:context Path:path_KDJ_J Price:m.KDJ_J IsFirst:&_first_KDJ_J ScrollX:x];
            }
            if (_model.stockIndexBottomType==FMStockIndexType_RSI) {
                [self addBottomPath:context Path:path_RSI_N1 Price:m.RSI_1 IsFirst:&_first_RSI_N1 ScrollX:x];
                [self addBottomPath:context Path:path_RSI_N2 Price:m.RSI_2 IsFirst:&_first_RSI_N2 ScrollX:x];
                [self addBottomPath:context Path:path_RSI_N3 Price:m.RSI_3 IsFirst:&_first_RSI_N3 ScrollX:x];
            }
            if (_model.stockIndexBottomType==FMStockIndexType_OBV) {
                [self addBottomPath:context Path:path_OBV Price:m.OBV_N1 IsFirst:&_first_OBV ScrollX:x];
            }
            if (_model.stockIndexBottomType==FMStockIndexType_DMI) {
                [self addBottomPath:context Path:path_DMI_PDI Price:m.DMI_PDI IsFirst:&_first_DMI_PDI ScrollX:x];
                [self addBottomPath:context Path:path_DMI_MDI Price:m.DMI_MDI IsFirst:&_first_DMI_MDI ScrollX:x];
                [self addBottomPath:context Path:path_DMI_ADX Price:m.DMI_ADX IsFirst:&_first_DMI_ADX ScrollX:x];
                [self addBottomPath:context Path:path_DMI_ADXR Price:m.DMI_ADXR IsFirst:&_first_DMI_ADXR ScrollX:x];
            }
            
        }
        
        x += (self.model.klineWidth+self.model.klinePadding);
    }
    
    
    CGContextSetShouldAntialias(context, YES);
    CGContextSetLineWidth(context, 1);
    if (_model.stockIndexType==FMStockIndexType_SMA) {
        CGContextAddPath(context, path_SMA_N1);
        CGContextSetStrokeColorWithColor(context, _model.klineMAN1Color.CGColor);
        CGContextStrokePath(context);
        
        CGContextAddPath(context, path_SMA_N2);
        CGContextSetStrokeColorWithColor(context, _model.klineMAN2Color.CGColor);
        CGContextStrokePath(context);
        
        CGContextAddPath(context, path_SMA_N3);
        CGContextSetStrokeColorWithColor(context, _model.klineMAN3Color.CGColor);
        CGContextStrokePath(context);
        
        //
        //        CGContextAddPath(context, path_SMA_N6);
        //        CGContextSetStrokeColorWithColor(context, _model.klineMAN6Color.CGColor);
        //        CGContextStrokePath(context);
    }
    if (_model.stockIndexType==FMStockIndexType_EMA) {
        CGContextAddPath(context, path_EMA);
        CGContextSetStrokeColorWithColor(context, _model.klineEMAColor.CGColor);
        CGContextStrokePath(context);
    }
    if (_model.stockIndexType==FMStockIndexType_BOLL) {
        CGContextAddPath(context, path_BOLL_DOWN);
        CGContextSetStrokeColorWithColor(context, _model.klineBOLLDownColor.CGColor);
        CGContextStrokePath(context);
        
        CGContextAddPath(context, path_BOLL_MIDDLE);
        CGContextSetStrokeColorWithColor(context, _model.klineBOLLMiddleColor.CGColor);
        CGContextStrokePath(context);
        
        CGContextAddPath(context, path_BOLL_UP);
        CGContextSetStrokeColorWithColor(context, _model.klineBOLLUpColor.CGColor);
        CGContextStrokePath(context);
    }
    
    if (_model.isShowBottomViews) {
        if (_model.stockIndexBottomType==FMStockIndexType_VOL) {
            CGContextAddPath(context, path_VOL_N1);
            CGContextSetStrokeColorWithColor(context, _model.klineVOLN1Color.CGColor);
            CGContextStrokePath(context);
            
            CGContextAddPath(context, path_VOL_N2);
            CGContextSetStrokeColorWithColor(context, _model.klineVOLN2Color.CGColor);
            CGContextStrokePath(context);
            
            CGContextAddPath(context, path_VOL_N3);
            CGContextSetStrokeColorWithColor(context, _model.klineVOLN3Color.CGColor);
            CGContextStrokePath(context);
        }
        if (_model.stockIndexBottomType==FMStockIndexType_MACD) {
            CGContextAddPath(context, path_MACD_DIF);
            CGContextSetStrokeColorWithColor(context, _model.klineMACDDIFColor.CGColor);
            CGContextStrokePath(context);
            
            CGContextAddPath(context, path_MACD_DEA);
            CGContextSetStrokeColorWithColor(context, _model.klineMACDDEAColor.CGColor);
            CGContextStrokePath(context);
        }
        if (_model.stockIndexBottomType==FMStockIndexType_KDJ) {
            CGContextAddPath(context, path_KDJ_K);
            CGContextSetStrokeColorWithColor(context, _model.klineKDJKColor.CGColor);
            CGContextStrokePath(context);
            
            CGContextAddPath(context, path_KDJ_D);
            CGContextSetStrokeColorWithColor(context, _model.klineKDJDColor.CGColor);
            CGContextStrokePath(context);
            
            CGContextAddPath(context, path_KDJ_J);
            CGContextSetStrokeColorWithColor(context, _model.klineKDJJColor.CGColor);
            CGContextStrokePath(context);
        }
        if (_model.stockIndexBottomType==FMStockIndexType_RSI) {
            CGContextAddPath(context, path_RSI_N1);
            CGContextSetStrokeColorWithColor(context, _model.klineRSIN1Color.CGColor);
            CGContextStrokePath(context);
            
            CGContextAddPath(context, path_RSI_N2);
            CGContextSetStrokeColorWithColor(context, _model.klineRSIN2Color.CGColor);
            CGContextStrokePath(context);
            
            CGContextAddPath(context, path_RSI_N3);
            CGContextSetStrokeColorWithColor(context, _model.klineRSIN3Color.CGColor);
            CGContextStrokePath(context);
        }
        if (_model.stockIndexBottomType==FMStockIndexType_OBV) {
            CGContextAddPath(context, path_OBV);
            CGContextSetStrokeColorWithColor(context, _model.klineOBVColor.CGColor);
            CGContextStrokePath(context);
        }
        
        if (_model.stockIndexBottomType==FMStockIndexType_DMI) {
            CGContextAddPath(context, path_DMI_PDI);
            CGContextSetStrokeColorWithColor(context, _model.klineDMIPDIColor.CGColor);
            CGContextStrokePath(context);
            
            CGContextAddPath(context, path_DMI_MDI);
            CGContextSetStrokeColorWithColor(context, _model.klineDMIMDIColor.CGColor);
            CGContextStrokePath(context);
            
            CGContextAddPath(context, path_DMI_ADX);
            CGContextSetStrokeColorWithColor(context, _model.klineDMIADXColor.CGColor);
            CGContextStrokePath(context);
            
            CGContextAddPath(context, path_DMI_ADXR);
            CGContextSetStrokeColorWithColor(context, _model.klineDMIADXRColor.CGColor);
            CGContextStrokePath(context);
        }
    }
    
    CGPathRelease(path_SMA_N1);
    CGPathRelease(path_SMA_N2);
    CGPathRelease(path_SMA_N3);
    CGPathRelease(path_SMA_N4);
    CGPathRelease(path_SMA_N5);
    CGPathRelease(path_SMA_N6);
    CGPathRelease(path_EMA);
    CGPathRelease(path_EMA_S);
    CGPathRelease(path_BOLL_DOWN);
    CGPathRelease(path_BOLL_MIDDLE);
    CGPathRelease(path_BOLL_UP);
    CGPathRelease(path_MACD_DEA);
    CGPathRelease(path_MACD_DIF);
    CGPathRelease(path_KDJ_D);
    CGPathRelease(path_KDJ_J);
    CGPathRelease(path_KDJ_K);
    CGPathRelease(path_RSI_N1);
    CGPathRelease(path_RSI_N2);
    CGPathRelease(path_RSI_N3);
    CGPathRelease(path_VOL_N1);
    CGPathRelease(path_VOL_N2);
    CGPathRelease(path_VOL_N3);
    CGPathRelease(path_OBV);
    CGPathRelease(path_DMI_PDI);
    CGPathRelease(path_DMI_MDI);
    CGPathRelease(path_DMI_ADX);
    CGPathRelease(path_DMI_ADXR);
    
    _zoomingFinished = YES;
}


//  画一条K线
-(void)drawSignleOneKLineWithContext:(CGContextRef)context Prices:(FMStockDaysModel*)prices moveX:(CGFloat)x{
    if (x==NAN) {
        return;
    }
    // 总共两条线 一条实体线 一条影线
    // 实体Y轴
    CGFloat y1 = [FMStockMaxMinValues topY:[prices.closePrice floatValue] Model:self.model];
    CGFloat y2 = [FMStockMaxMinValues topY:[prices.openPrice floatValue] Model:self.model];
    CGFloat y3 = [FMStockMaxMinValues topY:[prices.heightPrice floatValue] Model:self.model];
    CGFloat y4 = [FMStockMaxMinValues topY:[prices.lowPrice floatValue] Model:self.model];
    // CGFloat h1 = fabsl(y2-y1);
    UIColor *color = self.model.klineUpColor;
    if (y2<y1) {
        color = self.model.klineDownColor;
    }
    if (y2==y1) {
        color = self.model.klineUpColor;
        y2=y1+1;
    }
    CGContextSetShouldAntialias(context, NO);
    // 实体
    CGFloat w = self.model.klineWidth;
    CGContextSetLineWidth(context, w);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, x-w/2, y1);
    CGPathAddLineToPoint(path, NULL, x-w/2, y2);
    CGContextAddPath(context, path);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextStrokePath(context);
    CGPathRelease(path);
    
    // 影线
    CGFloat lw = 1;
    CGContextSetLineWidth(context, lw);
    if (w<=2) {
        lw = lw/2;
        CGContextSetLineWidth(context, lw);
    }
    CGContextSetShouldAntialias(context, YES);
    CGMutablePathRef path2 = CGPathCreateMutable();
    CGPathMoveToPoint(path2, NULL, x-w/2, y3);
    CGPathAddLineToPoint(path2, NULL, x-w/2, y4);
    CGContextAddPath(context, path2);
    CGContextSetStrokeColorWithColor(context,color.CGColor);
    CGContextStrokePath(context);
    CGPathRelease(path2);
    // 保存坐标
    [_model.points addObject:@[NSStringFromCGPoint(CGPointMake(x-self.contentOffset.x, y1)),prices]];
    
    // 画信号圆点
    if (_model.isOpenSignal) {
        if (prices.signleType==FMKLineSignleType_None) {
            return;
        }
        // 卖出信号
        x = x-w/2;
        float y = y3 - w/2 - 2;
        // 买入信号
        if (prices.signleType==FMKLineSignleType_Up) {
            y = y4 + w/2 +2;
            [self paintpie:context start:0 capacity:360 pointx:x pointy:y radius:w/2 piecolor:[UIColor blueColor]];
        }
        if (prices.signleType==FMKLineSignleType_Down) {
            [self paintpie:context start:0 capacity:360 pointx:x pointy:y radius:w/2 piecolor:[UIColor purpleColor]];
        }
        
    }
 
}


//  画MACD线
-(void)drawMACDMLineWithContext:(CGContextRef)context Prices:(FMStockDaysModel*)prices moveX:(CGFloat)x{
    x -= 1.5;
    // 实体Y轴
    CGFloat y2 = [FMStockMaxMinValues macdBottomY:[prices.MACD_M floatValue] Model:self.model];
    CGFloat y1 = _model.stage.topHeight+_model.stage.padding.middle+_model.stage.bottomHeight/2;
    
    if (y2<=0) {
        y2 = y1;
    }
    // CGFloat h1 = fabsl(y2-y1);
    UIColor *color = self.model.klineUpColor;
    if ([prices.MACD_M floatValue]<0) {
        color = self.model.klineDownColor;
    }
    if ([prices.MACD_M floatValue]==0) {
        color = self.model.klineGreyColor;
    }
    CGContextSetShouldAntialias(context, NO);
    // 实体
    CGFloat w = 1;
    CGContextSetLineWidth(context, w);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, x-w/2, y1);
    CGPathAddLineToPoint(path, NULL, x-w/2, y2);
    CGContextAddPath(context, path);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextStrokePath(context);
    CGPathRelease(path);
    
}

// 画k线中显示最高最低价信息
-(void)drawMaxMinKlineTipView:(CGContextRef)context Prices:(FMStockDaysModel*)prices moveX:(CGFloat)x maxP:(float)maxP minP:(float)minP{
    // 最高价
    float heightPrice = [prices.heightPrice floatValue];
    float lowPrice = [prices.lowPrice floatValue];
    UIFont *font = [UIFont systemFontOfSize:8];
    if (heightPrice>=maxP && !_isDrawHighTipView) {
        _isDrawHighTipView = YES;
        // 文本宽度
        NSString *text = [NSString stringWithFormat:@"%.2f",[prices.heightPrice floatValue]];
        NSLog(@"最高价：%@",text);
        float w = [text sizeWithAttributes:@{NSFontAttributeName:font}].width+2;
        // 画最高价提示
        // 实体Y轴
        CGFloat y = [FMStockMaxMinValues topY:[prices.heightPrice floatValue]  Model:self.model];
        float x1 = x+self.model.klineWidth+2*(self.model.klineWidth+self.model.klinePadding);
        float x2 = x1+w;
        if ((x-self.contentOffset.x)>self.model.stage.width/2) {
            x1 = x-self.model.klineWidth-2*(self.model.klineWidth+self.model.klinePadding);
            x2 = x1 - w;
        }
        // CGFloat h1 = fabsl(y2-y1);
        UIColor *color = _model.stage.fontColor;
        CGContextSetShouldAntialias(context, YES);
        // 指向线
        CGContextSetLineWidth(context, 0.5);
        CGMutablePathRef lpath = CGPathCreateMutable();
        CGPathMoveToPoint(lpath, NULL, x-self.model.klineWidth/2, y);
        CGPathAddLineToPoint(lpath, NULL, x1, y);
        CGContextAddPath(context, lpath);
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextStrokePath(context);
        CGPathRelease(lpath);
        // 实体
        CGContextSetLineWidth(context, 10);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, x1, y);
        CGPathAddLineToPoint(path, NULL, x2, y);
        CGContextAddPath(context, path);
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextStrokePath(context);
        CGPathRelease(path);
        // 画文字
        float tx = x1;
        if ((x-self.contentOffset.x)>self.model.stage.width/2) {
            tx = x2;
        }
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        [text drawInRect:CGRectMake(tx+1, y-5, w, 10) withFont:font];
    }
    
    if (lowPrice<=minP && !_isDrawLowTipView) {
        _isDrawLowTipView = YES;
        // 文本宽度
        NSString *text = [NSString stringWithFormat:@"%.2f",[prices.lowPrice floatValue]];
        NSLog(@"最低价：%@",text);
        float w = [text sizeWithAttributes:@{NSFontAttributeName:font}].width+2;
        // 画最低价提示
        // 实体Y轴
        CGFloat y = [FMStockMaxMinValues topY:[prices.lowPrice floatValue]  Model:self.model];
        float x1 = x+self.model.klineWidth+2*(self.model.klineWidth+self.model.klinePadding);
        float x2 = x1+w;
        if ((x-self.contentOffset.x)>self.model.stage.width/2) {
            x1 = x-self.model.klineWidth-2*(self.model.klineWidth+self.model.klinePadding);
            x2 = x1 - w;
        }
        // CGFloat h1 = fabsl(y2-y1);
        UIColor *color = _model.stage.fontColor;
        CGContextSetShouldAntialias(context, YES);
        // 指向线
        CGContextSetLineWidth(context, 0.5);
        CGMutablePathRef lpath = CGPathCreateMutable();
        CGPathMoveToPoint(lpath, NULL, x-self.model.klineWidth/2, y);
        CGPathAddLineToPoint(lpath, NULL, x1, y);
        CGContextAddPath(context, lpath);
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextStrokePath(context);
        CGPathRelease(lpath);
        // 实体
        CGContextSetLineWidth(context, 10);
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, x1, y);
        CGPathAddLineToPoint(path, NULL, x2, y);
        CGContextAddPath(context, path);
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextStrokePath(context);
        CGPathRelease(path);
        // 画文字
        float tx = x1;
        if ((x-self.contentOffset.x)>self.model.stage.width/2) {
            tx = x2;
        }
        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
        [text drawInRect:CGRectMake(tx+1, y-5, w, 10) withFont:font];
    }
}

//  画成交量
-(void)drawVolumnLineWithContext:(CGContextRef)context Prices:(FMStockDaysModel*)prices moveX:(CGFloat)x{
    // 实体Y轴
    CGFloat y1 = [FMStockMaxMinValues bottomY:[prices.volumn floatValue] Model:self.model];
    CGFloat y2 = _model.stage.height;
    
    // CGFloat h1 = fabsl(y2-y1);
    UIColor *color = self.model.klineUpColor;
    if ([prices.closePrice floatValue]<[prices.openPrice floatValue]) {
        color = self.model.klineDownColor;
    }
//    if ([prices.closePrice floatValue]==[prices.openPrice floatValue]) {
//        color = self.model.klineGreyColor;
//    }
    CGContextSetShouldAntialias(context, NO);
    // 实体
    CGFloat w = _model.klineWidth;
    CGContextSetLineWidth(context, w);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, x-w/2, y1);
    CGPathAddLineToPoint(path, NULL, x-w/2, y2);
    CGContextAddPath(context, path);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextStrokePath(context);
    CGPathRelease(path);
    
}

//  主图路径
-(void)addPath:(CGContextRef)context Path:(CGMutablePathRef)path Price:(NSString*)price IsFirst:(BOOL*)isfirst ScrollX:(CGFloat)x{
    x = x-_model.klineWidth/2;
    CGFloat y = [FMStockMaxMinValues topY:[price floatValue] Model:_model];
    if (y<=0 || y>=_model.stage.topHeight) {
        return;
    }
    CGContextSetShouldAntialias(context, YES);
    CGContextSetLineWidth(context, 1);
    CGContextSetAlpha(context, 1);
    if (!*isfirst) {
        // 消除锯齿
        
        *isfirst = YES;
        // 定位第一个点
        CGPathMoveToPoint(path, NULL, x, y);
    }else{
        // 继续添加点
        CGPathAddLineToPoint(path,NULL, x, y);
    }
    
}



//  副图指标y轴路径
-(void)addBottomPath:(CGContextRef)context Path:(CGMutablePathRef)path Price:(NSString*)price IsFirst:(BOOL*)isfirst ScrollX:(CGFloat)x{
    x = x-_model.klineWidth/2;
    CGFloat y = [FMStockMaxMinValues bottomY:[price floatValue] Model:_model];
    CGContextSetShouldAntialias(context, YES);
    CGContextSetLineWidth(context, 1);
    CGContextSetAlpha(context, 1);
    if (y<=0 || y>=_model.stage.height || y<_model.stage.topHeight) {
        return;
    }
    if (!*isfirst) {
        // 消除锯齿
        
        *isfirst = YES;
        // 定位第一个点
        CGPathMoveToPoint(path, NULL, x, y);
    }else{
        // 继续添加点
        CGPathAddLineToPoint(path,NULL, x, y);
    }
    
}

//  最大最小值
-(void)drawMaxMinTextWithContext:(CGContextRef)context ScrollX:(CGFloat)x{
//    if (!_model.isShowText) {
//        return;
//    }
    CGContextSetShouldAntialias(context, YES);
    
    //    NSString *maxText = [NSString stringWithFormat:@"%.2f",_model.maxPrice];
    //    CGContextSetFillColorWithColor(context, _model.klineDownColor.CGColor);
    //    NSString *minText = [NSString stringWithFormat:@"%.2f",_model.minPrice];
    //    [maxText drawInRect:CGRectMake(x, 1, 100, _model.stage.font.pointSize) withFont:_model.stage.font];
    //    [minText drawInRect:CGRectMake(x,_model.stage.topHeight-_model.stage.font.pointSize-1,100,_model.stage.font.pointSize)
    //               withFont:_model.stage.font];
    
    // 分成4份价格
    double subFourPrice = (_model.maxPrice - _model.minPrice) / 4;
    float y = 1;
    float w = 100;
    float h = _model.stage.font.pointSize;
    float subHeight = (_model.stage.topHeight-2) / 4;
    CGContextSetFillColorWithColor(context, _model.klineUpColor.CGColor);
    for (int i=0; i<5; i++) {
        
        if (i>2) {
            CGContextSetFillColorWithColor(context, _model.klineDownColor.CGColor);
        }
        if (i==2) {
            CGContextSetFillColorWithColor(context, _model.stage.fontColor.CGColor);
        }
        if (_model.type!=FMStockType_MinuteChart && _model.type!=FMStockType_FiveDaysChart) {
            CGContextSetFillColorWithColor(context, _model.stage.fontColor.CGColor);
        }
        double value = _model.maxPrice - i*subFourPrice;
        NSString *valStr = [NSString stringWithFormat:@"%.2f",value];
        
        float yy = y;
        if (i>0 && i<4) {
            yy = y - h/2-1;
        }
        if (i==4) {
            yy = y - h-1;
        }
        if (_model.isShowLeftText) {
            [valStr drawInRect:CGRectMake(x+2, yy, w, h) withFont:_model.stage.font];
        }
        
        
        if (_model.type==FMStockType_MinuteChart || (_model.type==FMStockType_FiveDaysChart && _model.isShowRightText)) {
            // 对应的涨跌幅
            NSString *rateStr = [NSString stringWithFormat:@"%.2f%%",(value-_model.yestodayClosePrice)/_model.yestodayClosePrice*100];
            CGFloat tw = [rateStr sizeWithFont:_model.stage.font].width;
            [rateStr drawInRect:CGRectMake(_model.stage.width-tw-2, yy, tw, _model.stage.font.pointSize)
                       withFont:_model.stage.font];
        }
        y += subHeight;
    }
    
    //[minText drawInRect:CGRectMake(0, _model.stage.topHeight, 100, 12) withAttributes:@{NSForegroundColorAttributeName:_model.stage.fontColor}];
    // 涨幅跌幅
    //    if (_model.type==FMStockType_MinuteChart) {
    //        NSString *upText = [NSString stringWithFormat:@"%.2f%%",(_model.maxPrice-_model.yestodayClosePrice)/_model.yestodayClosePrice*100];
    //        NSString *downText = [NSString stringWithFormat:@"%.2f%%",(_model.minPrice-_model.yestodayClosePrice)/_model.yestodayClosePrice*100];
    //        CGFloat tw = [downText sizeWithFont:_model.stage.font].width;
    //        CGContextSetFillColorWithColor(context, _model.klineUpColor.CGColor);
    //        [upText drawInRect:CGRectMake(_model.stage.width-tw, 1, tw, _model.stage.font.pointSize)
    //                  withFont:_model.stage.font];
    //        CGContextSetFillColorWithColor(context, _model.klineDownColor.CGColor);
    //        [downText drawInRect:CGRectMake(_model.stage.width-tw-1, _model.stage.topHeight-_model.stage.font.pointSize-1, tw, _model.stage.font.pointSize)
    //                    withFont:_model.stage.font];
    //        
    //        
    //        
    //        
    //    }
}

//  画日期线
-(void)drawDateLineWithContext:(CGContextRef)context Prices:(FMStockDaysModel*)prices ScrollX:(CGFloat)x{

    NSString *firstTime = prices.datetime ;//[prices.datetime substringToIndex:6];
    int width = 150; // 一百距离一个日期
    int klineCount = width / (_model.klineWidth+_model.klinePadding); // 相隔的k线数量
    // 目前x轴指向第几个k线
    //    int index = (int)x / (_model.klineWidth+_model.klinePadding);
    if (prices.index % klineCount==0 && prices.index>0) {
        CGFloat y1 = 0;
        CGFloat y2 = _model.stage.height;
        // CGFloat h1 = fabsl(y2-y1);
        UIColor *color = self.model.stage.lineColor;
        CGFloat w = _model.klineWidth;
        CGFloat lw = _model.stage.lineWidth;
        CGContextSetShouldAntialias(context, NO);
        CGContextSetLineWidth(context, lw);
        CGMutablePathRef path2 = CGPathCreateMutable();
        CGPathMoveToPoint(path2, NULL, x-w/2-lw/2, y1);
        CGPathAddLineToPoint(path2, NULL, x-w/2-lw/2, y2);
        CGContextAddPath(context, path2);
        CGContextSetStrokeColorWithColor(context,color.CGColor);
        CGContextStrokePath(context);
        CGPathRelease(path2);
        
        // 画日期
        CGContextSetShouldAntialias(context, YES);
        CGContextSetFillColorWithColor(context, _model.stage.fontColor.CGColor);
        NSString *time = firstTime;
        if (firstTime.length>=8) {
            NSString *year = [firstTime substringToIndex:4];
            NSString *month = [firstTime substringWithRange:NSMakeRange(4, 2)];
            NSString *day = [firstTime substringWithRange:NSMakeRange(6, 2)];
            // 显示日期
            time = [NSString stringWithFormat:@"%@-%@",month,day];
            if (_model.type == FMStockType_DaysChart) {
                time = [NSString stringWithFormat:@"%@-%@-%@",year,month,day];
            }
            if (_model.type == FMStockType_WeekChart) {
                time = [NSString stringWithFormat:@"%@-%@",year,month];
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
                time = [NSString stringWithFormat:@"%@:%@",hour,minute];
            }
        }
        
        CGFloat tw = [time sizeWithFont:_model.stage.font].width;
        [time drawInRect:CGRectMake(x-tw/2-_model.klineWidth/2, _model.stage.topHeight+1, tw, _model.stage.font.pointSize) withFont:_model.stage.font];
        
        time = nil;
    }
    
//    NSString *key = [prices.datetime substringToIndex:6];
//    // 每个月的第一天
//    NSString *firstTime = [_model.firstMonthDay objectForKey:key];
//    NSString *year = [firstTime substringToIndex:4];
//    NSString *month = [firstTime substringWithRange:NSMakeRange(4, 2)];
//    //NSString *parentTime = [_model.firstMonthDay valueForKey:[_model.firstMonthDay.allKeys firstObject]];
////    int subMonth = 2;
////    if (_model.type==FMStockType_WeekChart) {
////        subMonth = 4;
////    }
////    if (_model.type==FMStockType_MonthChart) {
////        subMonth = 10;
////    }
//    
//    if([firstTime isEqualToString:prices.datetime]){
//
////        int result = [month intValue] - [_preMonth intValue];
////        if ([month intValue]<[_preMonth intValue]) {
////            result = [month intValue]+12 - [_preMonth intValue];
////        }
////        if (result < subMonth) {
////            return;
////        }
////        _preMonth = month;
////        _lastDateX = x;
//        CGFloat y1 = 0;
//        CGFloat y2 = _model.stage.height;
//        // CGFloat h1 = fabsl(y2-y1);
//        UIColor *color = self.model.stage.lineColor;
//        CGFloat w = _model.klineWidth;
//        CGFloat lw = _model.stage.lineWidth;
//        CGContextSetShouldAntialias(context, NO);
//        CGContextSetLineWidth(context, lw);
//        CGMutablePathRef path2 = CGPathCreateMutable();
//        CGPathMoveToPoint(path2, NULL, x-w/2-lw/2, y1);
//        CGPathAddLineToPoint(path2, NULL, x-w/2-lw/2, y2);
//        CGContextAddPath(context, path2);
//        CGContextSetStrokeColorWithColor(context,color.CGColor);
//        CGContextStrokePath(context);
//        CGPathRelease(path2);
//    
//        // 画日期
//        CGContextSetShouldAntialias(context, YES);
//        CGContextSetFillColorWithColor(context, _model.stage.fontColor.CGColor);
//        
//        //NSString *day = [firstTime substringFromIndex:6];
//        NSString *time = [NSString stringWithFormat:@"%@-%@",year,month];
//        CGFloat tw = [time sizeWithFont:_model.stage.font].width;
//        [time drawInRect:CGRectMake(x-tw/2, _model.stage.topHeight+1, tw, _model.stage.font.pointSize) withFont:_model.stage.font];
//        
//        time = nil;
//        year = nil;
//        month = nil;
//    }
//    key = nil;
//    firstTime = nil;
}


//  画文本命令
-(void)drawtextWithContext:(CGContextRef)context Prices:(FMStockDaysModel*)prices ScrollX:(CGFloat)x{
    NSDictionary *draws = self.model.drawDatas[prices.datetime];
    if ([[draws class] isSubclassOfClass:[NSDictionary class]]) {
        // 获取画文本命令
        NSArray *drawtext = draws[@"drawtext"];
        if([[drawtext class] isSubclassOfClass:[NSArray class]]){
            for (NSDictionary *line in drawtext) {
                BOOL top = YES;
                // 文本
                NSString *title = line[@"title"];
                CGFloat tw = [title sizeWithAttributes:@{NSFontAttributeName:_model.stage.font}].width;
                // 颜色代码
                NSString *colorCode = line[@"color"];
                // 位置对应的值
                NSString *price = line[@"price"];
                NSString *type = line[@"type"];
                // 计算相对高度
                CGFloat y = [FMStockMaxMinValues topY:[price floatValue] Model:_model];
                if ([price floatValue]>=[prices.heightPrice floatValue] && [type isEqualToString:@"0"]) {
                    y -= 10;
                    y -= _model.stage.font.pointSize;
                }
                if ([price floatValue]<=[prices.lowPrice floatValue] && [type isEqualToString:@"1"]) {
                    y += 10;
                    top = NO;
                }
                
                UIColor *color = [FMCommon colorWithHexString:colorCode];
                if (!color) {
                    color = [UIColor whiteColor];
                }
                
                // 画日期
                CGContextSetShouldAntialias(context, YES);
                CGContextSetFillColorWithColor(context, color.CGColor);
                CGContextSetStrokeColorWithColor(context, color.CGColor);
                float rtw = tw + 4;
                CGContextFillEllipseInRect(context, CGRectMake(x-_model.klineWidth/2-rtw/2, y-1, rtw, rtw));
                // 三角
                // 只要三个点就行跟画一条线方式一样，把三点连接起来
                CGPoint sPoints[3];//坐标点
                if (top) {
                    // 尖头向下
                    sPoints[0] =CGPointMake(x-_model.klineWidth/2-rtw/4, y+rtw-2);//坐标1
                    sPoints[1] =CGPointMake(x-_model.klineWidth/2+rtw/4, y+rtw-2);//坐标2
                    sPoints[2] =CGPointMake(x-_model.klineWidth/2, y+rtw+rtw/4);//坐标3
                }else{
                    // 尖头向上
                    sPoints[0] =CGPointMake(x-_model.klineWidth/2, y-rtw/4);//坐标1
                    sPoints[1] =CGPointMake(x-_model.klineWidth/2+rtw/4, y);//坐标2
                    sPoints[2] =CGPointMake(x-_model.klineWidth/2-rtw/4, y);//坐标3
                }
                
                CGContextAddLines(context, sPoints, 3);//添加线
                CGContextClosePath(context);//封起来
                CGContextDrawPath(context, kCGPathFillStroke); //根据坐标绘制路径
                CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
                [title drawInRect:CGRectMake(x-_model.klineWidth/2-tw/2, y, tw, _model.stage.font.pointSize) withFont:_model.stage.font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
                
                title = nil;
                colorCode = nil;
                price = nil;
            }
            
            
        }
        drawtext = nil;
    }
    
}


//  画一个点 半径等于k线宽度
-(void)drawPointWithContext:(CGContextRef)context Prices:(FMStockDaysModel*)prices moveX:(CGFloat)x{
    if (x==NAN) {
        return;
    }
    UIColor *color = [UIColor redColor];
    float price = [prices.SAR floatValue];
    float closePrice = [prices.closePrice floatValue];
    // 实体Y轴
    CGFloat y = [FMStockMaxMinValues topY:price Model:self.model];
    CGFloat w = self.model.klineWidth>4?4:self.model.klineWidth;
    float xx = x - w;
    
    if (price>=closePrice) {
        color = [UIColor blueColor];
        //y -= w/2;
        //FMLog(@"blue:%@=%.2f",prices.datetime,price);
    }else{
        color = [UIColor redColor];
        //y += w/2;
        //FMLog(@"red:%@=%.2f",prices.datetime,price);
    }
    // 总共两条线 一条实体线 一条影线
    
    // CGFloat h1 = fabsl(y2-y1);
    
    
    CGContextSetShouldAntialias(context, YES);
    // 实体
    CGContextSetFillColorWithColor(context,color.CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(xx,y,w,w));
    CGContextDrawPath(context, kCGPathFill);
}

#pragma mark -
#pragma mark 分时图

//  分时图路径
-(void)drawMinuteLine:(CGContextRef)context Prices:(NSArray*)prices{
    
    // 点间距离
    CGFloat signWidth = _model.stage.width / (_model.upCounts+_model.downCounts);
//    if (_model.type==FMStockType_FiveDaysChart){
//        signWidth = _model.stage.width / (_model.upCounts+_model.downCounts)*3;
//    }
    CGMutablePathRef path = CGPathCreateMutable();
    CGMutablePathRef avPath = CGPathCreateMutable();
    CGMutablePathRef bgPath = CGPathCreateMutable();
    CGMutablePathRef linePath = CGPathCreateMutable();
    CGMutablePathRef upPath = CGPathCreateMutable();
    CGMutablePathRef downPath = CGPathCreateMutable();
    int i = 0;
    CGFloat x = 0;
    
    [_model.points removeAllObjects];
    for (FMStockMinuteModel *m in prices) {
        CGFloat y = [FMStockMaxMinValues topY:[m.price floatValue] Model:_model];
        CGFloat avy = [FMStockMaxMinValues topY:[m.averagePrice floatValue] Model:_model];
        
        CGFloat upY = (_model.maxPower-m.upPower)/(_model.maxPower-_model.minPower)*_model.stage.topHeight;
        
        CGFloat downY = (_model.maxPower-m.downPower)/(_model.maxPower-_model.minPower)*_model.stage.topHeight;
        if (_model.maxPower==_model.minPower) {
            upY = 0;
            downY = 0;
        }
        if (y<=0.5) {
            y = 0.5;
        }
        if (y>_model.stage.topHeight) {
            continue;
        }
        if (i==0) {
            // 定位第一个点
            CGPathMoveToPoint(path, NULL, x, y);
            CGPathMoveToPoint(bgPath, NULL, x, y);
            CGPathMoveToPoint(avPath, NULL, x, avy);
            if (_model.isOpenSignal) {
                CGPathMoveToPoint(upPath, NULL, x, upY);
                CGPathMoveToPoint(downPath, NULL, x, downY);
            }
            
        }else{
            // 继续添加点
            CGPathAddLineToPoint(path,NULL, x, y);
            CGPathAddLineToPoint(bgPath,NULL, x, y);
            CGPathAddLineToPoint(avPath,NULL, x, avy);
            if (_model.isOpenSignal) {
                CGPathAddLineToPoint(upPath,NULL, x, upY);
                CGPathAddLineToPoint(downPath,NULL, x, downY);
            }
        }
        [self drawMinuteVolumnLineWithContext:context Prices:m moveX:x];
        
        // 保存坐标
        [_model.points addObject:@[NSStringFromCGPoint(CGPointMake(x, y)),m]];
        
        x += signWidth;
        i++;
    }
    CGContextSetShouldAntialias(context, YES);
    CGContextSetLineWidth(context, 1);
    CGContextSetAlpha(context, 1);
//    CGPathAddLineToPoint(bgPath,NULL, x-signWidth, _model.stage.topHeight);
//    CGPathAddLineToPoint(bgPath,NULL, 0, _model.stage.topHeight);
//    CGContextAddPath(context, bgPath);
//    // CGPathCloseSubpath(bgPath);
////    CGContextSetFillColorWithColor(context,_model.klineMinutePathFillColor.CGColor);
//    //CGContextFillPath(context);
////    CGContextDrawPath(context, kCGPathFill);
//    CGPathRelease(bgPath);
//    
    CGContextAddPath(context, path);
    CGContextSetStrokeColorWithColor(context,_model.klineMinuteColor.CGColor);
    CGContextStrokePath(context);
    CGPathRelease(path);
    
    CGContextAddPath(context, avPath);
    CGContextSetStrokeColorWithColor(context,_model.klineMinuteAverageColor.CGColor);
    CGContextStrokePath(context);
    CGPathRelease(avPath);
    
    if (_model.isOpenSignal) {
        CGContextAddPath(context, upPath);
        CGContextSetStrokeColorWithColor(context,_model.klineUpColor.CGColor);
        CGContextStrokePath(context);
        CGPathRelease(upPath);
        
        CGContextAddPath(context, downPath);
        CGContextSetStrokeColorWithColor(context,_model.klineDownColor.CGColor);
        CGContextStrokePath(context);
        CGPathRelease(downPath);
    }
    
    [self drawMaxMinTextWithContext:context ScrollX:0];
    
    // 画中间的虚线
    CGContextSetLineWidth(context, 0.5);
    CGPathMoveToPoint(linePath, NULL, 0, _model.stage.topHeight/2);
    CGPathAddLineToPoint(linePath, NULL, _model.stage.width, _model.stage.topHeight/2);
    CGContextAddPath(context, linePath);
    CGFloat lengths[] = {1,2};
    CGContextSetLineDash(context, 0, lengths, 2);  //画虚线
    CGContextSetStrokeColorWithColor(context,_model.klineMinuteDashColor.CGColor);
    CGContextStrokePath(context);
    CGPathRelease(linePath);
    if (_model.type==FMStockType_MinuteChart) {
        [self drawMinuteDateTimeWithContext:context];
    }
    
}

//  画分时图成交量
-(void)drawMinuteVolumnLineWithContext:(CGContextRef)context Prices:(FMStockMinuteModel*)prices moveX:(CGFloat)x{
    // 实体Y轴
    CGFloat y1 = [FMStockMaxMinValues bottomY:[prices.volumn floatValue] Model:self.model];
    CGFloat y2 = _model.stage.height;
    if (y1>CGFLOAT_MAX || [prices.volumn floatValue]<=0) {
        return;
    }
    // CGFloat h1 = fabsl(y2-y1);
    
    UIColor *color = self.model.klineMinuteColor;
    if (prices.color) {
        if ([prices.color floatValue]==0) {
            color = self.model.klineDownColor;
        }
        if ([prices.color floatValue]==1) {
            color = self.model.klineUpColor;
        }
    }
    
    CGContextSetShouldAntialias(context, YES);
    // 实体
    CGFloat w = _model.klineWidth;
    CGContextSetLineWidth(context, w);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, x+w/2, y1);
    CGPathAddLineToPoint(path, NULL, x+w/2, y2);
    CGContextAddPath(context, path);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextStrokePath(context);
    CGPathRelease(path);
    
    // 画多空能量对比
    //[self drawMinutePowerWithContext:context Prices:prices moveX:x];
}

//  画分时图时间显示
-(void)drawMinuteDateTimeWithContext:(CGContextRef)context{
    CGFloat upRate = _model.upCounts/(_model.upCounts+_model.downCounts+1.0f);
    CGFloat upWidth = _model.stage.width * upRate;
    CGFloat tw = [_model.startTime sizeWithFont:_model.stage.font].width;
    [self drawTextWithContext:context
                        Title:_model.startTime
                         Font:_model.stage.font
                        Point:CGPointMake(tw/2, _model.stage.topHeight+1)];
    
    [self drawTextWithContext:context
                        Title:_model.middleTime
                         Font:_model.stage.font
                        Point:CGPointMake(upWidth, _model.stage.topHeight+1)];
    
    tw = [_model.endTime sizeWithFont:_model.stage.font].width;
    [self drawTextWithContext:context
                        Title:_model.endTime
                         Font:_model.stage.font
                        Point:CGPointMake(_model.stage.width - tw/2, _model.stage.topHeight+1)];
}

-(void)drawMinutePowerWithContext:(CGContextRef)context Prices:(FMStockMinuteModel*)prices moveX:(CGFloat)x{

    // 画在副图顶部
    CGFloat upPowerWidth = x;
    CGFloat downPowerWidth = prices.downPower/prices.upPower * x;
    if (prices.downPower>prices.upPower) {
        downPowerWidth = x;
        upPowerWidth = prices.upPower/prices.downPower * x;
    }
    CGPoint upPoint1 = CGPointMake(0, 0);
    CGPoint upPoint2 = CGPointMake(upPowerWidth, 0);
    CGPoint downPoint1 = CGPointMake(0, 2);
    CGPoint downPoint2 = CGPointMake(downPowerWidth, 2);
    [self drawSignleLineWithContext:context
                             Points:@[NSStringFromCGPoint(upPoint1),NSStringFromCGPoint(upPoint2)]
                              Color:_model.klineUpColor
                          LineWidth:2];
    [self drawSignleLineWithContext:context
                             Points:@[NSStringFromCGPoint(downPoint1),NSStringFromCGPoint(downPoint2)]
                              Color:_model.klineDownColor
                          LineWidth:2];
}

//  画文本
-(void)drawTextWithContext:(CGContextRef)context Title:(NSString*)title Font:(UIFont*)font Point:(CGPoint)point{
//    if (_model.isShowText) {
        CGContextSetShouldAntialias(context, YES);
        CGContextSetFillColorWithColor(context, _model.stage.fontColor.CGColor);
        CGFloat tw = [title sizeWithFont:font].width;
        [title drawInRect:CGRectMake(point.x-tw/2, point.y, tw, _model.stage.font.pointSize) withFont:_model.stage.font];
//    }
    
 
}
//  画一根线
-(void)drawSignleLineWithContext:(CGContextRef)context Points:(NSArray*)points Color:(UIColor*)color LineWidth:(CGFloat)lineWidth{
    CGContextSetShouldAntialias(context, YES);
    CGContextSetLineWidth(context, lineWidth);
    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint point1 = CGPointFromString([points firstObject]);
    CGPoint point2 = CGPointFromString([points lastObject]);
    CGPathMoveToPoint(path, NULL, point1.x, point1.y);
    CGPathAddLineToPoint(path, NULL, point2.x, point2.y);
    CGContextAddPath(context, path);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
    CGContextStrokePath(context);
    CGPathRelease(path);
    
}

/**
 *  画圆圈
 *
 *  @param ctx         画布
 *  @param pieStart    其实角度 0-360
 *  @param pieCapacity 结束角度
 *  @param x           圆心x轴
 *  @param y           圆心y轴
 *  @param radius      半径
 *  @param color       饼状颜色
 */
-(void)paintpie:(CGContextRef)ctx
          start:(double)pieStart
       capacity:(double)pieCapacity
         pointx:(double)x
         pointy:(double)y
         radius:(CGFloat)radius
       piecolor:(UIColor *)color{
    //起始角度，0-360
    double snapshot_start = pieStart;
    //结束角度
    double snapshot_finish = pieStart+pieCapacity;
    //设置扇形填充色
    CGContextSetFillColor(ctx, CGColorGetComponents( [color CGColor]));
    //设置圆心
    CGContextMoveToPoint(ctx, x, y);
    //以90为半径围绕圆心画指定角度扇形，0表示逆时针
    CGContextAddArc(ctx, x, y, radius,  radians(snapshot_start), radians(snapshot_finish), 0);
    CGContextClosePath(ctx);
    CGContextDrawPath(ctx, kCGPathFill);
}
@end
