//
//  FMStockCompany.h
//  FMMarket
//
//  Created by dangfm on 15/10/5.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMStockChart.h"

#define kFMStockCompanyHeight 200
#define kFMStockCompanyLineHeight 35
#define kFMStockCompanyPadding 15

@class FMStockCompanyModel;

@interface FMStockCompany : UIView
@property (nonatomic,retain) FMStockCompanyModel *model;
-(void)updateWithModel:(FMStockCompanyModel*)model;
@end


@interface FMStockCompanyModel : NSObject

@property (nonatomic,retain) NSString *companyName;
@property (nonatomic,retain) NSString *marketDate;
@property (nonatomic,retain) NSString *registMoney;
@property (nonatomic,retain) NSString *plateName;
@property (nonatomic,retain) NSString *mainBusiness;
-(instancetype)initWithDic:(NSDictionary*)dic;

@end
