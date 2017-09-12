//
//  FMStockAddButtonViews.h
//  FMMarket
//
//  Created by dangfm on 15/8/16.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^clickAddStocksButtonBlock)(void);

@interface FMStockAddButtonViews : UIView

@property (nonatomic,copy) clickAddStocksButtonBlock clickAddStocksButtonBlock;

@end
