//
//  UIButton+stocking.m
//  FMMarket
//
//  Created by dangfm on 15/8/9.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "UIButton+stocking.h"

@implementation UIButton (stocking)

+(UIButton*)createWithTitle:(NSString*)title Frame:(CGRect)frame{
    //CGSize fontSize = [title sizeWithFont:kDefaultFont constrainedToSize:frame.size];
    UIButton *l = [[UIButton alloc] initWithFrame:frame];
    l.titleLabel.font = kDefaultFont;
    [l setTitleColor:FMBlackColor forState:UIControlStateNormal];
    [l setTitle:title forState:UIControlStateNormal];
    return l;
}

+(UIButton*)createButtonWithTitle:(NSString*)title Frame:(CGRect)frame{
    //CGSize fontSize = [title sizeWithFont:kDefaultFont constrainedToSize:frame.size];
    UIButton *l = [self createWithTitle:title Frame:frame];
    l.layer.cornerRadius = 3;
    l.backgroundColor = [UIColor whiteColor];
    l.layer.masksToBounds = YES;
    l.layer.borderColor = FMBottomLineColor.CGColor;
    l.layer.borderWidth = 0.5;
    return l;
}

@end
