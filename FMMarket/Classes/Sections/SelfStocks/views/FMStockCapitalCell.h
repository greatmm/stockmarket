//
//  FMStockCapitalCell.h
//  FMMarket
//
//  Created by dangfm on 15/10/7.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMTableViewCell.h"
@class FMStockCapitalModel;
@interface FMStockCapitalCell : FMTableViewCell

-(void)setContent:(FMStockCapitalModel*)model;
@end
