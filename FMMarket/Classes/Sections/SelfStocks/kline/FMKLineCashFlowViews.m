//
//  FMKLineCashFlowViews.m
//  FMMarket
//
//  Created by dangfm on 15/9/1.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMKLineCashFlowViews.h"
#import "UIImage+stocking.h"

@implementation FMCashFlowModel

@end

@interface FMKLineCashFlowViews(){
    NSArray *_datas;
    UIButton *_intro;
    NSMutableDictionary *_points;
}

@end

//把角度转换为弧度的计算公式
static inline float radians(double degrees) { return degrees * M_PI / 180; }

@implementation FMKLineCashFlowViews

-(instancetype)initWithFrame:(CGRect)frame withDatas:(NSArray*)datas{
    if (self==[super initWithFrame:frame]) {
        _datas = datas;
        [self initParams];
    }
    return self;
}

+(Class)layerClass{
    return [CAShapeLayer class];
}

-(void)initParams{
    self.backgroundColor = [UIColor clearColor];
    _points = [NSMutableDictionary new];
}

-(void)startWithDatas:(NSArray*)datas{
    _datas = datas;
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, YES);
    double start = 0;
    double capacity = 0;
    double x = self.frame.size.width/2;
    double y = self.frame.size.height/2;
    [_points removeAllObjects];
    for (FMCashFlowModel* model in _datas) {
        if (model.percent<=0) {
            continue;
        }
        capacity = model.percent * 360;
        
        [self paintpie:context start:start capacity:capacity pointx:x pointy:y radius:kFMKLineCashFlow_CryRadius piecolor:model.color];
        [self drawTextWithContext:context start:start capacity:capacity pointx:x pointy:y radius:kFMKLineCashFlow_CryRadius model:model];
        start += capacity;
    }
   
    [self createIntroView];
}

/**
 *  画饼状
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
    //设置线条颜色
    CGContextSetStrokeColor(ctx, CGColorGetComponents(FMGreyColor.CGColor));
    //设置线条粗细
    CGContextSetLineWidth(ctx, 1);
    //设置圆心
    CGContextMoveToPoint(ctx, x, y);
    //以90为半径围绕圆心画指定角度扇形，0表示逆时针
    CGContextAddArc(ctx, x, y, radius,  radians(snapshot_start), radians(snapshot_finish), 0);
    CGContextClosePath(ctx);
    CGContextDrawPath(ctx, kCGPathFill);
}

-(void)drawTextWithContext:(CGContextRef)context
                     start:(double)pieStart
                  capacity:(double)pieCapacity
                    pointx:(double)x
                    pointy:(double)y
                    radius:(CGFloat)radius
                     model:(FMCashFlowModel*)m{
    
    
    CGPoint point = [self pointForAngle:(pieCapacity/2+pieStart) pointx:x pointy:y radius:radius+5];
    CGPoint margPoint = [self pointForAngle:(pieCapacity/2+pieStart) pointx:x pointy:y radius:radius+30];
    NSString *title = m.title;
    NSDictionary *attr = @{NSFontAttributeName:kFMKLineCashFlow_TextFont,NSForegroundColorAttributeName:kFMKLineCashFlow_TextColor};
    
    // 画尖头线
    CGFloat lw = 10;
    CGFloat x1 = point.x;
    CGFloat y1 = point.y;
    CGFloat x2 = margPoint.x;
    CGFloat y2 = margPoint.y;
    CGFloat x3 = margPoint.x+lw;
    CGFloat y3 = margPoint.y;
    for (NSString *item in _points.allValues) {
        CGPoint p = CGPointFromString(item);
        if (fabs(p.y-y3)<20 && fabs(p.x-x3)<20) {
            if (p.y<y3) {
                y2 += 50;
                y3 += 50;
            }else{
                y2 -= 50;
                y3 -= 50;
            }
        }
    }
    
    [_points setObject:NSStringFromCGPoint(CGPointMake(x3, y3)) forKey:m.title];
    if (point.x<x) {
        // 圆心的左边
        x3 = x3-2*lw;
    }
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, x1, y1);
    CGPathAddLineToPoint(path, NULL, x2, y2);
    CGPathAddLineToPoint(path, NULL, x3, y3);
    CGContextAddPath(context, path);
    CGContextSetStrokeColorWithColor(context,m.color.CGColor);
    CGContextStrokePath(context);
    CGPathRelease(path);
    // 画个小圆圈
    [self paintpie:context start:0 capacity:360 pointx:x3 pointy:y3 radius:2 piecolor:m.color];
    
    CGPoint txtPoint = CGPointMake(x3+5, y3-10);
    CGFloat th = [title sizeWithAttributes:attr].height;
    txtPoint.y = txtPoint.y - th;
    if (txtPoint.x<x) {
        // 圆心的左边
        txtPoint.x = txtPoint.x - [title sizeWithAttributes:attr].width - 10;
        
    }
    [title drawAtPoint:txtPoint withAttributes:attr];
    // 百分比
    NSString *present = [NSString stringWithFormat:@"%.1f%%",m.percent*100];
    attr = @{NSFontAttributeName:kFontNumberBold(18),NSForegroundColorAttributeName:m.color};
    txtPoint = CGPointMake(txtPoint.x, txtPoint.y+th);
    [present drawAtPoint:txtPoint withAttributes:attr];
    th = [present sizeWithAttributes:attr].height;
    // 简介
    NSString *info = m.info;
    attr = @{NSFontAttributeName:kFMKLineCashFlow_TextFont,NSForegroundColorAttributeName:kFMKLineCashFlow_TextColor};
    txtPoint = CGPointMake(txtPoint.x, txtPoint.y+th);
    [info drawAtPoint:txtPoint withAttributes:attr];
}

/**
 *  以正东面为0度起点计算指定角度所对应的圆周上的点的坐标：
 *
 *  @param angle  角度
 *  @param x      圆心x
 *  @param y      圆心y
 *  @param radius 半径
 *
 *  @return 圆周对应点坐标
 */
-(CGPoint)pointForAngle:(CGFloat)angle
                 pointx:(double)x
                 pointy:(double)y
                 radius:(CGFloat)radius{
    float radian = radians(angle);
    float px = x + cos(radian)*radius;
    float py = y + sin(radian)*radius;
    CGPoint point = CGPointMake(px, py);
    return point;
}

-(void)createIntroView{
    if (!_intro) {
        CGFloat w = 50;
        _intro = [[UIButton alloc] initWithFrame:CGRectMake((self.frame.size.width-w)/2,
                                                           (self.frame.size.height-w)/2,
                                                           w, w)];
        [_intro setTitle:@"今日\n资金" forState:UIControlStateNormal];
        [_intro setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _intro.titleLabel.font = kFont(12);
        _intro.titleLabel.numberOfLines = 0;
        _intro.backgroundColor = [UIColor clearColor];
        _intro.layer.masksToBounds = YES;
        _intro.layer.cornerRadius = w/2;
        [_intro setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:1 alpha:0.3] andSize:_intro.frame.size] forState:UIControlStateNormal];
        [_intro setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithWhite:1 alpha:0.3] andSize:_intro.frame.size] forState:UIControlStateHighlighted];
        [self addSubview:_intro];
    }
}
@end
