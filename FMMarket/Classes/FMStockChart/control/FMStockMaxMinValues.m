//
//  FMStockMaxMinValues.m
//  FMStockChart
//
//  Created by dangfm on 15/8/22.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMStockMaxMinValues.h"
#import "FMStockModel.h"
#import "FMStockDaysModel.h"
#import "FMStockMinuteModel.h"

@implementation FMStockMaxMinValues

//  计算偏移
+(void)setOffsetWithModel:(FMStockModel*)model{
    // 线的显示总量
    int pointCounts = floor((model.stage.width) / (model.klineWidth + model.klinePadding))+1;
    if (model.prices.count<=0) {
        pointCounts = 0;
    }
    if (model.offsetStart<0 || model.isReset) {
        // 数据偏移起始位置
        model.offsetStart = model.counts - pointCounts;

    }
    model.offsetEnd = model.offsetStart + pointCounts;
    
    if (model.offsetEnd>=model.prices.count) {
        model.offsetEnd = model.counts;
        model.offsetStart = model.offsetEnd - pointCounts;
    }
    if (model.offsetStart<=0) {
        model.offsetStart = 0;
    }
    if (!model.isZooming) {
        // 更新中间点位置
        int sub = (model.offsetEnd-model.offsetStart+1);
        int middleIndex = model.offsetStart+sub/2;
        model.offsetMiddle = middleIndex;
    }
    
    //NSLog(@"start:%d  end:%d",_model.offsetStart,_model.offsetEnd);
}


