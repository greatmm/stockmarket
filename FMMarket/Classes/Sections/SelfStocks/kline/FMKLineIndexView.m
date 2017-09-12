//
//  FMKLineIndexView.m
//  FMMarket
//
//  Created by dangfm on 15/9/18.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMKLineIndexView.h"
#import "UIImage+stocking.h"
@interface FMKLineIndexView(){
    
}

@property (nonatomic,retain) NSArray *indexs;
@property (nonatomic,retain) UIScrollView *box;
@property (nonatomic,retain) NSString *type; // 股票类型 0=个股 1=指数

@end

@implementation FMKLineIndexView

-(void)dealloc{
    NSLog(@"FMKLineIndexView dealloc");
}

-(instancetype)initWithFrame:(CGRect)frame type:(NSString*)type{
    if (self==[super initWithFrame:frame]) {
        _type = type;
        [self initParams];
        [self createViews];
    }
    return self;
}

-(void)initParams{
    _indexs = (NSArray*)ThemeJson(@"stockindexs");
}

-(void)createViews{
    
    self.backgroundColor = [UIColor whiteColor];
    _box = [[UIScrollView alloc] initWithFrame:CGRectMake(4, 0, self.frame.size.width-8, self.frame.size.height-10)];
    _box.layer.borderColor = FMBottomLineColor.CGColor;
    _box.layer.borderWidth = 0.5;
    _box.backgroundColor = [UIColor whiteColor];
    [self addSubview:_box];
    CGFloat w = _box.frame.size.width;
    CGFloat h = _box.frame.size.height/(_indexs.count-1);
    CGFloat x = 0;
    CGFloat y = 0;
    int startIndex = 0;
    if ([_type intValue]>0) {
        // startIndex = 3;
        h = 30;
    }
    for (int i=startIndex; i<_indexs.count; i++) {
        if ([_type intValue]>0) {
            if (i==1 || i==2) {
                continue;
            }
        }
        UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
        NSDictionary *dic = [_indexs objectAtIndex:i];
        NSString *title = [dic objectForKey:@"code"];
        [bt setTitle:title forState:UIControlStateNormal];
        [bt setTitleColor:FMBlackColor forState:UIControlStateNormal];
        [bt setBackgroundImage:[UIImage imageWithColor:self.backgroundColor andSize:bt.frame.size] forState:UIControlStateHighlighted];
        bt.titleLabel.font = kFontNumber(10);
        [bt addTarget:self action:@selector(clickButtonHandle:) forControlEvents:UIControlEventTouchUpInside];
        bt.tag = i;
        [_box addSubview:bt];
        y += h;
        dic = nil;
        title = nil;
        bt = nil;
    }
    
    _box.contentSize = CGSizeMake(_box.mj_w, y);
    
}

-(void)defaultAllViews{
    for (UIButton *bt in _box.subviews) {
        if ([[bt class] isSubclassOfClass:[UIButton class]]) {
            [bt setTitleColor:FMBlackColor forState:UIControlStateNormal];
            [bt setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor] andSize:bt.frame.size] forState:UIControlStateNormal];
        }
    }
}

-(void)clickButtonHandle:(UIButton*)bt{
    NSString *code = bt.titleLabel.text;
    [self defaultAllViews];
    [bt setTitleColor:FMBlueColor forState:UIControlStateNormal];
    if (self.clickKLineHorizontalNavButtonBlock) {
        self.clickKLineHorizontalNavButtonBlock(code,(int)bt.tag);
    }
}

-(void)highlightsWithIndex:(int)index{
    [self defaultAllViews];
    if (index>=0 && index<_box.subviews.count) {
        UIButton *bt = _box.subviews[index];
        [bt setTitleColor:FMBlueColor forState:UIControlStateNormal];
    }
    
}

@end
