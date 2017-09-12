//
//  FMStockIndexAlgorithm.m
//  FMStockChart
//
//  Created by dangfm on 15/7/26.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMStockIndexAlgorithm.h"
#import "FMStockDaysModel.h"

@implementation FMStockIndexAlgorithm

#pragma mark - 股票指数算法集合

#pragma mark MACD里EMA算法
/**
 * @param list为收盘价集合 传昨天和今天的数据过来 共两个数据
 * @param EMAn=2/(n+1)*(本周期收盘价-上一周期EMAn)+上一周期EMAn
 **/
+(float)getEXPMA:(NSMutableArray*)list Number:(int)number {
    // 开始计算EMA值，
    // 昨日EMA 第一天取收盘价
    FMStockDaysModel *ym = (FMStockDaysModel*)[list firstObject];
    double ema = [ym.MACD_12EMA floatValue];// 昨天ema
    if (number>12) {
        ema = [ym.MACD_26EMA floatValue];
    }
    if (ema<=0) {
        ema = [ym.closePrice floatValue]; // 如果无昨日ema则等于当天收盘价 这个一般是开盘第一天的ema值
        if (ema<=0) {
            return 0;
        }
    }
    ym = nil;
    
    FMStockDaysModel *m = (FMStockDaysModel*)[list lastObject];
    
    // EMAn=2/(n+1)*(本周期收盘价-上一周期EMAn)+上一周期EMAn
    ema = (2*[m.closePrice floatValue] + (number-1)*ema)/(number+1);
    
    if (number<=12) {
        m.MACD_12EMA = [NSString stringWithFormat:@"%f",ema];
    }else{
        m.MACD_26EMA = [NSString stringWithFormat:@"%f",ema];
    }
    m = nil;
    return ema;
}

/**
 *  计算EMA值
 *  公式：EMAn=2/(n+1)*(本周期收盘价-上一周期EMAn)+上一周期EMAn
 *
 *  @param list   本周期数据和上一周期数据
 *  @param number N值
 *
 *  @return EMA
 */
+(float)getEMA:(NSMutableArray*)list Number:(int)number{
    // 开始计算EMA值，
    // 昨日EMA 第一天取收盘价
    FMStockDaysModel *ym = (FMStockDaysModel*)[list firstObject];
    double ema = [ym.EMA floatValue];// 昨天ema
    
    if (ema<=0) {
        ema = [ym.closePrice floatValue]; // 如果无昨日ema则等于当天收盘价 这个一般是开盘第一天的ema值
        if (ema<=0) {
            return 0;
        }
    }
    ym = nil;
    
    FMStockDaysModel *m = (FMStockDaysModel*)[list lastObject];
    
    // EMAn=2/(n+1)*(本周期收盘价-上一周期EMAn)+上一周期EMAn
    ema = (2*[m.closePrice floatValue] + (number-1)*ema)/(number+1);
    m.EMA = [NSString stringWithFormat:@"%f",ema];
    // ema = (2/(number+1)) * ([m.closePrice floatValue]-ema) + ema;
    m = nil;
    return ema;
}


/**
 * 计算MACD值
 *
 * @param list          N日收盘价集合
 * @param shortPeriod   短期.
 * @param longPeriod    长期.
 * @param midPeriod     M.参数：SHORT(短期)、LONG(长期)、M天数，一般为12、26、9
 * @return 返回第N日的 MACD值
 */
