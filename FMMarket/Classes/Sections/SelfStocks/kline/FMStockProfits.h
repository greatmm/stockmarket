//
//  FMStockProfits.h
//  FMMarket
//
//  Created by dangfm on 15/10/6.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <FMStockChart/FMStockChart.h>

#define kFMStockProfits_Height 220
#define kFMStockProfits_ChartViewsHeight 100
#define kFMStockProfits_Padding 15

@interface FMStockProfits : FMBaseView

@property (nonatomic,retain) NSString *titler;
-(instancetype)initWithFrame:(CGRect)frame datas:(NSArray*)datas;
-(void)startWithDatas:(NSArray*)datas title:(NSString*)title;
@end

@interface FMProfitModel : NSObject

@property (nonatomic,retain) NSString *title;
@property (nonatomic,assign) double incomeRate;
@property (nonatomic,assign) double profitRate;

-(instancetype)initWithDic:(NSDictionary*)dic;
@end
