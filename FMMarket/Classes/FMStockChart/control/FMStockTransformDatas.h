//
//  FMStockTransformDatas.h
//  FMStockChart
//
//  Created by dangfm on 15/8/24.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMHeader.h"
#import "MKUserDefault.h"
#import "FMStockModel.h"

typedef enum {
    fmTrend_None,
    fmTrend_Up,
    fmTrend_Down
} fmBeforeDaysKDJTrendType;

@interface FMStockTransformDatas : NSObject
+(void)createWithModel:(FMStockModel*)model;
+(void)createMinuteWithModel:(FMStockModel*)model;
@end