+(void)getMACD:(NSMutableArray*)list days:(int)day DhortPeriod:(int)shortPeriod LongPeriod:(int)longPeriod MidPeriod:(int)midPeriod
{
//    if (list.count<shortPeriod || list.count<longPeriod || list.count<midPeriod) {
//        return;
//    }
    NSMutableArray *diffList = [[NSMutableArray alloc] init];
    double shortEMA = 0.0;
    double longEMA = 0.0;
    double dif = 0.0;
    double dea = 0.0;
    double macd = 0.0;
    FMStockDaysModel *dic = (FMStockDaysModel*)[list objectAtIndex:day];
    if (day>=1) {
        int startIndex = day - 1;
        if(startIndex<0)startIndex = 0;
        if (list.count<startIndex+2) {
            return;
        }
        
        NSMutableArray *sublist = [NSMutableArray arrayWithArray:[list subarrayWithRange:NSMakeRange(startIndex, 2)]];
        shortEMA = [self getEXPMA:sublist Number:shortPeriod];
        longEMA = [self getEXPMA:sublist Number:longPeriod];
        // 每日的DIF值 收盘价短期、长期指数平滑移动平均线间的差   DIF=EMAx-EMAy
        // 首个DEA=最近z个周期的DIF的移动平均
        // 此后DEA=(前个DEA*(z-1)/(z+1)+本周期DIF*2/(z+1)
        dif = shortEMA - longEMA;
        sublist = nil;
        // 首个DEA=最近z个周期的DIF的移动平均  9日DIF的平均值(DEA)=最近9日的DIF之和/9
//        if (day<midPeriod) {
//            CGFloat deatemp = 0;
//            for (int i=day; i<midPeriod; i++) {
//                int startIndex = i-1;
//                if(startIndex<0)startIndex = 0;
//                NSMutableArray *sublist = [NSMutableArray arrayWithArray:[list subarrayWithRange:NSMakeRange(startIndex, 2)]];
//                shortEMA = [self getEXPMA:sublist Number:shortPeriod];
//                longEMA = [self getEXPMA:sublist Number:longPeriod];
//                double difftemp = shortEMA - longEMA;
//                deatemp += difftemp;
//                sublist = nil;
//            }
//            // DEA N日的DIF平均值
//            dea = deatemp / midPeriod;
//        }else{
//            // 前一个DEA
//            FMStockDaysModel *lastM = (FMStockDaysModel*)[list objectAtIndex:day-1];
//            dea = [lastM.MACD_DEA doubleValue];
//            // 此后DEA=(前个DEA*(z-1)/(z+1)+本周期DIF*2/(z+1)
//            dea = dea*(midPeriod-1)/(midPeriod+1)+dif*2/(midPeriod+1);
//        }
        
        // 前一个DEA
        FMStockDaysModel *lastM = (FMStockDaysModel*)[list objectAtIndex:day-1];
        dea = [lastM.MACD_DEA doubleValue];
        // 此后DEA=(前个DEA*(z-1)/(z+1)+本周期DIF*2/(z+1)
        dea = dea*(midPeriod-1)/(midPeriod+1)+dif*2/(midPeriod+1);
        
        macd = 2*(dif-dea);
    }
    dic.MACD_DIF = [NSString stringWithFormat:@"%f",dif];
    dic.MACD_DEA = [NSString stringWithFormat:@"%f",dea];
    dic.MACD_M = [NSString stringWithFormat:@"%f",macd];
    diffList = nil;
    dic = nil;
}

/**
 *  KDJ算法
 *  计算公式：rsv =（收盘价– n日内最低价最低值）/（n日内最高价最高值– n日内最低价最低值）×100
 　　K = rsv的m天移动平均值
 　　D = K的m1天的移动平均值
 　　J = 3K - 2D
 　　rsv:未成熟随机值
    rsv天数默认值：9，K默认值：3，D默认值：3。
 **/
