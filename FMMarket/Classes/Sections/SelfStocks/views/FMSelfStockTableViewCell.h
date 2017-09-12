//
//  FMSelfStockTableViewCell.h
//  FMMarket
//
//  Created by dangfm on 15/8/8.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMTableViewCell.h"
#import "FMSelfStocksModel.h"

@interface FMSelfStockTableViewCell : FMTableViewCell

@property (nonatomic,retain) UIView *changeBackgound;
-(void)setContent:(FMSelfStocksModel*)model;
@end
