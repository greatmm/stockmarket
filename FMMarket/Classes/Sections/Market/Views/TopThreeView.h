//
//  TopThreeView.h
//  FMMarket
//
//  Created by dangfm on 15/11/18.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMSelfStocksModel.h"
#import "ThreeButton.h"
#define kThreeViewHeight 90
#define kThreeViewTradeHeight 90
static NSString *cacheForTopThreeDataKey = @"cacheForTopThreeDataKey";
@class TopThreeView;
@class ThreeButton;
typedef void (^ClickTopThreeButtonBlock)(TopThreeView *topview,ThreeButton *button);
@interface TopThreeView : UIView
@property (nonatomic,retain) ThreeButton *first;
@property (nonatomic,retain) ThreeButton *second;
@property (nonatomic,retain) ThreeButton *three;
@property (nonatomic,retain) UIScrollView *mainView;  // 滚动
@property (nonatomic,retain) NSMutableDictionary *buttons;  // button集合
@property (nonatomic,assign) BOOL isTrade;
@property (nonatomic,copy) ClickTopThreeButtonBlock clickTopThreeButtonBlock;

-(void)updateViewsWithDatas:(NSArray *)datas;
@end