+(FMStockMaxMinValueResult)createWithModel:(FMStockModel *)model{
    int startIndex = model.offsetStart;
    int endIndex = model.offsetEnd;
    if (startIndex<=0) {
        startIndex = 0;
    }
    if (endIndex>=model.counts-1) {
        endIndex = model.counts - 1;
    }
    
    model.maxPrice = 0;
    model.minPrice = CGFLOAT_MAX;
    model.bottomMaxPrice = 0;
    model.bottomMinPrice = CGFLOAT_MAX;
    model.maxPower = 0;
    model.minPower = CGFLOAT_MAX;
    for (int i=startIndex;i<=endIndex;i++) {
        if (i>=model.prices.count) {
            break;
        }
        NSMutableDictionary *item = [model.prices objectAtIndex:i];
        FMStockDaysModel *mchart = [[FMStockDaysModel alloc] initWithDic:item];
        CGFloat heightPrice = [mchart.heightPrice floatValue];
        CGFloat lowPrice = [mchart.lowPrice floatValue];
        CGFloat open = [mchart.openPrice floatValue];
        CGFloat close = [mchart.closePrice floatValue];
        CGFloat SMA_N1 = [mchart.MA5 floatValue];
        CGFloat SMA_N2 = [mchart.MA10 floatValue];
        CGFloat SMA_N3 = [mchart.MA20 floatValue];
        CGFloat EMA = [mchart.EMA floatValue];
        CGFloat BOLL_DOWN = [mchart.BOLL_DOWN floatValue];
        CGFloat BOLL_MIDDLE = [mchart.BOLL_MIDDLE floatValue];
        CGFloat BOLL_UP = [mchart.BOLL_UP floatValue];
        CGFloat SAR = [mchart.SAR floatValue];
        //NSLog(@"i=%d  %f",i,lowPrice);
        // 最高最低价动态变化
        if (heightPrice>model.maxPrice && heightPrice<CGFLOAT_MAX) {
            model.maxPrice = heightPrice;
        }
        if (lowPrice<model.minPrice && lowPrice<CGFLOAT_MAX) {
            model.minPrice = lowPrice;
        }
        if (lowPrice>model.maxPrice && lowPrice<CGFLOAT_MAX) {
            model.maxPrice = lowPrice;
        }
        if (heightPrice<model.minPrice && heightPrice<CGFLOAT_MAX) {
            model.minPrice = heightPrice;
        }
        if (open>model.maxPrice && open<CGFLOAT_MAX) {
            model.maxPrice = open;
        }
        if (open<model.minPrice && open<CGFLOAT_MAX) {
            model.minPrice = open;
        }
        if (close>model.maxPrice && close<CGFLOAT_MAX) {
            model.maxPrice = close;
        }
        if (close<model.minPrice && close<CGFLOAT_MAX) {
            model.minPrice = close;
        }
        if (model.stockIndexType == FMStockIndexType_SMA) {
            if (SMA_N1>model.maxPrice && SMA_N1>0 && SMA_N1<CGFLOAT_MAX) {
                model.maxPrice = SMA_N1;
            }
            if (SMA_N1<model.minPrice && SMA_N1>0 && SMA_N1<CGFLOAT_MAX) {
                model.minPrice = SMA_N1;
            }
            if (SMA_N2>model.maxPrice && SMA_N2>0 && SMA_N2<CGFLOAT_MAX ) {
                model.maxPrice = SMA_N2;
            }
            if (SMA_N2<model.minPrice && SMA_N2>0 && SMA_N2<CGFLOAT_MAX) {
                model.minPrice = SMA_N2;
            }
            if (SMA_N3>model.maxPrice && SMA_N3>0 && SMA_N3<CGFLOAT_MAX) {
                model.maxPrice = SMA_N3;
            }
            if (SMA_N3<model.minPrice && SMA_N3>0 && SMA_N3<CGFLOAT_MAX) {
                model.minPrice = SMA_N3;
            }
        }
        if (model.stockIndexType == FMStockIndexType_EMA) {
            if (EMA>model.maxPrice && EMA<CGFLOAT_MAX) {
                model.maxPrice = EMA;
            }
            if (EMA<model.minPrice && EMA>0 && EMA<CGFLOAT_MAX) {
                model.minPrice = EMA;
            }
        }
        if (model.stockIndexType == FMStockIndexType_BOLL) {
            if (BOLL_DOWN>model.maxPrice && BOLL_DOWN<CGFLOAT_MAX) {
                model.maxPrice = BOLL_DOWN;
            }
            if (BOLL_DOWN<model.minPrice && BOLL_DOWN>0 && BOLL_DOWN<CGFLOAT_MAX) {
                model.minPrice = BOLL_DOWN;
            }
            if (BOLL_MIDDLE>model.maxPrice && BOLL_MIDDLE<CGFLOAT_MAX) {
                model.maxPrice = BOLL_MIDDLE;
            }
            if (BOLL_MIDDLE<model.minPrice && BOLL_MIDDLE>0 && BOLL_MIDDLE<CGFLOAT_MAX) {
                model.minPrice = BOLL_MIDDLE;
            }
            if (BOLL_UP>model.maxPrice && BOLL_UP<CGFLOAT_MAX) {
                model.maxPrice = BOLL_UP;
            }
            if (BOLL_UP<model.minPrice && BOLL_UP>0 && BOLL_UP<CGFLOAT_MAX) {
                model.minPrice = BOLL_UP;
            }
        }
        if (model.stockIndexType == FMStockIndexType_SAR) {
            if (SAR>model.maxPrice && SAR<CGFLOAT_MAX) {
                model.maxPrice = SAR;
            }
            if (SAR<model.minPrice && SAR>0 && SAR<CGFLOAT_MAX) {
                model.minPrice = SAR;
            }
        }
        
        
        float M = 0;
        float DIF = 0;
        float DEA = 0;
        float J = 0;
        float rsi_1 = 0;
        float rsi_2 = 0;
        float rsi_3 = 0;
        float dmi_pdi = 0;
        float dmi_mdi = 0;
        float dmi_adx = 0;
        float dmi_adxr = 0;
        float volumn = [mchart.volumn floatValue];
        M = [mchart.MACD_M floatValue];
        DIF = [mchart.MACD_DIF floatValue];
        DEA = [mchart.MACD_DEA floatValue];
        J = [mchart.KDJ_J floatValue];
        rsi_1 = [mchart.RSI_1 floatValue];
        rsi_2 = [mchart.RSI_2 floatValue];
        rsi_3 = [mchart.RSI_3 floatValue];
        float obv = [mchart.OBV_N1 floatValue];
        dmi_pdi = [mchart.DMI_PDI floatValue];
        dmi_mdi = [mchart.DMI_MDI floatValue];
        dmi_adx = [mchart.DMI_ADX floatValue];
        dmi_adxr = [mchart.DMI_ADXR floatValue];
        
        if (model.stockIndexBottomType == FMStockIndexType_VOL) {
            if (volumn>model.bottomMaxPrice && volumn<CGFLOAT_MAX) {
                model.bottomMaxPrice = volumn;
            }
            if (volumn<model.bottomMinPrice && volumn>0 && volumn<CGFLOAT_MAX) {
                model.bottomMinPrice = volumn;
            }
        }
        if (model.stockIndexBottomType == FMStockIndexType_MACD) {
            // 计算MACD的最大最小
            if (M > model.bottomMaxPrice && M<CGFLOAT_MAX) {
                model.bottomMaxPrice = M;
            }
            if (M < model.bottomMinPrice && M<CGFLOAT_MAX) {
                model.bottomMinPrice = M;
            }
            if (DIF > model.bottomMaxPrice && DIF<CGFLOAT_MAX) {
                model.bottomMaxPrice = DIF;
            }
            if (DIF < model.bottomMinPrice && DIF<CGFLOAT_MAX) {
                model.bottomMinPrice = DIF;
            }
            if (DEA > model.bottomMaxPrice && DEA<CGFLOAT_MAX) {
                model.bottomMaxPrice = DEA;
            }
            if (DEA < model.bottomMinPrice && DEA<CGFLOAT_MAX) {
                model.bottomMinPrice = DEA;
            }
        }
        if (model.stockIndexBottomType == FMStockIndexType_KDJ) {
            // 计算KDJ的最大最小值
            if (J > model.bottomMaxPrice && M<CGFLOAT_MAX) {
                model.bottomMaxPrice = J;
            }
            if (J < model.bottomMinPrice && M<CGFLOAT_MAX) {
                model.bottomMinPrice = J;
            }
        }
        if (model.stockIndexBottomType == FMStockIndexType_RSI) {
            // 计算RSI的最大最小值
            if (rsi_1>model.bottomMaxPrice && rsi_1<CGFLOAT_MAX) {
                model.bottomMaxPrice = rsi_1;
            }
            if (rsi_2>model.bottomMaxPrice && rsi_2<CGFLOAT_MAX) {
                model.bottomMaxPrice = rsi_2;
            }
            if (rsi_3>model.bottomMaxPrice && rsi_3<CGFLOAT_MAX) {
                model.bottomMaxPrice = rsi_3;
            }
            if (rsi_1<model.bottomMinPrice && rsi_1<CGFLOAT_MAX) {
                model.bottomMinPrice = rsi_1;
            }
            if (rsi_2<model.bottomMinPrice && rsi_2<CGFLOAT_MAX) {
                model.bottomMinPrice = rsi_2;
            }
            if (rsi_3<model.bottomMinPrice && rsi_3<CGFLOAT_MAX) {
                model.bottomMinPrice = rsi_3;
            }
        }
        
        if (model.stockIndexBottomType == FMStockIndexType_DMI) {
            // 计算RSI的最大最小值
            if (dmi_pdi>model.bottomMaxPrice && dmi_pdi<CGFLOAT_MAX) {
                model.bottomMaxPrice = dmi_pdi;
            }
            if (dmi_mdi>model.bottomMaxPrice && dmi_mdi<CGFLOAT_MAX) {
                model.bottomMaxPrice = dmi_mdi;
            }
            if (dmi_adx>model.bottomMaxPrice && dmi_adx<CGFLOAT_MAX) {
                model.bottomMaxPrice = dmi_adx;
            }
            if (dmi_adxr>model.bottomMaxPrice && dmi_adxr<CGFLOAT_MAX) {
                model.bottomMaxPrice = dmi_adxr;
            }
            if (dmi_pdi<model.bottomMinPrice && dmi_pdi<CGFLOAT_MAX) {
                model.bottomMinPrice = dmi_pdi;
            }
            if (dmi_mdi<model.bottomMinPrice && dmi_mdi<CGFLOAT_MAX) {
                model.bottomMinPrice = dmi_mdi;
            }
            if (dmi_adx<model.bottomMinPrice && dmi_adx<CGFLOAT_MAX) {
                model.bottomMinPrice = dmi_adx;
            }
            if (dmi_adxr<model.bottomMinPrice && dmi_adxr<CGFLOAT_MAX) {
                model.bottomMinPrice = dmi_adxr;
            }
        }
        
        if (model.stockIndexBottomType == FMStockIndexType_OBV) {
            // 计算OBV的最大最小值
            if (obv>model.bottomMaxPrice && obv<CGFLOAT_MAX) {
                model.bottomMaxPrice = obv;
            }
            if (obv<model.bottomMinPrice && obv<CGFLOAT_MAX) {
                model.bottomMinPrice = obv;
            }
        }
        
        mchart = nil;
        item = nil;
    }
    if (fabs(model.minPrice)>=CGFLOAT_MAX) {
        model.minPrice = 0;
    }
    if (model.maxPrice>=CGFLOAT_MAX) {
        model.maxPrice = 0;
    }
    if (fabs(model.bottomMinPrice)>=CGFLOAT_MAX || model.stockIndexBottomType == FMStockIndexType_VOL) {
        model.bottomMinPrice = 0;
    }
    if (model.bottomMaxPrice>=CGFLOAT_MAX) {
        model.bottomMaxPrice = 0;
    }
    
    // 加高一点
    float sub = (model.maxPrice - model.minPrice) * (10.0 / model.stage.topHeight);
    model.maxPrice += sub;
    model.minPrice -= sub;
    
    
    
    FMStockMaxMinValueResult maxMins = {model.maxPrice,model.minPrice,model.bottomMaxPrice,model.bottomMinPrice};
    //FMLog(@"maxValue=%f  minValue=%f",model.maxPrice,model.minPrice);
    return maxMins;
}

