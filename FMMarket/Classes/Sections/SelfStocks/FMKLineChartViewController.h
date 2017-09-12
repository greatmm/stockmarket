//
//  FMKLineChartViewController.h
//  FMMarket
//
//  Created by dangfm on 15/8/16.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMBaseViewController.h"

#define kFMKLineChartViewStockInfoLoopTime [FMUserDefault getSelfStockLoopTime]
#define kFMKLineChartViewMinuteChartLoopTime 30
#define kFMKLineChartViewHeight 280

@interface FMKLineChartViewController : FMBaseViewController

@property (nonatomic,retain) UILabel *signal;

/**
 *  初始化
 *
 *  @param code       股票编码 必填
 *  @param name       股票名称
 *  @param price      当前价格
 *  @param closePrice 昨收
 *
 *  @return FMKLineChartViewController
 */
-(instancetype)initWithStockCode:(NSString*)code
                       StockName:(NSString*)name
                           Price:(NSString*)price
                      ClosePrice:(NSString *)closePrice
                            Type:(NSString*)type;
@end
