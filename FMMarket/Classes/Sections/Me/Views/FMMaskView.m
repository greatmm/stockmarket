//
//  FMMaskView.m
//  FMMarket
//
//  Created by dangfm on 16/1/13.
//  Copyright © 2016年 dangfm. All rights reserved.
//

#import "FMMaskView.h"

#define kFMMaskViewTag 234098222

@implementation FMMaskView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _alpha = 0.5;
        
        [self initViews];
    }
    return self;
}


- (id)initWithAlpha:(CGFloat)alpha Height:(int)height
{
    self = [super init];
    if (self) {
        _alpha = alpha;
        _h = height;
        [self initViews];
    }
    return self;
}

-(void)dealloc{
    self.sportView = nil;
    self.mainBody = nil;
    self.hideFinishBlock = nil;
}

-(void)initViews{
    self.tag = kFMMaskViewTag;
    if (_h<=0) {
        _h = 220;
    }
    self.frame = CGRectMake(0, 0, UIScreenWidth, UIScreenHeight);
    self.backgroundColor = [UIColor clearColor];
    if (!self.sportView) {
        CGFloat h = _h;
        CGFloat w = self.frame.size.width;
        CGFloat y = self.frame.size.height + h;
        CGFloat x = 0;
        
        self.mainBody = [[UIView alloc] initWithFrame:self.frame];
        self.mainBody.alpha = _alpha;
        self.mainBody.backgroundColor = [UIColor blackColor];
        [self addSubview:self.mainBody];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        [self.mainBody addGestureRecognizer:tap];
        tap = nil;
        
        self.sportView = [[UIView alloc] initWithFrame:CGRectMake(x,y,w,h)];
        self.sportView.backgroundColor = UIColorFromRGB(0xFFFFFF);
        [self addSubview:self.sportView];
        
    }
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

-(void)show:(void (^)(void))animations{
    CGRect frame = self.sportView.frame;
    frame.origin.y = UIScreenHeight - _h;
    [UIView animateWithDuration:0.5 animations:^{
        self.sportView.frame = frame;
        self.mainBody.alpha = _alpha;
    } completion:^(BOOL finish){
        if (animations) {
            animations();
        }
    }];
}

-(void)hide{
    CGRect frame = self.sportView.frame;
    frame.origin.y = UIScreenHeight + _h;
    [UIView animateWithDuration:0.5 animations:^{
        self.sportView.frame = frame;
        self.mainBody.alpha = 0;
    } completion:^(BOOL finish){
        [self removeFromSuperview];
        if (self.hideFinishBlock) {
            self.hideFinishBlock();
        }
        
    }];
}

+(void)hide{
    FMMaskView *me = [[UIApplication sharedApplication].keyWindow viewWithTag:kFMMaskViewTag];
    if (me) {
        [me hide];
    }
}

@end
