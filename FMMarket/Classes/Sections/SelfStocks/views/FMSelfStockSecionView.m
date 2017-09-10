//
//  FMSelfStockSecionView.m
//  FMMarket
//
//  Created by dangfm on 15/8/15.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMSelfStockSecionView.h"

@implementation FMSelfStockSecionView
-(void)dealloc{
    NSLog(@"FMSelfStockSecionView dealloc");
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self==[super initWithFrame:frame]) {
        [self createViews];
    }
    return self;
}

#pragma mark -
#pragma mark UI Create

-(void)createViews{
    self.backgroundColor = FMBgGreyColor;
    [fn drawLineWithSuperView:self Color:FMBottomLineColor Location:0];
    [fn drawLineWithSuperView:self Color:FMBottomLineColor Location:1];
    if (!_firstButton) {
        _firstButton = [[UIButton alloc]
                        initWithFrame:CGRectMake(kFMSelfStockSectionLeftPadding, 0, UIScreenWidth/4-kFMSelfStockSectionLeftPadding, kFMSelfStockSectionViewHeight)];
        _firstButton.titleLabel.font = kDefaultFont;
        _firstButton.tag = -1;
        [_firstButton addTarget:self
                         action:@selector(clickLeftTitleButtonHandle:)
               forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_firstButton];
    }
    if (!_priceButton) {
        _priceButton = [[UIButton alloc]
                        initWithFrame:CGRectMake(UIScreenWidth/4+kFMSelfStockSectionLeftPadding, 0,
                                                 UIScreenWidth/4*3-80-4*kFMSelfStockSectionLeftPadding,
                                                 kFMSelfStockSectionViewHeight)];
        _priceButton.titleLabel.font = kDefaultFont;
        _priceButton.tag = -1;
        [_priceButton addTarget:self
                         action:@selector(clickPriceButtonHandle:)
               forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_priceButton];
    }
    
    if (!_changeRateButton) {
        _changeRateButton = [[UIButton alloc]
                        initWithFrame:CGRectMake(_priceButton.frame.origin.x+_priceButton.frame.size.width, 0, UIScreenWidth-_priceButton.frame.origin.x-_priceButton.frame.size.width-kFMSelfStockSectionLeftPadding, kFMSelfStockSectionViewHeight)];
        _changeRateButton.titleLabel.font = kDefaultFont;
        _changeRateButton.tag = -1;
        [_changeRateButton addTarget:self
                         action:@selector(clickChangeRateButtonHandle:)
               forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_changeRateButton];
    }
    
    [self setFirstButtonWithTitleIndex:-1];
    [self setPriceButtonWithTitleIndex:-1];
    [self setChangeRateButtonWithTitleIndex:-1];
}

-(void)setFirstButtonWithTitleIndex:(NSInteger)index{
    index ++;
    NSArray *titles = kFMSelfStockSectionStockClassNames;
    NSArray *images = kFMSelfStockSectionStockImages;
    UIImage *img = [images firstObject];
    if (index>=titles.count) {
        index = 0;
    }
    NSString *title = [titles objectAtIndex:index];
    CGFloat width = [title sizeWithAttributes:@{NSFontAttributeName:kDefaultFont}].width+img.size.width-8;
    
    
    [_firstButton setTitle:title forState:UIControlStateNormal];
    [_firstButton setTitleColor:FMBlueColor forState:UIControlStateNormal];
    [_firstButton setImage:img forState:UIControlStateNormal];
    [_firstButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -(_firstButton.frame.size.width-width), 0, 0)];
    width += 10;
    [_firstButton setImageEdgeInsets:UIEdgeInsetsMake(kDefaultFont.pointSize/2, width-img.size.width, 0, 0)];
    _firstButton.tag = index;
}
-(void)setPriceButtonWithTitleIndex:(NSInteger)index{
    index ++;
    NSArray *titles = kFMSelfStockSectionStockPricesNames;
    NSArray *images = kFMSelfStockSectionStockImages;
    if (index>=titles.count) {
        index = 0;
    }
    UIImage *img = [images objectAtIndex:index];
    NSString *title = [titles objectAtIndex:index];
    CGFloat width = [title sizeWithAttributes:@{NSFontAttributeName:kDefaultFont}].width+img.size.width+kFMSelfStockSectionLeftPadding;
    
    [_priceButton setTitle:title forState:UIControlStateNormal];
    [_priceButton setTitleColor:FMBlueColor forState:UIControlStateNormal];
    [_priceButton setImage:img forState:UIControlStateNormal];
    [_priceButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -(_priceButton.frame.size.width-width))];
    CGFloat paddingTop = kDefaultFont.pointSize/2;
    if (index>0) {
        paddingTop = 0;
    }
    [_priceButton setImageEdgeInsets:UIEdgeInsetsMake(paddingTop, _priceButton.frame.size.width-img.size.width, 0, 0)];
    _priceButton.tag = index;
}
-(void)setChangeRateButtonWithTitleIndex:(NSInteger)index{
    index ++;
    NSArray *titles = kFMSelfStockSectionStockChangeRateNames;
    NSArray *images = kFMSelfStockSectionStockImages;
    if (index>=titles.count) {
        index = 0;
    }
    UIImage *img = [images objectAtIndex:index];
    NSString *title = [titles objectAtIndex:index];
    CGFloat width = [title sizeWithAttributes:@{NSFontAttributeName:kDefaultFont}].width+img.size.width+kFMSelfStockSectionLeftPadding;
    
    [_changeRateButton setTitle:title forState:UIControlStateNormal];
    [_changeRateButton setTitleColor:FMBlueColor forState:UIControlStateNormal];
    [_changeRateButton setImage:img forState:UIControlStateNormal];
    [_changeRateButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -(_changeRateButton.frame.size.width-width))];
    CGFloat paddingTop = kDefaultFont.pointSize/2;
    if (index>0) {
        paddingTop = 0;
    }
    [_changeRateButton setImageEdgeInsets:UIEdgeInsetsMake(paddingTop, _changeRateButton.frame.size.width-img.size.width, 0, 0)];
    _changeRateButton.tag = index;
}

#pragma mark -
#pragma mark UI Action
-(void)clickLeftTitleButtonHandle:(UIButton*)bt{
    return;
    [self setFirstButtonWithTitleIndex:bt.tag];
}
-(void)clickPriceButtonHandle:(UIButton*)bt{
    return;
    [self setPriceButtonWithTitleIndex:bt.tag];
}
-(void)clickChangeRateButtonHandle:(UIButton*)bt{
    return;
    [self setChangeRateButtonWithTitleIndex:bt.tag];
}
@end