+(NSMutableDictionary*)getKDJMap:(NSArray*)list N:(int)n{
    // 默认随机值
    int m_iParam[] = {n, 3, 3};
    int n1 = m_iParam[0];
    int n2 = m_iParam[1];
    int n3 = m_iParam[2];
    if(list == nil || n1 > list.count || n1 < 1)
        return nil;
    // 初始化数组
    NSMutableArray *kvalue = [[NSMutableArray alloc] init];
    NSMutableArray *dvalue = [[NSMutableArray alloc] init];
    NSMutableArray *jvalue = [[NSMutableArray alloc] init];
    // 给初值
    for (id item in list) {
        [kvalue addObject:[NSNumber numberWithInt:0]];
        [dvalue addObject:[NSNumber numberWithInt:0]];
        [jvalue addObject:[NSNumber numberWithInt:0]];
    }
    n2 = n2 > 0 ? n2 : 3;
    n3 = n3 > 0 ? n3 : 3;
    // 第九天的k线图数据单例
    FMStockDaysModel *model = (FMStockDaysModel*)[list objectAtIndex:(n1-1)];
    // 计算N日内的最低最高价
    float maxhigh = [model.heightPrice floatValue]; // 最高价
    float minlow = [model.lowPrice floatValue]; // 最低价
    for(int j = n1 - 1; j >= 0; j--) {
        FMStockDaysModel *m = (FMStockDaysModel*)[list objectAtIndex:(j)];
        if(maxhigh < [m.heightPrice floatValue])
            maxhigh = [m.heightPrice floatValue];
        if(minlow > [m.lowPrice floatValue])
            minlow = [m.lowPrice floatValue];
        m = nil;
    }
    // 计算RSV值
    float rsv;
    if(maxhigh <= minlow)
        rsv = 50.0f;
    else
        rsv = (([model.closePrice floatValue] - minlow) / (maxhigh - minlow)) * 100.0f;
    float prersv;
    prersv = rsv;
    [jvalue replaceObjectAtIndex:(n1 - 1) withObject:[NSNumber numberWithFloat:prersv]];
    [dvalue replaceObjectAtIndex:(n1 - 1) withObject:[NSNumber numberWithFloat:prersv]];
    [kvalue replaceObjectAtIndex:(n1 - 1) withObject:[NSNumber numberWithFloat:prersv]];
    for(int i = 0; i < n1; i++) {
        [jvalue replaceObjectAtIndex:(i) withObject:[NSNumber numberWithFloat:0]];
        [dvalue replaceObjectAtIndex:(i) withObject:[NSNumber numberWithFloat:0]];
        [kvalue replaceObjectAtIndex:(i) withObject:[NSNumber numberWithFloat:0]];
    }
    
    for(int i = n1-1; i < list.count; i++) {
        FMStockDaysModel *m = (FMStockDaysModel*)[list objectAtIndex:i];
        maxhigh = [m.heightPrice floatValue];
        minlow = [m.lowPrice floatValue];
        for(int j = i; j > i - n1; j--) {
            FMStockDaysModel *mm = (FMStockDaysModel*)[list objectAtIndex:j];
            if(maxhigh < [mm.heightPrice floatValue])
                maxhigh = [mm.heightPrice floatValue];
            if(minlow > [mm.lowPrice floatValue])
                minlow = [mm.lowPrice floatValue];
            mm = nil;
        }
        
        if(maxhigh <= minlow) {
            rsv = prersv;
        } else {
            prersv = rsv;
            rsv = (([m.closePrice floatValue] - minlow) / (maxhigh - minlow)) * 100.0f;
        }
        // 计算K值
        CGFloat newK = ([[kvalue objectAtIndex:i-1] floatValue] * (float)(n2 - 1)) / (float)n2 + rsv / (float)n2;
        if (newK<=0) {
            newK = 0;
        }
        [kvalue replaceObjectAtIndex:(i) withObject:[NSNumber numberWithFloat:newK]];
        // 计算D值
        CGFloat newD = [[kvalue objectAtIndex:i] floatValue] / (float)n3 + ([[dvalue objectAtIndex:i-1] floatValue] * (float)(n3 - 1)) / (float)n3;
        if (newD<=0) {
            newD = 0;
        }
        [dvalue replaceObjectAtIndex:(i) withObject:[NSNumber numberWithFloat:newD]];
        // 计算J值
        CGFloat newJ = [[kvalue objectAtIndex:i] floatValue] * 3.0f - 2.0f*[[dvalue objectAtIndex:i] floatValue];
        if (newJ<=0) {
            newJ = 0;
        }
        [jvalue replaceObjectAtIndex:(i) withObject:[NSNumber numberWithFloat:newJ]];
        m = nil;
        
    }
    model = nil;
    // 封装好返回
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:kvalue forKey:@"K"];
    [dic setObject:dvalue forKey:@"D"];
    [dic setObject:jvalue forKey:@"J"];
    return dic;
}


/**
 *  RSI
 *
 *  @param day  天数下标
 *  @param key  键名
 *  @param N    N值
 *  @param list 模型数据
 *
    算法：
    SMA(C,N,M) = (M*C+(N-M)*Y')/N
    LC := REF(CLOSE,1);
    RSI$1:SMA(MAX(CLOSE-LC,0),N1,1)/SMA(ABS(CLOSE-LC),N1,1)*100;
 
 *  @return RSI值
 */
