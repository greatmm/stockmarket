//
//  FMStockTransformDatas.m
//  FMStockChart
//
//  Created by dangfm on 15/8/24.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMStockTransformDatas.h"
#import "FMHeader.h"
#import "FMStockModel.h"
#import "FMStockIndexAlgorithm.h"
#import "FMStockDaysModel.h"
#import "FMStockMinuteModel.h"

#define fmStockChaoMaiMaxValue 50
#define fmStockChaoMaiMinValue 50

@implementation FMStockTransformDatas

+(void)createWithModel:(FMStockModel*)model{
    [MKUserDefault setStockIndexDefaultValue];
    int i = 0;
    // 指标变量
    int KDJ_N = [MKUserDefault getKDJ_N];
    int SMA_N1 = [MKUserDefault getSMA_N1];
    int SMA_N2 = [MKUserDefault getSMA_N2];
    int SMA_N3 = [MKUserDefault getSMA_N3];
    int MACD_N1 = [MKUserDefault getMACD_N1];
    int MACD_N2 = [MKUserDefault getMACD_N2];
    int MACD_P = [MKUserDefault getMACD_P];
    int RSI_N1 = [MKUserDefault getRSI_N1];
    int RSI_N2 = [MKUserDefault getRSI_N2];
    int RSI_N3 = [MKUserDefault getRSI_N3];
    int BOLL_K = [MKUserDefault getBOLL_K];
    int BOLL_N = [MKUserDefault getBOLL_N];
    int VOL_N1 = [MKUserDefault getVOL_N1];
    int VOL_N2 = [MKUserDefault getVOL_N2];
    int VOL_N3 = [MKUserDefault getVOL_N3];
    int EMA_N = [MKUserDefault getEMA_N1];
    int OBV_N1 = [MKUserDefault getOBV_N1];
    
    int SAR_N = [MKUserDefault getSAR_N];
    int SAR_S = [MKUserDefault getSAR_S];
    int SAR_M = [MKUserDefault getSAR_M];
    SAR_N = 8;
    SAR_S = 1;
    SAR_M = 40;
    int DMI_N = [MKUserDefault getDMI_N];
    int DMI_M = [MKUserDefault getDMI_M];
//    int CYE_N = 5;
//    int CYE_M = 20;
    
    
    // 计算KDJ
    NSMutableDictionary *KDJ = [FMStockIndexAlgorithm getKDJMap:model.prices N:KDJ_N];
    NSMutableDictionary *firstMonthDay = [NSMutableDictionary new];
    NSMutableArray *lastDateKey = [NSMutableArray new];
    int lastDay = 0;
    int leastSub = 15; // 至少相隔15根K线
    int l = 0;
    float lastBuy = 0;  // 上一个买信号值
    float lastSell = 0; // 上一个卖信号值
    float lastClose = 0;
//    float buy = 0;
//    float sell = 0;
    float RSI_N1_ly = 0;
    float RSI_N1_ly1 = 0;
    float RSI_N2_ly = 0;
    float RSI_N2_ly1 = 0;
    float RSI_N3_ly = 0;
    float RSI_N3_ly1 = 0;
    FMStockIndexUpOrDown SAR_ISUP = FMStockIndexDown;
    float SAR_AF = 0;
    int SAR_T = 0;
    float zjby_ema13 = 0;
    float zjby_ema34 = 0;
    float zjby_ema5 = 0;
    float DMI_TR = 0;
    float DMI_DX = 0;
    float DMI_DMP = 0;
    float DMI_DMM = 0;
    // 保存绘画命令
    NSMutableDictionary *bsList = [NSMutableDictionary new];
    for (FMStockDaysModel *item in model.prices) {
        float K = 0;
        float D = 0;
        float J = 0;
      
        // MA值
        CGFloat MA5 = [FMStockIndexAlgorithm createMAWithPrices:model.prices MA:SMA_N1 Index:i];
        CGFloat MA10 = [FMStockIndexAlgorithm createMAWithPrices:model.prices MA:SMA_N2 Index:i];
        CGFloat MA20 = [FMStockIndexAlgorithm createMAWithPrices:model.prices MA:SMA_N3 Index:i];
        item.MA5 = [NSString stringWithFormat:@"%f",MA5];
        item.MA10 = [NSString stringWithFormat:@"%f",MA10];
        item.MA20 = [NSString stringWithFormat:@"%f",MA20];
        // VOL MA值
        CGFloat volMA_N1 = [FMStockIndexAlgorithm createVolMAWithCounts:model.prices MA:VOL_N1 Index:i];
        CGFloat volMA_N2 = [FMStockIndexAlgorithm createVolMAWithCounts:model.prices MA:VOL_N2 Index:i];
        CGFloat volMA_N3 = [FMStockIndexAlgorithm createVolMAWithCounts:model.prices MA:VOL_N3 Index:i];
        item.volMA_N1 = [NSString stringWithFormat:@"%f",volMA_N1];
        item.volMA_N2 = [NSString stringWithFormat:@"%f",volMA_N2];
        item.volMA_N3 = [NSString stringWithFormat:@"%f",volMA_N3];
        // 计算每天的MACD值
        [FMStockIndexAlgorithm getMACD:model.prices
                                  days:i
                           DhortPeriod:MACD_N1
                            LongPeriod:MACD_N2
                             MidPeriod:MACD_P];
        // 计算RSI值
        float rsi_1 = [FMStockIndexAlgorithm RSI:i N:RSI_N1 list:model.prices ly:&RSI_N1_ly ly1:&RSI_N1_ly1];
        float rsi_2 = [FMStockIndexAlgorithm RSI:i N:RSI_N2 list:model.prices ly:&RSI_N2_ly ly1:&RSI_N2_ly1];
        float rsi_3 = [FMStockIndexAlgorithm RSI:i N:RSI_N3 list:model.prices ly:&RSI_N3_ly ly1:&RSI_N3_ly1];
        item.RSI_1 = [NSString stringWithFormat:@"%f",rsi_1];
        item.RSI_2 = [NSString stringWithFormat:@"%f",rsi_2];
        item.RSI_3 = [NSString stringWithFormat:@"%f",rsi_3];
        
        // 计算EMA
        NSInteger prei = i;
        if (prei>0) {
            prei = prei - 1;
        }
        NSMutableArray *list = [NSMutableArray arrayWithObjects:[model.prices objectAtIndex:prei],item,nil];
        [FMStockIndexAlgorithm getEMA:list Number:EMA_N];
        list = nil;
        // 计算OBV
        // 计算OBV
        float obv = [FMStockIndexAlgorithm OBV:i list:model.prices];
        float obv_n1 = 0;
        item.OBV = [NSString stringWithFormat:@"%.2f",obv];
        obv_n1 = [FMStockIndexAlgorithm MA:@"OBV" N:OBV_N1 day:i list:model.prices];
        item.OBV_N1 = [NSString stringWithFormat:@"%.2f",obv_n1];
        
        // 计算每天的BOLL值
        [FMStockIndexAlgorithm getBOLLWithDay:i K:BOLL_K N:BOLL_N Data:model.prices];
        if (KDJ) {
            K = [[[KDJ valueForKey:@"K"] objectAtIndex:i] floatValue];
            D = [[[KDJ valueForKey:@"D"] objectAtIndex:i] floatValue];
            J = [[[KDJ valueForKey:@"J"] objectAtIndex:i] floatValue];
        }
        item.KDJ_K = [NSString stringWithFormat:@"%f",K];
        item.KDJ_D = [NSString stringWithFormat:@"%f",D];
        item.KDJ_J = [NSString stringWithFormat:@"%f",J];
        
        
        // 计算DMA指标 方法里面会自动给模型赋值
        [FMStockIndexAlgorithm DMI:DMI_N M:DMI_M day:i list:model.prices lDMP:&DMI_DMP lDMM:&DMI_DMM lTR:&DMI_TR lDX:&DMI_DX];
        
        // 计算每天的SAR值
        [FMStockIndexAlgorithm SAR:SAR_N S:SAR_S M:SAR_M day:i list:model.prices lup:&SAR_ISUP lAF:&SAR_AF t:&SAR_T];
        
        
        // 是否是月份的第一个交易日 用来显示时间跨度
//        NSString *time = item.datetime;
//        int year = [[time substringToIndex:4] intValue];
//        int yearMonth = [[time substringToIndex:6] intValue];
//        int monthDay = [[time substringFromIndex:6] intValue];
//        int month = [[[time substringToIndex:6] substringFromIndex:4] intValue];
//        NSString *firstTime = [firstMonthDay objectForKey:lastDateKey.lastObject];
//        int firstYear = [[firstTime substringToIndex:4] intValue];
//        int firstMonth = [[[firstTime substringToIndex:6] substringFromIndex:4] intValue];
// 
//        if (monthDay<lastDay && l>=leastSub) {
//            // 判断要隔几个月
//            int gm = 2;
//            int mResult = 0;
//            int yearSub = year - firstYear;
//            month += yearSub * 12;
//            mResult = month - firstMonth;
//            
//            if (model.type == FMStockType_MonthChart) {
//                gm = 36;
//            }
//            if (model.type == FMStockType_WeekChart) {
//                gm = 6;
//            }
//            
//            if (!firstTime) {
//                mResult = gm;
//            }
//            
//            if (mResult>=gm) {
//                [firstMonthDay setObject:time forKey:[NSString stringWithFormat:@"%d",yearMonth]];
//                [lastDateKey addObject:[NSString stringWithFormat:@"%d",yearMonth]];
//            }
//            
//            l = 0;
//        }
//        
//        lastDay = monthDay;
        lastClose = [item.closePrice floatValue];
        
//        time = nil;
        item.index = i;
        
        i++;
        l++;
    }
    model.firstMonthDay = firstMonthDay;
    firstMonthDay = nil;
    if (bsList.count>0) {
        model.drawDatas = bsList;
        model.isOpenSignal = NO;
    }
    
    bsList = nil;
}





