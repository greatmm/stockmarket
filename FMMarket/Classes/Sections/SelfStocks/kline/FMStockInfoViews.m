//
//  FMStockInfoViews.m
//  FMMarket
//
//  Created by dangfm on 15/8/16.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMStockInfoViews.h"
#import "UILabel+stocking.h"

@interface FMStockInfoViews()

@property (nonatomic,retain) UIView *mainBox;
@end

@implementation FMStockInfoViews

-(instancetype)initWithFrame:(CGRect)frame{
    if (self==[super initWithFrame:frame]) {
        [self initViews];
    }
    return self;
}

-(void)initViews{
    [self createFirstLineViews];
    [self createSecondLineViews];
    [self createThreeLineViews];
}

-(void)createFirstLineViews{
    
    _openPrice = [UILabel new];
    _closePrice = [UILabel new];
    _highPrice = [UILabel new];
    _lowPrice = [UILabel new];
    _volumn = [UILabel new];
    _volumnPrice = [UILabel new];
    
    
    
    self.backgroundColor = [UIColor clearColor];
    // 搞个蒙板
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, UIScreenHeight)];
    maskView.backgroundColor = [UIColor blackColor];
    maskView.alpha = 0.5;
    [self addSubview:maskView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
    [maskView addGestureRecognizer:tap];
    
    _mainBox = [[UIView alloc] initWithFrame:CGRectMake(40, 150, UIScreenWidth-80, kFMStockInfoViewHeight)];
    _mainBox.layer.cornerRadius = 3;
    _mainBox.layer.masksToBounds = YES;
    _mainBox.backgroundColor = [UIColor whiteColor];
    [self addSubview:_mainBox];
    
    UILabel *title = [UILabel createWithTitle:@"盘口信息" Frame:CGRectMake(0,0,_mainBox.frame.size.width,40)];
    title.textAlignment = NSTextAlignmentCenter;
    [_mainBox addSubview:title];
    [fn drawLineWithSuperView:_mainBox Color:FMBottomLineColor Frame:CGRectMake(20, 40, _mainBox.frame.size.width-40, 0.5)];
    
    UIButton *close = [[UIButton alloc] initWithFrame:CGRectMake(_mainBox.frame.size.width-60, 0, 60, 40)];
    [close setImage:ThemeImage(@"global/icon_stockinfo_close") forState:UIControlStateNormal];
    [close addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [_mainBox addSubview:close];
    
    CGFloat x = 20;
    CGFloat y = 50;
    CGFloat w = (_mainBox.frame.size.width-60)/2;
    CGFloat h = (_mainBox.frame.size.height-60)/6;
    NSArray *firstLine = @[@"今开",@"昨收",@"最高",@"最低",@"成交量",@"成交额"];
    NSArray *viewList = @[_openPrice,_closePrice,_highPrice,_lowPrice,_volumn,_volumnPrice];
    for (int i=0; i<firstLine.count; i++) {
        UILabel *l = [UILabel createWithTitle:[firstLine objectAtIndex:i]
                                        Frame:CGRectMake(x, y, w, h)];
        l.font = kFont(12);
        l.textColor = FMBlackColor;
        l.textAlignment = NSTextAlignmentLeft;
        [_mainBox addSubview:l];
        
        UILabel *lb = viewList[i];
        lb.frame = CGRectMake(x, y, w, h);
        lb.textAlignment = NSTextAlignmentRight;
        lb.font = kFont(kFMStockInfoViewFontSize);
        lb.text = @"-";
        [_mainBox addSubview:lb];
        lb = nil;
        l = nil;
        y += h;
//        x += w;
//        if (i<firstLine.count-1) {
//            [fn drawLineWithSuperView:_mainBox Color:FMBottomLineColor Frame:CGRectMake(x, 10, 0.5, 30)];
//        }
        
    }
 
    
}

-(void)createSecondLineViews{
    _totalValue = [UILabel new];
    _circulationValue = [UILabel new];
    _peRatio = [UILabel new];
    _cityNetRate = [UILabel new];
    _swing = [UILabel new];
    _turnoverRate = [UILabel new];
    CGFloat x = (_mainBox.frame.size.width)/2+10;
    CGFloat y = 50;
    CGFloat w = (_mainBox.frame.size.width-60)/2;
    CGFloat h = (_mainBox.frame.size.height-60)/6;
    NSArray *firstLine =  @[@"总市值",@"流通值",@"市盈率",@"市净率",@"振幅",@"换手率"];
    NSArray *viewList = @[_totalValue,_circulationValue,_peRatio,_cityNetRate,_swing,_turnoverRate];
    for (int i=0; i<firstLine.count; i++) {
        UILabel *l = [UILabel createWithTitle:[firstLine objectAtIndex:i]
                                        Frame:CGRectMake(x, y, w, h)];
        l.font = kFont(12);
        l.textColor = FMBlackColor;
        l.textAlignment = NSTextAlignmentLeft;
        [_mainBox addSubview:l];
        
        UILabel *lb = viewList[i];
        lb.frame = CGRectMake(x, y, w, h);
        lb.textAlignment = NSTextAlignmentRight;
        lb.font = kFont(kFMStockInfoViewFontSize);
        lb.text = @"-";
        [_mainBox addSubview:lb];
        lb = nil;
        l = nil;
        y += h;
        //        x += w;
        //        if (i<firstLine.count-1) {
        //            [fn drawLineWithSuperView:_mainBox Color:FMBottomLineColor Frame:CGRectMake(x, 10, 0.5, 30)];
        //        }
        
    }
}

-(void)createThreeLineViews{
//    CGFloat x = 0;
//    CGFloat y = 110;
//    CGFloat w = (_mainBox.frame.size.width)/4;
//    CGFloat h = _mainBox.frame.size.height/6;
//    NSArray *firstLine = @[@"最低",@"流通市值",@"市净率",@"成交额"];
//    for (int i=0; i<firstLine.count; i++) {
//        UILabel *l = [UILabel createWithTitle:[firstLine objectAtIndex:i]
//                                        Frame:CGRectMake(x, y, w, h)];
//        l.font = kFont(12);
//        l.textColor = FMBlackColor;
//        l.textAlignment = NSTextAlignmentCenter;
//        [_mainBox addSubview:l];
//        l = nil;
//        x += w;
//        
//    }
//    y += 30;
//    _lowPrice = [UILabel createWithTitle:@"-" Frame:CGRectMake(0, y, w, 14)];
//    _lowPrice.textAlignment = NSTextAlignmentCenter;
//    _lowPrice.font = kFontNumber(kFMStockInfoViewFontSize);
//    
//    _circulationValue = [UILabel createWithTitle:@"-" Frame:CGRectMake(w, y, w, 14)];
//    _circulationValue.textAlignment = NSTextAlignmentCenter;
//    _circulationValue.font = kFontNumber(kFMStockInfoViewFontSize);
//    
//    _cityNetRate = [UILabel createWithTitle:@"-" Frame:CGRectMake(2*w, y, w, 14)];
//    _cityNetRate.textAlignment = NSTextAlignmentCenter;
//    _cityNetRate.font = kFontNumber(kFMStockInfoViewFontSize);
//    
//    _volumnPrice = [UILabel createWithTitle:@"-" Frame:CGRectMake(3*w, y, w, 14)];
//    _volumnPrice.textAlignment = NSTextAlignmentCenter;
//    _volumnPrice.font = kFontNumber(kFMStockInfoViewFontSize);
//    
//    [_mainBox addSubview:_lowPrice];
//    [_mainBox addSubview:_circulationValue];
//    [_mainBox addSubview:_cityNetRate];
//    [_mainBox addSubview:_volumnPrice];
    //[fn drawLineWithSuperView:self Color:FMBottomLineColor Frame:CGRectMake(0, kFMStockInfoViewHeight-0.5, UIScreenWidth, 0.5)];
}

-(void)updateViewsWithModel:(FMStockInfoModel*)model{
    _model = model;
    NSArray *keys = [fn propertyKeysWithClass:[model class]];
    for (NSString *key in keys) {
        id value = [model valueForKey:key];
        if ([value floatValue]<=0) {
            [model setValue:@"-" forKey:key];
        }
    }
    _openPrice.text = [NSString stringWithFormat:@"%.2f",[model.openPrice floatValue]];
    _closePrice.text = [NSString stringWithFormat:@"%.2f",[model.closePrice floatValue]];
    float volumn = [model.volumn floatValue]/100;
    NSString *volStr = [NSString stringWithFormat:@"%.2f",volumn];
    if (volumn>9999) {
        volStr = [NSString stringWithFormat:@"%.2f 万",volumn/10000];
    }
    if (volumn>99999999) {
        volStr = [NSString stringWithFormat:@"%.2f 亿",volumn/100000000];
    }
    _volumn.text = volStr;
    model.volumnPrice = [NSString stringWithFormat:@"%.2f",[model.volumnPrice floatValue]/10000];
    NSString *dw = @"万";
    if ([model.volumnPrice floatValue]>9999) {
        dw = @"亿";
    }
    
    _volumnPrice.text = [NSString stringWithFormat:@"%.2f %@",[model.volumnPrice floatValue]>9999?[model.volumnPrice floatValue]/10000:[model.volumnPrice floatValue],dw];
    _highPrice.text = [NSString stringWithFormat:@"%.2f",[model.highPrice floatValue]];
    _lowPrice.text = [NSString stringWithFormat:@"%.2f",[model.lowPrice floatValue]];
    _totalValue.text = [NSString stringWithFormat:@"%.2f亿",[model.totalValue floatValue]];
    _circulationValue.text = [NSString stringWithFormat:@"%.2f亿",[model.circulationValue floatValue]];
    _peRatio.text = [NSString stringWithFormat:@"%.2f",[model.peRatio floatValue]];
    _cityNetRate.text = [NSString stringWithFormat:@"%.2f",[model.cityNetRate floatValue]];
    _swing.text = [NSString stringWithFormat:@"%.2f%%",[model.swing floatValue]];
    _turnoverRate.text = [NSString stringWithFormat:@"%.2f%%",[model.turnoverRate floatValue]];
    
    [self changeColorWithLb:_openPrice price:[model.closePrice floatValue]];
    [self changeColorWithLb:_highPrice price:[model.closePrice floatValue]];
    [self changeColorWithLb:_lowPrice price:[model.closePrice floatValue]];
    
}

-(void)changeColorWithLb:(UILabel*)lb price:(float)price{
    float me = [lb.text floatValue];
    if (me>price) {
        lb.textColor = FMRedColor;
    }
    if (me<price) {
        lb.textColor = FMGreenColor;
    }
    if (me==price) {
        lb.textColor = FMBlackColor;
    }
}

-(void)show{
    WEAKSELF
    //    self.transform = CGAffineTransformMakeScale(0, 0);
    self.hidden = NO;
    //    [UIView animateWithDuration:0.5 animations:^{
    //        __weakSelf.transform = CGAffineTransformMakeScale(1, 1);
    //    } completion:^(BOOL finished){
    //    }];
}
-(void)hide{
    self.hidden = YES;
    //    WEAKSELF
    //    [UIView animateWithDuration:0.5 animations:^{
    //        __weakSelf.transform = CGAffineTransformMakeScale(0, 0);
    //    } completion:^(BOOL finished){
    //        __weakSelf.hidden = YES;
    //    }];
}
@end
