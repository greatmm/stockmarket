//
//  FMKLineChartTabBar.m
//  FMMarket
//
//  Created by dangfm on 15/8/18.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMKLineChartTabBar.h"

@implementation FMKLineChartTabBar

-(void)dealloc{
    NSLog(@"FMKLineChartTabBar dealloc");
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self==[super initWithFrame:frame]) {
        _isMove = YES;
        [self initViews];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame Titles:(NSArray*)titles{
    if (self==[super initWithFrame:frame]) {
        _isMove = YES;
        _titles = titles;
        [self initViews];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame Titles:(NSArray*)titles superView:(UIView *)superView{
    if (self==[super initWithFrame:frame]) {
        _isMove = YES;
        _titles = titles;
        _superView = superView;
        [self initViews];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame Titles:(NSArray*)titles IsMove:(BOOL)isMove{
    if (self==[super initWithFrame:frame]) {
        _isMove = isMove;
        _titles = titles;
        [self initViews];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame Titles:(NSArray*)titles IsMove:(BOOL)isMove showCounts:(int)showCounts{
    if (self==[super initWithFrame:frame]) {
        _isMove = isMove;
        _titles = titles;
        _showCounts = showCounts;
        [self initViews];
    }
    return self;
}

-(void)free{
    [_moreViews removeFromSuperview];
}

-(void)reloadViews{
    [_moreViews removeFromSuperview];
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self initViews];
}

-(void)initViews{
    if (_showCounts<=0) {
        _showCounts = 5;
    }
    if (!_titles) {
        _titles = kFMKLineChartTabBarTitles;
    }
    self.backgroundColor = [UIColor whiteColor];
    self.autoresizesSubviews = YES;
    _box = [[UIScrollView alloc] initWithFrame:self.bounds];
    _box.autoresizingMask = UIViewAutoresizingFlexibleWidth;;
    _box.autoresizesSubviews = YES;
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat h = self.frame.size.height;
    NSInteger max = _showCounts;
    // 横屏显示完
    if (UIScreenWidth>UIScreenHeight) {
        max = _titles.count;
    }
    CGFloat w = self.frame.size.width/max;
    
    NSInteger i=0;
    for (NSString *name in _titles) {
        if (i>=max) {
            continue;
        }
        UIButton *l = [[UIButton alloc] initWithFrame:CGRectMake(x, y , w, h)];
        l.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        l.titleLabel.font = kFont(14);
        [l setTitle:name forState:UIControlStateNormal];
        [l setTitleColor:FMBlackColor forState:UIControlStateNormal];
        [_box addSubview:l];
        l.tag = i;
        [l addTarget:self
              action:@selector(clickTabBarHandle:)
    forControlEvents:UIControlEventTouchUpInside];
        l = nil;
        x += w;
        i++;
    }
    [self addSubview:_box];
    // 更多界面
    if (_titles.count>max) {
        float moreCount = _titles.count - max+1;
        float height = moreCount * self.frame.size.height;
        _moreViews = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width-w, 80 + self.frame.size.height+5, w-5, height)];
        _moreViews.backgroundColor = FMGreyColor;
        _moreViews.layer.masksToBounds = YES;
        _moreViews.hidden = YES;
        // 放到窗口中
        //        [[UIApplication sharedApplication].keyWindow addSubview:_moreViews];
        if (_superView) {
            [_superView addSubview:_moreViews];
        }
        NSInteger i=0;
        x = 0;
        y = 0;
        w = _moreViews.frame.size.width;
        for (NSString *name in _titles) {
            if (i<max-1) {
                i++;
                continue;
            }
            UIButton *l = [[UIButton alloc] initWithFrame:CGRectMake(x, y , w, h)];
            l.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            l.titleLabel.font = kFont(14);
            [l setTitle:name forState:UIControlStateNormal];
            [l setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [_moreViews addSubview:l];
            l.tag = i;
            [l addTarget:self
                  action:@selector(clickMoreTabBarHandle:)
        forControlEvents:UIControlEventTouchUpInside];
            l = nil;
            y += h;
            i++;
        }
    }
    
    UIView *lt = [fn drawLineWithSuperView:self Color:FMBottomLineColor Location:0];
    lt.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UIView *lb = [fn drawLineWithSuperView:self Color:FMBottomLineColor Location:1];
    lb.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _line = [fn drawLineWithSuperView:self
                                Color:FMBlueColor
                                Frame:CGRectMake(0, h-kFMKLineChartTabBarLineHeight, 0, kFMKLineChartTabBarLineHeight)];
    _line.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    if (_lastSelectIndex>=max) {
        [self clickMoreTabBarHandle:_moreViews.subviews[_lastSelectIndex-max+1]];
    }else{
        [self clickTabBarHandle:_box.subviews[_lastSelectIndex]];
    }
}

-(void)clickTabBarHandle:(UIButton*)bt{
    if (![[bt class] isSubclassOfClass:[UIButton class]]) {
        return;
    }
    if ([[bt titleForState:UIControlStateNormal] isEqualToString:@""]) {
        return;
    }
    
    _moreViews.hidden = YES;
    if (UIScreenWidth<UIScreenHeight && bt.tag<_titles.count-1) {
        
        if (bt.tag==_showCounts-1 && _moreViews.hidden) {
            _moreViews.hidden = NO;
            return;
        }else if (bt.tag==_showCounts-1 && !_moreViews.hidden){
            _moreViews.hidden = YES;
            return;
        }
    }
    
    
    FMStockChartType tag = (FMStockChartType)bt.tag;
    
    [self updateHighlightsTitleWithIndex:tag];
    
    if (self.clickChartTabBarButtonHandle) {
        self.clickChartTabBarButtonHandle(tag);
    }else{
        if ([self.delegate respondsToSelector:@selector(FMKLineChartTabBarClickButton:)]) {
            [self.delegate FMKLineChartTabBarClickButton:tag];
        }
    }
    
    _lastSelectIndex = tag;
}

-(void)clickMoreTabBarHandle:(UIButton*)bt{
    if (![[bt class] isSubclassOfClass:[UIButton class]]) {
        return;
    }
    if ([[bt titleForState:UIControlStateNormal] isEqualToString:@""]) {
        return;
    }
    
    FMStockChartType tag = (FMStockChartType)bt.tag;
    
    [self updateHighlightsTitleWithIndex:_showCounts-1];
    
    if (self.clickChartTabBarButtonHandle) {
        self.clickChartTabBarButtonHandle(tag);
    }else{
        if ([self.delegate respondsToSelector:@selector(FMKLineChartTabBarClickButton:)]) {
            [self.delegate FMKLineChartTabBarClickButton:tag];
        }
    }
    
    // 隐藏
    _moreViews.hidden = YES;
    
    // 设置第四个的显示文本
    NSString *text = bt.titleLabel.text;
    UIButton *fourth = _box.subviews[_showCounts-1];
    [fourth setTitle:text forState:UIControlStateNormal];
    
    _lastSelectIndex = tag;
}

-(void)updateHighlightsTitleWithIndex:(NSInteger)index{
    NSArray *views = _box.subviews;
    if (index>=views.count) {
        return;
    }
    UIButton *bt = [views objectAtIndex:index];
    for (UIButton *l in views) {
        if ([[l class] isSubclassOfClass:[UIButton class]]) {
            [l setTitleColor:FMBlackColor forState:UIControlStateNormal];
        }
    }
    
    if (![[bt class] isSubclassOfClass:[UIButton class]]) {
        return;
    }
    
    if (_isMove) {
        [bt setTitleColor:FMBlueColor forState:UIControlStateNormal];
        CGFloat w = [bt.titleLabel.text
                     sizeWithAttributes:@{NSFontAttributeName:bt.titleLabel.font}].width;
        [UIView animateWithDuration:0.2 animations:^{
            _line.frame = CGRectMake((bt.frame.size.width-w)/2+bt.frame.origin.x,
                                     _line.frame.origin.y,
                                     w,
                                     _line.frame.size.height);
        }];
    }
    
}

@end
