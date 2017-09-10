//
//  FMSelfStockSecionView.h
//  FMMarket
//
//  Created by dangfm on 15/8/15.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kFMSelfStockSectionViewHeight 40
#define kFMSelfStockSectionLeftPadding 15
#define kFMSelfStockSectionStockClassNames @[@"全部自选",@"沪深",@"港股",@"美股"]
#define kFMSelfStockSectionStockPricesNames @[@"最新价",@"最新价",@"最新价"]
#define kFMSelfStockSectionStockChangeRateNames @[@"涨跌幅",@"涨跌幅",@"涨跌幅"]
#define kFMSelfStockSectionStockImages @[ThemeImage(@"global/selfstocks_icon_corner_normal"),ThemeImage(@"global/selfstocks_icon_downarrow_normal"),ThemeImage(@"global/selfstocks_icon_uparrow_normal")]

@interface FMSelfStockSecionView : UIView

@property (nonatomic,retain) UIButton *firstButton;
@property (nonatomic,retain) UIButton *priceButton;
@property (nonatomic,retain) UIButton *changeRateButton;
@end
