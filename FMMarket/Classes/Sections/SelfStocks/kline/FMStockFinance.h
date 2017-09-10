//
//  FMStockFinance.h
//  FMMarket
//
//  Created by dangfm on 15/10/6.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kFMStockFinanceHeight 200
#define kFMStockFinanceLineHeight 35
#define kFMStockFinancePadding 15

@class FMStockFinanceModel;
@interface FMStockFinance : UIView

@property (nonatomic,retain) FMStockFinanceModel *model;
-(void)updateWithModel:(FMStockFinanceModel*)model;
@end


@interface FMStockFinanceModel : NSObject

@property (nonatomic,retain) NSString *totalIncome;
@property (nonatomic,retain) NSString *totalExpenditure;
@property (nonatomic,retain) NSString *totalCost;
@property (nonatomic,retain) NSString *netProfit;
@property (nonatomic,retain) NSString *perEarnings;
@property (nonatomic,retain) NSString *otherIncome;
@property (nonatomic,retain) NSString *totalOtherIncome;
@property (nonatomic,retain) NSString *updateDate;
@property (nonatomic,retain) NSString *incomeRate;
@property (nonatomic,retain) NSString *expenditureRate;
@property (nonatomic,retain) NSString *profitRate;
-(instancetype)initWithDic:(NSDictionary*)dic;

@end
