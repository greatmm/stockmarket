//
//  FMNavigationHeaderView.h
//  FMMarket
//
//  Created by dangfm on 15/8/13.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FMNavigationHeaderView : UIView
@property (nonatomic,retain) UILabel *titler;
@property (nonatomic,retain) UIButton *backButton;
@property (nonatomic,retain) UIView *bottomline;

#pragma mark 初始化
-(instancetype)initWithFrame:(CGRect)frame title:(NSString*)title isBack:(BOOL)isback;
#pragma mark 背景变化
-(void)changeViewBackgroundColor:(UIColor*)color titleColor:(UIColor *)titleColor;
@end
