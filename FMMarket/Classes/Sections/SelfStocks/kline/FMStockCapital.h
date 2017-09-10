//
//  FMStockCapital.h
//  FMMarket
//
//  Created by dangfm on 15/10/7.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kFMStockCapitalHeight 48*kTableViewCellDefaultHeight

typedef void(^whenFinishedLoadDatasBlock)(void);

@interface FMStockCapital : UIView
@property (nonatomic,assign) float height;
@property (nonatomic,copy) whenFinishedLoadDatasBlock whenFinishedLoadDatasBlock;
@end

@interface FMStockCapitalModel : NSObject

@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *avg_price;
@property (nonatomic,retain) NSString *avg_changeratio;
@property (nonatomic,retain) NSString *turnover;
@property (nonatomic,retain) NSString *inamount;
@property (nonatomic,retain) NSString *outamount;
@property (nonatomic,retain) NSString *netamount;
@property (nonatomic,retain) NSString *ratioamount;
@property (nonatomic,retain) NSString *ts_symbol;
@property (nonatomic,retain) NSString *ts_name;
@property (nonatomic,retain) NSString *ts_trade;
@property (nonatomic,retain) NSString *ts_changeratio;
@property (nonatomic,retain) NSString *ts_ratioamount;
@property (nonatomic,retain) NSString *category;
@property (nonatomic,retain) NSString *cate_type;


-(instancetype)initWithDic:(NSDictionary*)dic;

@end