//  计算分时图
+(FMStockMaxMinValueResult)createMinuteWithModel:(FMStockModel *)model{
    // 计算线的宽度间距
    [self pointCountForMarketType:model];
    
    model.maxPrice = 0;
    model.minPrice = CGFLOAT_MAX;
    model.bottomMaxPrice = 0;
    model.bottomMinPrice = CGFLOAT_MAX;
    float i = 1.0;
    CGFloat averageTotalPrice = 0;
    CGFloat volumeTotal = 0;
    CGFloat volumePriceTotal = 0;
    for (FMStockMinuteModel *m in model.prices) {
        if ([m.price floatValue]<=0) {
            continue;
        }
        
        if ([m.price floatValue]>model.maxPrice && [m.price floatValue]<CGFLOAT_MAX) {
            model.maxPrice = [m.price floatValue];
        }
        if ([m.price floatValue]<model.minPrice && [m.price floatValue]>0 && [m.price floatValue]<CGFLOAT_MAX) {
            model.minPrice = [m.price floatValue];
        }
        
        if ([m.volumn floatValue]>model.bottomMaxPrice && [m.volumn floatValue]<CGFLOAT_MAX) {
            model.bottomMaxPrice = [m.volumn floatValue];
        }
        if ([m.volumn floatValue]<model.bottomMinPrice && [m.volumn floatValue]>0 && [m.volumn floatValue]<CGFLOAT_MAX) {
            model.bottomMinPrice = [m.volumn floatValue];
        }
        
        volumePriceTotal += [m.price floatValue];
        volumeTotal += [m.volumn floatValue];
        
        averageTotalPrice = volumePriceTotal / (i);
//        if ([m.averagePrice doubleValue]<=0) {
//            m.averagePrice = [NSString stringWithFormat:@"%.2f",averageTotalPrice];
//        }
        m.averagePrice = [NSString stringWithFormat:@"%f",averageTotalPrice];
        
        i ++;
        
    }
    
    CGFloat subTop = fabs(model.yestodayClosePrice - model.maxPrice);
    CGFloat subBottom = fabs(model.yestodayClosePrice - model.minPrice);
    CGFloat sub = subTop>subBottom?subTop:subBottom;
    if (model.maxPrice==model.minPrice) {
        if (model.maxPrice==model.yestodayClosePrice || model.maxPrice<=0) {
            sub = model.yestodayClosePrice * 0.02;
        }else{
            sub = fabs(model.maxPrice - model.yestodayClosePrice);
        }
        
    }
    model.maxPrice = model.yestodayClosePrice + sub;
    model.minPrice = model.yestodayClosePrice - sub;
    if (fabs(model.minPrice)>=CGFLOAT_MAX) {
        model.minPrice = 0;
    }
    if (model.maxPrice>=CGFLOAT_MAX) {
        model.maxPrice = 0;
    }
    
//    // MACD 处理
//    if (model.stockIndexBottomType == FMStockIndexType_MACD &&
//        model.type!=FMStockType_MinuteChart &&
//        model.type!=FMStockType_FiveDaysChart) {
//        if (fabs(model.bottomMaxPrice)>fabs(model.bottomMinPrice)) {
//            model.bottomMinPrice = -model.bottomMaxPrice;
//        }
//        if (fabs(model.bottomMaxPrice)<fabs(model.bottomMinPrice)) {
//            model.bottomMaxPrice = fabs(model.bottomMinPrice);
//        }
//    }
    
    FMStockMaxMinValueResult maxMins = {model.maxPrice,model.minPrice,model.bottomMaxPrice,model.bottomMinPrice};
    //FMLog(@"maxValue=%f  minValue=%f",model.maxPrice,model.minPrice);
    return maxMins;
}