+(float)RSI:(int)day N:(int)N list:(NSArray*)list ly:(float*)ly ly1:(float*)ly1 {
    float count = 0;
    float downCount = 0;
    float preClosePrice = 0;
    float rsi = 0;
    int M = 1.0;
    if (day<N) {
        return rsi;
    }
    int startIndex = day - N + 1;
    if(startIndex<=0)startIndex = 0;
    if (startIndex>0) {
        // 上一个收盘价
        preClosePrice = [self REF:@"closePrice" day:day-1 list:list];
    }
    // Y=(M*X+(N-M)*Y')/N
    float y1 = *ly;
    float y2 = *ly1;
    if (day==N) {
        // 第N天开始，昨天SMA为均值
        float lp = [self REF:@"closePrice" day:0 list:list];;
        float c1 = 0;
        float c2 = 0;
        for (int i=1; i<N; i++) {
            FMStockDaysModel *dcm = [[FMStockDaysModel alloc] initWithDic:[list objectAtIndex:i]];
            float c = [dcm.closePrice floatValue] - lp;
            if (c>0) {
                c1 += c;
            }
            c2 += fabsf(c);
            lp = [dcm.closePrice floatValue];
            dcm = nil;
        }
        y1 = count / N;
        y2 = c2 / N;
    }
    
    FMStockDaysModel *m = (FMStockDaysModel*)[list objectAtIndex:day];
    float X = [m.closePrice floatValue] - preClosePrice;
    if (X>0) {
        count = ((M*X)+(N-M)*y1)/N;
    }else{
        count = ((M*0)+(N-M)*y1)/N;
    }
    
    downCount = ((M*fabsf(X))+(N-M)*y2)/N;
    *ly = count;
    *ly1 = downCount;
    // RSI(N)=A÷(A＋B)×100
    rsi = count / (downCount) * 100;
//    an = count / N;
//    bn = downCount / N;
//    // RSI=100 × RS/(1+RS)
//    float rs = an/bn;
//    // rsi = rs/(1+rs)*100;
//    // RSI=100－100÷（1+RS）
//    rsi = 100 - 100.0 / (1.0 + rs);
    
    // RSI=100-[100/(1+RS)]
    // rsi = 100-(100/(1+count/downCount));
    // 保存RSI值
    return rsi;
}

#pragma mark 获取BOLL值

/**
 *  BOLL算法
 *
 *  @param day  天数
 *  @param k    K值
 *  @param n    N值
 *  @param data 收盘价集合
 *  算法：
 *  中轨：Mid=SMA(n-1)=(C1+C2+C3+…+C(n-1))/(n-1))
    标准差：MDn={[(C1-SMAn)^2+…+(Cn-SMAn)^2]/n}^0.5
    上轨：UP=Mid+k*MD
    下轨：DN=Mid-K*MD
 *
 */
+(void)getBOLLWithDay:(int)day K:(int)k N:(int)n Data:(NSArray*)data{
    float mid = 0;
    float up = 0;
    float dn = 0;
    float mdn = 0;
    if (day>=n) {
        mid = [self getSMAn:n Day:day Data:data];
        mdn = [self getMDn:n Day:day Data:data];
        up = mid + k*mdn;
        dn = mid - k*mdn;
    }
    FMStockDaysModel *dic = (FMStockDaysModel*)[data objectAtIndex:day];
    [dic setValue:[NSString stringWithFormat:@"%f",mid] forKey:@"BOLL_MIDDLE"];
    [dic setValue:[NSString stringWithFormat:@"%f",up] forKey:@"BOLL_UP"];
    [dic setValue:[NSString stringWithFormat:@"%f",dn] forKey:@"BOLL_DOWN"];
    
    
}

+(float)getSMAn:(int)n Day:(int)day Data:(NSArray*)data{
    int startIndex = day-n+1;
    int endIndex = day;
    float count = 0;
    if (startIndex<0) {
        startIndex = 0;
    }
    for (int i=startIndex;i<endIndex; i++) {
        FMStockDaysModel *m = (FMStockDaysModel*)[data objectAtIndex:i];
        CGFloat closePrice = [m.closePrice floatValue];
        count += closePrice;
    }
    return count/(n-1);
}
+(float)getMDn:(int)n Day:(int)day Data:(NSArray*)data{
    int startIndex = day-n+1;
    int endIndex = day;
    if (startIndex<0) {
        startIndex = 0;
    }
    float count = 0;
    float sman = [self getSMAn:(n) Day:day Data:data];
    for (int i=startIndex;i<=endIndex; i++) {
        FMStockDaysModel *m = (FMStockDaysModel*)[data objectAtIndex:i];
        CGFloat closePrice = [m.closePrice floatValue];
        CGFloat v = closePrice-sman;
        v = v*v;
        count += v;
    }
    float mdtemp = count/n;
    float mdn = sqrt(mdtemp);
    return mdn;
}

