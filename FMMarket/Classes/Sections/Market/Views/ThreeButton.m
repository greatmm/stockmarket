//
//  ThreeButton.m
//  FMMarket
//
//  Created by dangfm on 15/11/18.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "ThreeButton.h"


@implementation ThreeButton

-(instancetype)initWithFrame:(CGRect)frame{
    if (self==[super initWithFrame:frame]) {
        
        [self initViews];
    }
    return self;
}

-(void)dealloc{
    _titler = nil;
    _price = nil;
    _changeRate = nil;
    _change = nil;
}

-(void)initViews{
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = self.frame.size.width;
    CGFloat h = self.frame.size.height/3;
    if (!_titler) {
        _titler = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
        _titler.backgroundColor = [UIColor clearColor];
        _titler.textAlignment = NSTextAlignmentCenter;
        // _titler.textColor = FMBlackColor;
        _titler.font = kFont(kTopThreeFont_Title);
        _titler.text = @"--";
        [self addSubview: _titler];
    }
    if (!_price) {
        _price = [[UILabel alloc] initWithFrame:CGRectMake(x, y+h, w, h)];
        _price.backgroundColor = [UIColor clearColor];
        _price.textAlignment = NSTextAlignmentCenter;
        _price.textColor = FMRedColor;
        _price.font = kFontNumber(20);
        _price.text = @"--";
        [self addSubview: _price];
    }
    if (!_change) {
        _change = [[UILabel alloc] initWithFrame:CGRectMake(x, y+2*h, w, h-5)];
        _change.backgroundColor = [UIColor clearColor];
        _change.textAlignment = NSTextAlignmentCenter;
        _change.textColor = FMRedColor;
        _change.font = [UIFont fontWithName:kFontNumberName size:kTopThreeFont_price];
        _change.text = @"0.00";
        [self addSubview: _change];
    }
//    if (!_changeRate) {
//        _changeRate = [[UILabel alloc] initWithFrame:CGRectMake(x+w/2+3, y+2*h, w/2, h)];
//        _changeRate.backgroundColor = [UIColor clearColor];
//        _changeRate.textAlignment = NSTextAlignmentLeft;
//        _changeRate.textColor = FMRedColor;
//        _changeRate.font = [UIFont fontWithName:kFontNumberName size:kTopThreeFont_price];
//        _changeRate.text = @" / %";
//        [self addSubview: _changeRate];
//    }
    
    if (!_trade) {
        _trade = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, kTopThreeFont_Title+2)];
        _trade.backgroundColor = [UIColor clearColor];
        _trade.textAlignment = NSTextAlignmentCenter;
        _trade.font = kFont(kTopThreeFont_Title);
        _trade.text = @"";
        _trade.hidden = YES;
        [self addSubview: _trade];
    }
  
}

-(void)updateTextColor{
    NSString *oldChange = _change.text;
    _price.textColor = FMRedColor;
    _change.textColor = FMZeroColor;
    _changeRate.textColor = FMZeroColor;
    if ([oldChange floatValue] < 0) {
        _price.textColor = FMGreenColor;
        //_change.textColor = FMGreenColor;
        //_changeRate.textColor = FMGreenColor;
    }
    
    if (![_trade.text isEqualToString:@""]) {
        _price.frame = CGRectMake(_price.mj_x, _trade.mj_y+_trade.mj_h,_price.mj_w,_price.mj_h);
        [_titler sizeToFit];
        _titler.frame = CGRectMake(0, _price.mj_y + _price.mj_h, self.mj_w,kTopThreeFont_price);
        _titler.font = kFont(kTopThreeFont_price);
        
        _change.mj_y = _titler.mj_h + _titler.mj_y;
        
        //NSLog(@"%@",_change);
      
        if ([_price.text floatValue] < 0) {
            _price.textColor = FMGreenColor;
        }else{
            _price.textColor = FMRedColor;
        }
        if ([_price.text floatValue] == 0) {
            _price.textColor = FMZeroColor;
        }
    }
    
    
}

-(void)changeBgColorWithOldPrice:(NSString*)price{
    NSString *oldPrice = _price.text;
    if ([price floatValue]!=[oldPrice floatValue] && [oldPrice floatValue]>0) {
        [self createBgWithPrice:price];
    }
}

#pragma mark 闪动视图
-(void)createBgWithPrice:(NSString*)price{
    UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(3, 0, self.frame.size.width-3, self.frame.size.height)];
    [self insertSubview:bg belowSubview:_price];
    bg.layer.cornerRadius = 2;
    bg.layer.backgroundColor = FMGreenColor.CGColor;
    NSString *oldPrice = _price.text;
    if ([price floatValue]>[oldPrice floatValue] && [oldPrice floatValue]>0) {
        bg.layer.backgroundColor = FMRedColor.CGColor;
    }
    if ([price floatValue]==[oldPrice floatValue]) {
        return;
    }
    bg.layer.opacity = 0.1;
    [UIView animateWithDuration:0.3 animations:^{
        bg.layer.opacity = 0.2;
    } completion:^(BOOL isfinish){
        [UIView animateWithDuration:0.3 animations:^{
            bg.layer.opacity = 0;
        } completion:^(BOOL isfinish){
            [bg removeFromSuperview];
        }];
    }];
    bg = nil;
}

-(void)clearText{
    _titler.text = @"";
    _price.text = @"";
    _change.text = @"";
    _changeRate.text = @"";
    [self updateTextColor];
}

@end