//  计算当前价格离顶部多实际距离
+(CGFloat)topY:(CGFloat)price Model:(FMStockModel*)model{
    CGFloat y = (model.maxPrice - price) / (model.maxPrice-model.minPrice) * model.stage.topHeight;
    if (model.maxPrice==model.minPrice) {
        y = 0;
    }
//    if (y>model.stage.topHeight) {
//        FMLog(@"%f",y);
//    }
    return y;
}

//  计算指标数值的实际Y轴
+(CGFloat)bottomY:(CGFloat)price Model:(FMStockModel*)model{
    CGFloat y = (model.bottomMaxPrice - price) / (model.bottomMaxPrice-model.bottomMinPrice) * model.stage.bottomHeight;
    y += model.stage.topHeight + model.stage.padding.middle;
    if (model.bottomMaxPrice==model.bottomMinPrice) {
        y = 0;
    }
    //    if (y>model.stage.topHeight) {
    //        FMLog(@"%f",y);
    //    }
    return y;
}

+(CGFloat)macdBottomY:(CGFloat)price Model:(FMStockModel*)model{
    CGFloat y = (price) / (model.bottomMaxPrice) * model.stage.bottomHeight/2;
    y = model.stage.bottomHeight/2 - y;
    if (price<0) {
        y = fabs(price) / fabs(model.bottomMinPrice) * model.stage.bottomHeight/2;
        y = model.stage.bottomHeight/2 + y;
    }
    y += model.stage.topHeight + model.stage.padding.middle;
    if (model.bottomMaxPrice==model.bottomMinPrice) {
        y = 0;
    }
    return y;
}

