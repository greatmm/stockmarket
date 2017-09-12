//
//  FMSearchStocksTableViewCell.h
//  FMMarket
//
//  Created by dangfm on 15/8/14.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMSelfStockTableViewCell.h"


@interface FMSearchStocksTableViewCell : FMSelfStockTableViewCell
@property (nonatomic,retain) UIButton *addButton;
@property (nonatomic,retain) UILabel *addText;
@property (nonatomic,retain) FMStocksModel *model;
-(void)setContent:(FMStocksModel *)model;
@end
