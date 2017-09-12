//
//  FMStockMaxMinValues.h
//  FMStockChart
//
//  Created by dangfm on 15/8/22.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMStockModel.h"

typedef struct{
    // 主视图最大值
    double FMStockTopMaxValue;
    // 主视图最小值
    double FMStockTopMinValue;
    // 副图指标最大值
    double FMStockBottomMaxValue;
    // 副图指标最小值
    double FMStockBottomMinValue;
} FMStockMaxMinValueResult;

@interface FMStockMaxMinValues : NSObject

/**
 *  设置偏移量
 *
 *  @param model 模型
 */
+(void)setOffsetWithModel:(FMStockModel*)model;
/**
 *  计算最大最小值
 *
 *  @param model 模型
 *
 *  @return 最大最小结构
 */
+(FMStockMaxMinValueResult)createWithModel:(FMStockModel*)model;

/**
 *  计算分时图最大最小值
 *
 *  @param model 模型
 *
 *  @return 最大最小值结构
 */
+(FMStockMaxMinValueResult)createMinuteWithModel:(FMStockModel *)model;

/**
 *  计算当前价格Y轴
 *
 *  @param price 当前价格
 *  @param model 模型
 *
 *  @return y轴距离
 */
+(CGFloat)topY:(CGFloat)price Model:(FMStockModel*)model;

/**
 *  计算副图指标数值的实际Y轴
 *
 *  @param price 当前指标值
 *  @param model 模型
 *
 *  @return 副图指标视图y轴距离
 */
+(CGFloat)bottomY:(CGFloat)price Model:(FMStockModel*)model;
/**
 *  MACD Y轴
 *
 *  @param price M值
 *  @param model 模型
 *
 *  @return M值对应Y轴
 */
+(CGFloat)macdBottomY:(CGFloat)price Model:(FMStockModel*)model;
@end