/**
 *  MA移动平均线
 *
 *  @param prices 收盘价集合
 *  @param ma     N值
 *  @param index  天数
 *
 *  @return 当天MA值
 */
+(float)createMAWithPrices:(NSArray*)prices MA:(CGFloat)ma Index:(int)index{
    int startIndex = index - ma+1;
    float priceCount = 0;
    if (startIndex<0) {
        startIndex = 0;
        return 0;
    }
    for (int i=startIndex; i<=index; i++) {
        FMStockDaysModel *item = [prices objectAtIndex:i];
        float closePrice = [item.closePrice floatValue];
        priceCount += closePrice;
        item = nil;
    }
    if (priceCount<=0) {
        return 0;
    }
    ma = priceCount / ma;
    return ma;
}

/**
 *  成交量MA移动平均线
 *
 *  @param counts 成交量集合
 *  @param ma     N值
 *  @param index  天数
 *
 *  @return 当天MA值
 */
+(float)createVolMAWithCounts:(NSArray*)counts MA:(CGFloat)ma Index:(int)index{
    int startIndex = index - ma+1;
    float priceCount = 0;
    if (startIndex<0) {
        startIndex = 0;
        return 0;
    }
    for (int i=startIndex; i<=index; i++) {
        FMStockDaysModel *item = [counts objectAtIndex:i];
        float count = [item.volumn floatValue];
        priceCount += count;
        item = nil;
    }
    if (priceCount<=0) {
        return 0;
    }
    ma = priceCount / ma;
    return ma;
}

/**
 *  MA 值
 *
 *  @param key  要计算的key
 *  @param N    N天
 *  @param day  当天下标
 *  @param list 模型数据
 *
 *  @return MA
 */
+(float)MA:(NSString*)key N:(int)N day:(int)day list:(NSArray*)list{
    int startIndex = day - N + 1;
    float priceCount = 0;
    float ma = 0;
    if (startIndex<0) {
        startIndex = 0;
        return 0;
    }
    for (int i=startIndex; i<=day; i++) {
        FMStockDaysModel *item = [list objectAtIndex:i];
        float v = [[item valueForKey:key] floatValue];
        priceCount += v;
        item = nil;
    }
//    if (priceCount<=0) {
//        return 0;
//    }
    ma = priceCount / N;
    return ma;
}

/**
 *  前值
 *
 *  @param key  键
 *  @param day  那一天的数据
 *  @param list 模型数据
 *
 *  @return 前值
 */
+(float)REF:(NSString*)key day:(int)day list:(NSArray*)list{
    float value = 0;
    if (day<0) day = 0;
    if (day>=0 && day<list.count){
        FMStockDaysModel *m = list[day];
        value = [[m valueForKey:key] floatValue];
    }
    return value;
}



/**
 *  返回最大值最高价
 *
 *  @param key  价格类型
 *  @param N    N周期
 *  @param day  当前时间
 *  @param list k线数据
 *
 *  @return 最高价
 */
+(float)HHV:(NSString*)key N:(int)N day:(int)day list:(NSArray*)list{
    int startIndex = day - N + 1;
    float hhv = 0;
    if (startIndex<0) {
        startIndex = 0;
        return 0;
    }
    for (int i=startIndex; i<=day; i++) {
        FMStockDaysModel *item = [list objectAtIndex:i];
        float v = [[item valueForKey:key] floatValue];
        if (v>hhv) {
            hhv = v;
        }
        item = nil;
    }
    return hhv;
}

/**
 *  返回最大值最高价
 *
 *  @param key  价格类型
 *  @param N    N周期
 *  @param day  当前时间
 *  @param list k线数据
 *
 *  @return 最高价
 */
+(float)LLV:(NSString*)key N:(int)N day:(int)day list:(NSArray*)list{
    int startIndex = day - N + 1;
    float llv = CGFLOAT_MAX;
    if (startIndex<0) {
        startIndex = 0;
        return 0;
    }
    for (int i=startIndex; i<=day; i++) {
        FMStockDaysModel *item = [list objectAtIndex:i];
        float v = [[item valueForKey:key] floatValue];
        if (v<llv) {
            llv = v;
        }
        item = nil;
    }
    return llv;
}

