//
//  FMMarketTableSection.m
//  FMMarket
//
//  Created by dangfm on 15/11/19.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMMarketTableSection.h"
#import "UIImage+stocking.h"

@implementation FMMarketTableSection

-(instancetype)initWithFrame:(CGRect)frame title:(NSString*)title typeCode:(NSString*)typeCode{
    if (self==[super initWithFrame:frame]) {
        _title = title;
        _typeCode = typeCode;
        _isSpread = NO;
        [self createViews];
    }
    return self;
}

-(void)createViews{
    self.backgroundColor = FMBgGreyColor;
    //[fn drawLineWithSuperView:self Color:FMBottomLineColor Location:1];
    _titleLb = [UILabel createWithTitle:_title Frame:CGRectMake(kFMMarketTableSectionPadding,
                                                                0, UIScreenWidth-2*
                                                                kFMMarketTableSectionPadding,
                                                                self.frame.size.height)];
    _titleLb.font = kFont(14);
    [self addSubview:_titleLb];
    // 左边伸展箭头
    UIImage *moreIcon = ThemeImage(@"global/icon_more_bg");
    moreIcon = [UIImage imageWithTintColor:FMBlackColor
                                 blendMode:kCGBlendModeDestinationIn
                           WithImageObject:moreIcon];
    _moreBt = [[UIButton alloc] initWithFrame:CGRectMake(UIScreenWidth-15-moreIcon.size.width, 0,
                                                         moreIcon.size.width,
                                                         self.frame.size.height)];
    [_moreBt setImage:moreIcon forState:UIControlStateNormal];
    [self addSubview:_moreBt];
    
//    UIImage *icon = ThemeImage(@"home/icon_fire");
//    icon = [UIImage imageWithTintColor:FMRedColor blendMode:kCGBlendModeDestinationIn WithImageObject:icon];
    // icon = [UIImage imageByScalingAndCroppingForSourceImage:icon targetSize:CGSizeMake(30, 30)];
    UIImageView *leftIcon = [[UIImageView alloc] initWithFrame:CGRectMake(8, 11, 3, 15)];
    leftIcon.backgroundColor = FMRedColor;
    [self addSubview:leftIcon];
}
@end
