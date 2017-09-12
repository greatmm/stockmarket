//
//  FMKLineScrollView.h
//  FMStockChart
//
//  Created by dangfm on 15/8/21.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMStockModel.h"

@interface FMKLineScrollView : UIScrollView

@property (nonatomic,retain) FMStockModel *model;
@property (nonatomic,retain) CAShapeLayer *shapeLayer;

-(void)setNeedsDisplayWithModel:(FMStockModel*)model;
@end
