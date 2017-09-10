//
//  FMSelfStockTopViews.h
//  FMMarket
//
//  Created by dangfm on 15/8/15.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMStockInfoModel.h"
#define kStocksDapanCode @"sh000001"

#define kFMSelfStockTopViewBigFontSize 30
#define kFMSelfStockTopViewSmallFontSize 15
#define kFMSelfStockTopViewsLeftPadding 15
#define kFMSelfStockTopViewsBottomViewHeight 15
#define kFMSelfStockTopViewsHeight (91+kFMSelfStockTopViewsBottomViewHeight)

typedef void (^clickStockTopViewBlock)(FMSelfStocksModel*m);

@interface FMSelfStockTopViews : UIView

@property (nonatomic,retain) UILabel *titler;
@property (nonatomic,retain) UILabel *change;
@property (nonatomic,retain) UILabel *changeRate;
@property (nonatomic,retain) UILabel *time;
@property (nonatomic,retain) UIImageView *bg;
@property (nonatomic,retain) UILabel *codeName;
@property (nonatomic,retain) UILabel *code;
@property (nonatomic,retain) UILabel *openPrice;
@property (nonatomic,retain) UILabel *closePrice;
@property (nonatomic,retain) UILabel *highPrice;
@property (nonatomic,retain) UILabel *lowPrice;
@property (nonatomic,retain) UILabel *volumn;
@property (nonatomic,retain) UILabel *peRatio;
@property (nonatomic,retain) UILabel *turnoverRate;
@property (nonatomic,retain) UILabel *circulationValue;
@property (nonatomic,retain) FMSelfStocksModel *model;
@property (nonatomic,copy) clickStockTopViewBlock clickStockTopViewBlock;

-(void)changeBgBackgroundColor:(UIColor*)color;
-(void)updateViewsWithModel:(FMSelfStocksModel*)model infoModel:(FMStockInfoModel*)info;
@end
