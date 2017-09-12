//
//  FMEditStocksToolBar.h
//  FMMarket
//
//  Created by dangfm on 15/10/2.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMStockChart.h"

#define kFMEditStocksToolBarHeight 44

typedef void (^clickSelectButtonBlock)(int type);
typedef void (^clickDeleteButtonBlock)(void);

@interface FMEditStocksToolBar : FMBaseView

@property (nonatomic,retain) UIButton *selectButton;
@property (nonatomic,retain) UIButton *deleteButton;
@property (nonatomic,copy) clickSelectButtonBlock clickSelectButtonBlock;
@property (nonatomic,copy) clickDeleteButtonBlock clickDeleteButtonBlock;

-(void)updateViewsWithSelectedCount:(int)count;
@end