//  计算各种行情市场的交易时间点数
+(void)pointCountForMarketType:(FMStockModel*)model{
    switch (model.marketType) {
        case FMMarketType_A:
            model.startTime = @"9:30";
            model.middleTime = @"11:30/13:00";
            model.endTime = @"15:00";
            break;
        case FMMarketType_B:
            model.startTime = @"9:30";
            model.middleTime = @"11:30/13:00";
            model.endTime = @"15:00";
            break;
        case FMMarketType_HK:
            model.startTime = @"9:30";
            model.middleTime = @"12:00/13:00";
            model.endTime = @"16:00";
            break;
        case FMMarketType_US:
            model.startTime = @"9:30";
            model.middleTime = @"12:30";
            model.endTime = @"16:00";
            break;
        case FMMarketType_AH:
            model.startTime = @"9:30";
            model.middleTime = @"12:00/13:00";
            model.endTime = @"16:00";
            break;
        default:
            break;
    }
    
    if (model.startTime && model.middleTime && model.endTime) {
        NSString *middlePre = @"";
        NSString *middleNext = @"";
        NSArray *middles = [model.middleTime componentsSeparatedByString:@"/"];
        if (middles.count<=0) {
            middlePre = model.middleTime;
            middleNext = model.middleTime;
        }else{
            middlePre = [middles firstObject];
            middleNext = [middles lastObject];
        }
        int up = [self countForStartTime:model.startTime EndTime:middlePre];
        int down = [self countForStartTime:middleNext EndTime:model.endTime];
        model.upCounts = up;
        model.downCounts = down;
        
        
    }
}

//  计算两个时间点的分钟数
+(int)countForStartTime:(NSString*)startTime EndTime:(NSString*)endTime{
    NSArray *s1 = [startTime componentsSeparatedByString:@":"];
    NSString *t1 = [s1 firstObject];
    NSString *m1 = [s1 lastObject];
    NSArray *s2 = [endTime componentsSeparatedByString:@":"];
    NSString *t2 = [s2 firstObject];
    NSString *m2 = [s2 lastObject];
    
    int h = [t2 intValue] - [t1 intValue];
    int m = [m2 intValue] - [m1 intValue];
    
    return h*60 + m;
}

@end
