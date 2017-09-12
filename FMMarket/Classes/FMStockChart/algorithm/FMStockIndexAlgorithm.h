//
//  FMStockIndexAlgorithm.h
//  FMStockChart
//
//  Created by dangfm on 15/7/26.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 涨势跌势
 */
typedef enum {
    FMStockIndexUp,
    FMStockIndexDown
} FMStockIndexUpOrDown;

@interface FMStockIndexAlgorithm : NSObject

/**
 *  计算EMA值
 *  公式：EMAn=2/(n+1)*(本周期收盘价-上一周期EMAn)+上一周期EMAn
 *
 *  @param list   本周期数据和上一周期数据
 *  @param number N值
 *
 *  @return EMA
 */
+(float)getEMA:(NSMutableArray*)list Number:(int)number;
/**
 * 计算MACD值
 *
 * @param list          N日收盘价集合
 * @param shortPeriod   短期.
 * @param longPeriod    长期.
 * @param midPeriod     M.参数：SHORT(短期)、LONG(长期)、M天数，一般为12、26、9
 * @return 返回第N日的 MACD值
 */
+(void)getMACD:(NSMutableArray*)list days:(int)day DhortPeriod:(int)shortPeriod LongPeriod:(int)longPeriod MidPeriod:(int)midPeriod;

/**
 *  KDJ算法
 *  计算公式：rsv =（收盘价– n日内最低价最低值）/（n日内最高价最高值– n日内最低价最低值）×100
 　　K = rsv的m天移动平均值
 　　D = K的m1天的移动平均值
 　　J = 3K - 2D
 　　rsv:未成熟随机值
    rsv天数默认值：9，K默认值：3，D默认值：3。
 **/
+(NSMutableDictionary*)getKDJMap:(NSArray*)list N:(int)n;


/**
 *  RSI
 *
 *  @param day  天数下标
 *  @param N    N值
 *  @param list 模型数据
 *
 算法：
 An=n个周期中所有收盘价上涨数之和/n
 Bn=n个周期中所有收盘价下跌数之和/n (取绝对值)
 RSIn=An/(An+Bn)*100
 *  @return RSI值
 */
+(float)RSI:(int)day N:(int)N list:(NSArray*)list ly:(float*)ly ly1:(float*)ly1 ;

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
+(void)getBOLLWithDay:(int)day K:(int)k N:(int)n Data:(NSArray*)data;

/**
 *  MA移动平均线
 *
 *  @param prices 收盘价集合
 *  @param ma     N值
 *  @param index  天数
 *
 *  @return 当天MA值
 */
+(float)createMAWithPrices:(NSArray*)prices MA:(CGFloat)ma Index:(int)index;
/**
 *  成交量MA移动平均线
 *
 *  @param counts 成交量集合
 *  @param ma     N值
 *  @param index  天数
 *
 *  @return 当天MA值
 */
+(float)createVolMAWithCounts:(NSArray*)counts MA:(CGFloat)ma Index:(int)index;

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
+(float)MA:(NSString*)key N:(int)N day:(int)day list:(NSArray*)list;

/**
 *  前值
 *
 *  @param key  键
 *  @param day  那一天的数据
 *  @param list 模型数据
 *
 *  @return 前值
 */
+(float)REF:(NSString*)key day:(int)day list:(NSArray*)list;



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
+(float)HHV:(NSString*)key N:(int)N day:(int)day list:(NSArray*)list;

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
+(float)LLV:(NSString*)key N:(int)N day:(int)day list:(NSArray*)list;

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
+(float)SLOPE:(NSString*)key n:(int)n day:(int)day list:(NSArray*)list;

/**
 *  OBV 量能潮
 *
 *  @param day  那一天
 *  @param list 模型数据
 *  公式：VA = V × [（C - L）- （H - C）]/（H - C）
 *  @return OBV值
 */
+(float)OBV:(int)day list:(NSArray*)list;

/**
 *  SAR指标
 *
 *  @param N    周期
 *  @param S    S是步长相当于公式的ＡＲ加速因子的0.02,但在这里 1对应0.01,最大值可以是100，相当于1。
 *  @param M    M为极值相当于公式的ＡＲ加速因子中说的0.2,也就累加到最后不能超过的值。
 *  @param list k线数据
 *  @param lAF  上一个AF值
 *  @param t    累计上涨和下跌的次数
 *  @return SAR值
 */
+(float)SAR:(int)N S:(float)S M:(float)M  day:(int)day list:(NSArray*)list lup:(FMStockIndexUpOrDown*)lup lAF:(float*)lAF t:(int*)t;

/**
 *  DMI 动向指标
 *
 *  @param N    N周期
 *  @param M    M周期 用来计算ADXR
 *  @param day  当前天数
 *  @param list k线数据
 *  @param PDI  ＋DI值
 *  @param MDI  －DI值
 *  @param ADX  ADX值
 *  @param ADXR ADXR值
 *  @param lTR  昨日TR
 */
+(void)DMI:(int)N M:(int)M day:(int)day list:(NSArray*)list lDMP:(float*)lDMP lDMM:(float*)lDMM lTR:(float*)lTR lDX:(float*)lDX;

@end