/**
 *  配置行情开盘收盘时间
 *
 *  @param model 模型
 */
+(void)createModelTimes:(FMStockModel*)model{
    if (model.times.count<=0) {
        switch (model.marketType) {
            case FMMarketType_A:
            case FMMarketType_B:
            {
                model.times = [NSMutableArray arrayWithArray:@[@"9:30",@"11:30/13:00",@"15:00"]];
            }
                break;
                
            default:
                break;
        }
    }

}

/**
 *  处理分时数据不完整情况
 *
 *  @param model 模型
 */
+(void)createMinuteWithModel:(FMStockModel*)model{
    if (model.prices.count<=0) {
        return;
    }
    [self createModelTimes:model];
    // 今天
    NSString *today = [FMCommon dateToString:[NSDate date] target:@"yyyy-MM-dd "];
    // 第一个日期
    FMStockMinuteModel *sm = model.prices.firstObject;
    NSString *startTime = [today stringByAppendingString:sm.datetime];
    startTime = [NSString stringWithFormat:@"%.f",[[FMCommon stringToDate:startTime format:@"yyyy-MM-dd HH:mm"] timeIntervalSince1970]];
    // 最后一个日期
    FMStockMinuteModel *em = model.prices.lastObject;
    NSString *endTime = [today stringByAppendingString:em.datetime];
    endTime = [NSString stringWithFormat:@"%.f",[[FMCommon stringToDate:endTime format:@"yyyy-MM-dd HH:mm"] timeIntervalSince1970]];
    // 最新更新时间
    NSString *lastTime = [today stringByAppendingString:em.lastTime];
    lastTime = [NSString stringWithFormat:@"%.f",[[FMCommon stringToDate:lastTime format:@"yyyy-MM-dd HH:mm:ss"] timeIntervalSince1970]];
    // 开始时间的时间戳
    int t = [self timeWithString:startTime time:model.times.firstObject];
    // 中间时间戳
    NSString *middle = model.times[1];
    NSString *m1str = middle;
    NSString *m2str = middle;
    if ([middle containsString:@"/"]) {
        NSArray *middleArray = [middle componentsSeparatedByString:@"/"];
        m1str = middleArray.firstObject;
        m2str = middleArray.lastObject;
    }
    int m1 = [self timeWithString:startTime time:m1str];
    int m2 = [self timeWithString:startTime time:m2str];
    // 结束时间时间戳
    int endT = [self timeWithString:endTime time:model.times.lastObject];
    endT = [lastTime intValue];
    // 按分钟来走
    NSMutableArray *newPrice = [NSMutableArray new];
    BOOL ishasData = NO; // 是否有数据啦
    FMStockMinuteModel *lastModel;  // 上一个有值的数据
    // 收盘时间
    NSString *untilTime = [today stringByAppendingString:@"15:00"];
    untilTime = [NSString stringWithFormat:@"%.f",[[FMCommon stringToDate:untilTime format:@"yyyy-MM-dd HH:mm"] timeIntervalSince1970]];
    int until = [self timeWithString:untilTime time:model.times.lastObject];;
    if (endT>=until) {
        endT = until;
    }
    FMLog(@"开始时间戳:%d,结束时间戳:%d，收盘时间戳:%d",t,endT,until);
    float averageCount = 0; // 计算平均价
    int num = 1;
    for (int i=t; i<=endT; i=i+60) {
        // 如果是中间休盘时间则跳过
        if (i>m1 && i<m2 && m1!=m2) {
            continue;
        }
        // NSString *tm = [FMCommon dateToString:[NSDate dateWithTimeIntervalSince1970:i] target:@"yyyy-MM-dd hh:mm:ss"];
        //FMLog(@"时间：%d=%@",i,tm);
        FMStockMinuteModel *mo = [[FMStockMinuteModel alloc] init];
        
        mo.price = @"0";//[NSString stringWithFormat:@"%.2f",model.yestodayClosePrice];
        mo.yestodayClosePrice = @"0";
        mo.averagePrice = @"0";
        mo.changeRate = @"0";
        if (lastModel && i<endT) {
            mo.price = lastModel.price;
            mo.changeRate = lastModel.changeRate;
            mo.averagePrice = lastModel.averagePrice;
            //FMLog(@"最后一个点的值为：%@",lastModel.price);
        }
        mo.volumn = 0;
    
        if (!ishasData) {
//            mo.yestodayClosePrice = mo.price;
//            mo.averagePrice = mo.price;
        }
        
        NSString *istr = [FMCommon dateToString:[NSDate dateWithTimeIntervalSince1970:i] target:@"HH:mm"];
        
        for (FMStockMinuteModel *m in model.prices) {
            //NSString *datetime = [today stringByAppendingString:m.datetime];
            //datetime = [NSString stringWithFormat:@"%.f",[[FMCommon stringToDate:datetime format:@"yyyy-MM-dd HH:mm"] timeIntervalSince1970]];
            if ([istr isEqualToString:m.datetime]) {
                mo = m;
                //FMLog(@"有了=%@",istr);
                ishasData = YES;
                lastModel = m;
                break;
            }
        }
        istr = nil;
        
        if (i==until) {
            //FMLog(@"加到最后一个点");
            //mo = model.prices.lastObject;
        }
        
        if ([mo.price floatValue]>0) {
            averageCount += [mo.price floatValue];
            mo.averagePrice = [NSString stringWithFormat:@"%.2f",averageCount/num];
        }
        
        
        mo.datetime = [FMCommon dateToString:[NSDate dateWithTimeIntervalSince1970:i] target:@"HH:mm"];
        [newPrice addObject:mo];
        mo = nil;
        
        num ++;
    }
    
    // 最后until值加一个点
    
    
    model.prices = newPrice;
}

/**
 *  拿到相对时间戳
 *
 *  @param str  需要转换的时间 时间戳
 *  @param time 开盘时间或者收盘时间，或者最新更新时间 格式 HH:mm
 *
 *  @return 时间戳
 */
+(int)timeWithString:(NSString*)str time:(NSString*)time{
    NSString *hm = [FMCommon dateToString:[NSDate dateWithTimeIntervalSince1970:[str doubleValue]] target:[NSString stringWithFormat:@"yyyy-MM-dd %@:00",time]];
    FMLog(@"第一个数据时间:%@",hm);
    // 转换为时间戳
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *strDate = [dateFormatter dateFromString:hm];
    
    dateFormatter = nil;
    // 开始时间的时间戳
    int t = [strDate timeIntervalSince1970];
    
    return t;
}
@end
