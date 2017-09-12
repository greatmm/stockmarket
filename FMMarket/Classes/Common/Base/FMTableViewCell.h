//
//  FMTableViewCell.h
//  FMMarket
//
//  Created by dangfm on 15/8/8.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImage+stocking.h"

#define kTableViewCellDefaultHeight 44
#define kTableViewCellHeight 50
#define kTableViewCellLeftPadding 15
#define kTableViewCellLineHeight 0.5
#define kTableViewCellButtonWidth 80
#define kTableViewCellButtonHeight 30
#define kTableViewCellTitleFontSize 16
#define kTableViewCellCodeFontSize 10
#define kTableViewCellPriceFontSize 22
#define kTableViewCellChangeRateFontSize 16
#define kTableViewCellButtonCorner 3

@interface FMTableViewCell : UITableViewCell

@property (nonatomic,retain) UILabel *title;
@property (nonatomic,retain) UILabel *code;
@property (nonatomic,retain) UILabel *intro;
@property (nonatomic,retain) UILabel *typeIcon;
@property (nonatomic,retain) UILabel *price;
@property (nonatomic,retain) UILabel *signal;
@property (nonatomic,retain) UIButton *changeRate;
@property (nonatomic,retain) UIView *line;
@property (nonatomic,retain) UIImageView *arrow;
@property (nonatomic,retain) UIImageView *leftImageView;
@property (nonatomic,assign) CGFloat leftImageWidth;
@property (nonatomic,retain) UILabel *unReadLb;
@property (nonatomic,assign) BOOL isLast;
@property (nonatomic,assign) BOOL isCorner;
@property (nonatomic,assign) BOOL isAutoReSizeImage;


@end