/**
 *  线性回归斜率
 *
 *  @param key  键
 *  @param n    N值
 *  @param day  当前天数下标
 *  @param list 模型数据
 公式：
 lxy:=∑(x(i)-avr(x,n))*(y(i)-avr(y,n));
 lxx:=∑(x(i)-avr(x,n))^2;
 b:=lxy/lxx;
 *
 *  @return 线性回归斜率
 */
+(float)SLOPE:(NSString*)key n:(int)n day:(int)day list:(NSArray*)list{
    float x = 0.0;
    float y = 0.0;
    float lxx = 0.0;
    float lxy = 0.0;
    float slope = 0.0;
    if (day<0) day = 0;
    int end = day - n;
    if (end<=0) end = 0;
    if (day<list.count) {
        // x 的平均值,收盘价的平均值
        for (int i=n;i>=1;i--){
            float c = [self REF:key day:(i+end-1) list:list];
            x = i + x;
            y = c + y;
        }
        x=x / n;
        y=y / n;
        for (int i=1;i<=n;i++){
            float c = [self REF:key day:(i+end-1) list:list];
            lxx=lxx + (i - x) * (i - x);
            lxy=lxy + (i - x) * (c - y);
        }
        
        float b = lxy / lxx;
        //double a = y - b*x;
        slope = b;
    }
    return slope;
}

/**
 *  OBV 量能潮
 *
 *  @param day  那一天
 *  @param list 模型数据
 *  公式：VA = V × [（C - L）- （H - C）]/（H - C）
 *  @return OBV值
 */
+(float)OBV:(int)day list:(NSArray*)list{
    float va = 0;
    float lc = 0;
    int lday = day  - 1;
    if (day<list.count && day>0) {
        FMStockDaysModel *m = list[day];
        if (lday>=0) {
            lc = [self REF:@"closePrice" day:lday list:list];
        }
        float obv = [m.OBV floatValue];
        if (day==0) {
            obv = 0;
        }
        float v = [m.volumn floatValue];
        float c = [m.closePrice floatValue];
        float l = [m.lowPrice floatValue];
        float h = [m.heightPrice floatValue];
        va = v * ((c-l)-(h-c)) / (h-c);
        if (c<lc) {
            va = obv-v;
        }
        if (c>lc) {
            va = obv+v;
        }
        if (c==lc) {
            //va = 0;
        }
    }
    return va;
}

