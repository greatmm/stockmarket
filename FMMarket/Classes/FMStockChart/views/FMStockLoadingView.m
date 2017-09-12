//
//  FMStockLoadingView.m
//  FMStockChart
//
//  Created by dangfm on 15/8/21.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMStockLoadingView.h"

@implementation FMStockLoadingView

+(FMStockLoadingView*)showWithSuperView:(UIView*)superView{
    CGRect frame = superView.frame;
    CGFloat x = (frame.size.width - fmFMStockLoadingViewWidth) / 2;
    CGFloat y = (frame.size.height - fmFMStockLoadingViewHeight) / 2;
    FMStockLoadingView *view = (FMStockLoadingView*)[superView viewWithTag:fmFMStockLoadingViewTag];
    if (!view) {
        view = [[FMStockLoadingView alloc] initWithFrame:CGRectMake(x, y,
                                                                    fmFMStockLoadingViewWidth,
                                                                    fmFMStockLoadingViewHeight)];
        view.tag = fmFMStockLoadingViewTag;
        [superView addSubview:view];
    }
    [view performSelector:@selector(start) withObject:nil afterDelay:0.1];
    return view;
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self==[super initWithFrame:frame]) {
        [self initViews];
    }
    return self;
}

-(void)initViews{
    self.layer.borderColor = fmFMStockLoadingViewBorderColor.CGColor;
    self.layer.borderWidth = fmFMStockLoadingViewBorderWidth;
    
    if (!_titler) {
        _titler = [[UILabel alloc] init];
        _titler.font = [UIFont systemFontOfSize:fmFMStockLoadingViewFontSize];
        _titler.textColor = fmFMStockLoadingViewFontColor;
        [self addSubview:_titler];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickLoadingViewHandle:)];
    [self addGestureRecognizer:tap];
    tap = nil;
    
    
}

-(void)start{
    [self updateViews];
}

-(void)updateViews{
    if (!_activity){
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activity.color = fmFMStockLoadingViewLoadingColor;
        _activity.hidesWhenStopped = NO;
        [self addSubview:_activity];
    }
    CGFloat padding = 10;
    CGFloat w = _activity.frame.size.width + padding;
    CGFloat textWidth = [fmFMStockLoadingViewDefaultTitle sizeWithFont:_titler.font].width;
    w += textWidth;
    _titler.text = fmFMStockLoadingViewDefaultTitle;
    [_titler sizeToFit];
    CGFloat x = (self.frame.size.width - w) / 2;
    CGFloat y = (self.frame.size.height - _activity.frame.size.height) / 2;
    _activity.frame = CGRectMake(x, y, _activity.frame.size.width, _activity.frame.size.height);
    _titler.frame = CGRectMake(x+_activity.frame.size.width+padding,
                               (self.frame.size.height-_titler.frame.size.height)/2,
                               _titler.frame.size.width,
                               _titler.frame.size.height);
    [_activity setHidden:NO];
    [_activity startAnimating];
    [self performSelector:@selector(timeout) withObject:nil afterDelay:fmFMStockLoadingViewTimeout];
}

-(void)timeout{
    _titler.text = fmFMStockLoadingViewTimeoutTitle;
    [_activity stopAnimating];
    [_activity setHidden:YES];
    _titler.textAlignment = NSTextAlignmentCenter;
    _titler.frame = self.bounds;
    
}

-(void)clickLoadingViewHandle:(UITapGestureRecognizer*)tap{
    if (_clickFMStockLoadingViewBlock) {
        _clickFMStockLoadingViewBlock();
    }
}

-(void)timeoutRunBlock:(ClickFMStockLoadingViewBlock)block{
    [self timeout];
    if (block) {
        _clickFMStockLoadingViewBlock = block;
    }
}

+(void)removeFromSuperView:(UIView*)superView{
    FMStockLoadingView *view = (FMStockLoadingView*)[superView viewWithTag:fmFMStockLoadingViewTag];
    if (view) {
        [view removeFromSuperview];
    }
}

+(void)timeoutWithSuperView:(UIView*)superView block:(ClickFMStockLoadingViewBlock)block{
    FMStockLoadingView *view = (FMStockLoadingView*)[superView viewWithTag:fmFMStockLoadingViewTag];
    if (view) {
        [view timeoutRunBlock:block];
    }
}
@end
