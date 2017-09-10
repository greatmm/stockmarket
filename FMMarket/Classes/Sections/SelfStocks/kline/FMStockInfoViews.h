//
//  FMStockInfoViews.h
//  FMMarket
//
//  Created by dangfm on 15/8/16.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMStockInfoModel.h"

#define kFMStockInfoViewHeight 220
#define kFMStockInfoViewFontSize 12


@interface FMStockInfoViews : UIView

@property (nonatomic,retain) UILabel *openPrice;            // 开盘价
@property (nonatomic,retain) UILabel *closePrice;           // 昨收
@property (nonatomic,retain) UILabel *volumn;               // 成交量
@property (nonatomic,retain) UILabel *volumnPrice;          // 成交额
@property (nonatomic,retain) UILabel *turnoverRate;         // 换手率
@property (nonatomic,retain) UILabel *highPrice;            // 最高价
@property (nonatomic,retain) UILabel *lowPrice;             // 最低价
@property (nonatomic,retain) UILabel *circulationValue;     // 流通市值
@property (nonatomic,retain) UILabel *totalValue;           // 总市值
@property (nonatomic,retain) UILabel *peRatio;              // 市盈率
@property (nonatomic,retain) UILabel *cityNetRate;          // 市净率
@property (nonatomic,retain) UILabel *swing;                // 振幅
@property (nonatomic,retain) FMStockInfoModel *model;                // 振幅

-(void)updateViewsWithModel:(FMStockInfoModel*)model;
-(void)show;
-(void)hide;
@end