+(float)SAR:(int)N S:(float)S M:(float)M  day:(int)day list:(NSArray*)list lup:(FMStockIndexUpOrDown*)lup lAF:(float*)lAF t:(int*)t{
    if (day<N) {
        return 0;
    }
    // 加速因子换算
    float s = S * 0.01;  // 每次递增加速因子
    float m = M * 0.01;  // 最大递增到加速因子值
    float EP = 0;
    float AF = *lAF;
    int tt = *t;
    NSString *topkey = @"heightPrice";
    NSString *downKey = @"lowPrice";
    
    FMStockDaysModel *model = list[day];
    float sar = 0;
    float lsar = [self REF:@"SAR" day:day-1 list:list];
    float lsar_buy = [self REF:@"SAR_BUY" day:day-1 list:list];
    float high = [model.heightPrice floatValue];
    float low = [model.lowPrice floatValue];
    float close = [model.closePrice floatValue];
    float open = [model.openPrice floatValue];
    float lhigh = [self REF:topkey day:day-1 list:list];
    float llow = [self REF:downKey day:day-1 list:list];
    
    
    // 买入点价格延续
    model.SAR_BUY = [NSString stringWithFormat:@"%f",lsar_buy];
    // 计算当前收益率
    float rate = 0;
    float lrate = [self REF:@"SAR_RATE" day:day-1 list:list];
    if(lsar_buy>0) rate = (high-lsar_buy) / lsar_buy * 100;
    model.SAR_RATE = [NSString stringWithFormat:@"%f",rate];
    
    
    // 趋势判断
    FMStockIndexUpOrDown isUp = *lup;
    
    // 极点价EP的确定
    // 若Tn周期为上涨趋势，EP(Tn-1)为Tn-1周期内的最高价，若Tn周期为下跌趋势，EP(Tn-1)为Tn-1周期内的最 低价；
    if (isUp==FMStockIndexUp) {
        EP = [self HHV:topkey N:N day:day-1 list:list];
    }else{
        EP = [self LLV:downKey N:N day:day-1 list:list];
    }
    
    // 如果第1日的最高价>第0日最高价，则AF(1)=AF(0)+0.02。否则，AF(1)=AF(0)。
    float high_min = [self LLV:topkey N:N day:day-1 list:list];
    float low_min = [self LLV:downKey N:N day:day-1 list:list];
    if (isUp==FMStockIndexUp) {
        //s = 0.01;
        // Tn周期都为上涨趋势时，当Tn周期的最高价>Tn-1周期内的最高价,则AF(Tn)=AF(Tn-1)+0.02， 当Tn周期的最高价<=Tn-1周期的最高价,则AF(Tn)=AF(Tn-1)，但加速因子AF最高不超过0.2
        if (high>high_min && close>open) {
            AF = AF + s;
        }else{
            //AF = *lAF;
            //AF = AF + s;
        }
        
        
    }else{
        //s = 0.02;
        // Tn周期都为下跌趋势时，当Tn周期的最低价<Tn-1周期的最低价,则AF(Tn)=AF(Tn-1)+0.02， 当Tn周期的最低价>=Tn-1周期的最低价,则AF(Tn)=AF(Tn-1)
        if (low<low_min && close<open) {
            AF = AF + s;//
        }else{
            //AF = *lAF;
            //AF = AF + s;
        }
    }
    
    if (AF>m) {
        AF = m;
    }
    
    
    if (day>=N) {
        // SAR(Tn)=SAR(Tn-1)+AF(Tn)*[EP(Tn-1)-SAR(Tn-1)]
        sar = lsar + AF * (EP - lsar);
        model.SAR_T = [NSString stringWithFormat:@"%d",tt];
        //sar = MA5;
        
    }
    
    if (isUp==FMStockIndexUp) {
        if ((sar>close && close<open)){
            isUp = FMStockIndexDown;
            AF = s;
            *t = 0;
            sar = [self HHV:topkey N:N day:day list:list];
            model.SAR_BUY = [NSString stringWithFormat:@"%f",close];
            model.SAR_RATE = @"0.00";
            //NSLog(@"卖出点:%@  sar=%.2f close=%.2f",model.datetime,sar,close);
        }else if (sar>low) {
            AF = *lAF;
            // *t = tt-1;
            sar = [self LLV:downKey N:N day:day list:list];
        }
        
        
    }else{
        if ((sar<close && close>=open)){
            isUp = FMStockIndexUp;
            AF = s;
            *t = 0;
            sar = [self LLV:downKey N:N day:day list:list];
            // 买入点价格
            model.SAR_BUY = [NSString stringWithFormat:@"%f",close];
            model.SAR_RATE = @"0.00";
            // NSLog(@"买入点:%@  sar=%.2f close=%.2f",model.datetime,sar,close);
        }else if (sar<high) {
            //AF = s;
            AF = *lAF;
            //*t = 0;
            sar = [self HHV:topkey N:N day:day list:list];
        }
    }
    
    // 初始值SAR(T0)的确定
    // 若T1周期中SAR(T1)上涨趋势，则SAR(T0)为T0周期的最低价，若T1周期下跌趋势，则SAR(T0)为T0周期 的最高价；。
    if (day==N) {
        if (isUp==FMStockIndexUp) {
            sar = [self LLV:downKey N:N day:day-1 list:list];
        }else{
            sar = [self HHV:topkey N:N day:day-1 list:list];
        }
        model.SAR = [NSString stringWithFormat:@"%f",sar];
        AF = s;
        
    }
    
    model.SAR = [NSString stringWithFormat:@"%f",sar];
    model.SAR_ORI = [NSString stringWithFormat:@"%f",sar];
    
    *lup = isUp;
    *lAF = AF;
    *t = *t + 1;
    //NSLog(@"%@ sar=%.2f rate=%.2f buy=%.2f close=%.2f",model.datetime, [model.SAR_ORI floatValue],[model.SAR_RATE floatValue],[model.SAR_BUY floatValue],close);
    return sar;
}

/**
 *  DMI 动向指标
 *
 *  @param N    N周期
 *  @param day  当前天数
 *  @param list k线数据
 *  @param PDI  ＋DI值
 *  @param MDI  －DI值
 *  @param ADX  ADX值
 *  @param ADXR ADXR值
 N:=14;
 MM:=6;
 MTR:=EXPMEMA(MAX(MAX(HIGH-LOW,ABS(HIGH-REF(CLOSE,1))),ABS(REF(CLOSE,1)-LOW)),N);
 HD:=HIGH-REF(HIGH,1);
 LD:=REF(LOW,1)-LOW;
 DMP:=EXPMEMA(IF(HD>0 && HD>LD,HD,0),N);
 DMM:=EXPMEMA(IF(LD>0 && LD>HD,LD,0),N);
 PDI:DMP*100/MTR;
 MDI:DMM*100/MTR;
 ADX:EXPMEMA(ABS(MDI-PDI)/(MDI+PDI)*100,MM);
 ADXR:EXPMEMA(ADX,MM);
 
 EXPMEMA ＝ (2*X + (N-1)*EXPMEMA') / (N+1)
 */
+(void)DMI:(int)N M:(int)M day:(int)day list:(NSArray*)list lDMP:(float*)lDMP lDMM:(float*)lDMM lTR:(float*)lTR lDX:(float*)lDX{
    float SMA_M = 1.0;
    if (day<=0) {
        return;
    }
    float lastADX = [self REF:@"DMI_ADX" day:day-1 list:list];
    float lastADXR = [self REF:@"DMI_ADXR" day:day-1 list:list];
    
    //    if (day==N) {
    //        // 前值都用平均值
    //        *lDMM = [self MA:@"closePrice" N:N day:day list:list];
    //        *lDMP = *lDMM;
    //        *lTR = *lDMM;
    //        *lDX = *lDMM;
    //        lastADX = *lDMM;
    //        lastADXR = *lDMM;
    //    }
    
    float DMP = 0;
    float DMM = 0;
    
    FMStockDaysModel *m = list[day];
    
    float high = [m.heightPrice floatValue];
    float low = [m.lowPrice floatValue];
    
    float lastHigh = [self REF:@"heightPrice" day:day-1 list:list];
    float lastLow = [self REF:@"lowPrice" day:day-1 list:list];
    float lastClose = [self REF:@"closePrice" day:day-1 list:list];
    
    // 1.计算当日动向值
    // 上升动向 其数值等于当日的最高价减去前一日的最高价，如果<=0 则+DM=0
    float PDM = high - lastHigh;
    // 下降动向 其数值等于前一日的最低价减去当日的最低价，如果<=0 则-DM=0
    float MDM = lastLow - low;
    // 再比较+DM和-DM，较大的那个数字保持，较小的数字归0。
    if (PDM>MDM && PDM>0) {
    }else{
        PDM = 0;
    }
    if (MDM>PDM && MDM>0) {
    }else{
        MDM = 0;
    }
    // 2.计算真实波幅（TR）
    // A、当日的最高价减去当日的最低价的价差。
    float A = fabsf(high - low);
    // B、当日的最高价减去前一日的收盘价的价差。
    float B = fabsf(high - lastClose);
    // C、当日的最低价减去前一日的收盘价的价差。
    float C = fabsf(low - lastClose);
    
    // EXPMEMA ＝ (2*X + (N-1)*EXPMEMA') / (N+1)
    
    float TR = (2.0*MAX(MAX(A, B),C)+(N-SMA_M)*(*lTR)) / (N+SMA_M);
    
    DMP = (2.0 * PDM + (N-SMA_M)*(*lDMP)) / (N+SMA_M);
    DMM = (2.0 * MDM + (N-SMA_M)*(*lDMM)) / (N+SMA_M);
    
    // 3.计算方向线DI
    float PDI = (DMP/TR) * 100.0;
    float MDI = (DMM/TR) * 100.0;
    m.DMI_PDI = [NSString stringWithFormat:@"%f",PDI];
    m.DMI_MDI = [NSString stringWithFormat:@"%f",MDI];
    
    // 4.计算动向平均数ADX
    float DX = (fabsf(PDI-MDI)/(PDI+MDI)) * 100.0;
    float ADX = (2.0*DX + (M-SMA_M)*lastADX) / (M+SMA_M);
    m.DMI_ADX = [NSString stringWithFormat:@"%f",ADX];
    float ADXR = (2.0*ADX + (M-SMA_M)*lastADXR) / (M+SMA_M);
    m.DMI_ADXR = [NSString stringWithFormat:@"%f",ADXR];
    
    *lDMM = DMM;
    *lDMP = DMP;
    *lTR = TR;
    *lDX = DX;
}

@end
