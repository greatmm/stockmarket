//
//  FMCommon.h
//  FMStockChart
//
//  Created by dangfm on 15/7/26.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FMCommon : NSObject

+ (NSString *)md5:(NSString *)str;

/**
 *  十六进制颜色值转换
 *
 *  @param hex 十六进制颜色值
 *
 *  @return 颜色对象
 */
+(UIColor*)colorWithHex:(int)hex;

/**
 *  颜色转换
 *
 *  @param color 颜色代码 #FFFF000
 *
 *  @return 颜色对象
 */
+(UIColor *)colorWithHexString:(NSString *)color;
/**
 *  画线条
 *
 *  @param superView 父视图
 *  @param color     线条延伸
 *  @param location  位置 0=顶部 1=底部
 *
 *  @return 线条
 */
+(UIView*)drawLineWithSuperView:(UIView*)superView Color:(UIColor*)color Location:(NSInteger)location;

/**
 *  自定义线条
 *
 *  @param superView 父视图
 *  @param color     延伸
 *  @param frame     位置
 *
 *  @return 线条
 */
+(UIView*)drawLineWithSuperView:(UIView*)superView Color:(UIColor*)color Frame:(CGRect)frame;

/**
 *  反射对象所有属性
 *
 *  @param classs 对象
 *
 *  @return 属性数组
 */
+(NSArray*)propertyKeysWithClass:(Class)classs;
/**
 *  赋值对象所有属性
 *
 *  @param dataSource 值字典
 *  @param target     对象
 *
 *  @return 是否成功
 */
+(BOOL)reflectDataFromOtherObject:(NSObject*)dataSource WithTarget:(id)target;

/**
 *  计算两个时间的间隔
 *
 *  @param startDate 开始时间
 *  @param endDate   结束时间
 *
 *  @return 时间戳
 */
+(NSTimeInterval)compareDate:(NSDate*)startDate EndDate:(NSDate*)endDate;

/**
 *  字符串转时间
 *
 *  @param str 字符串
 *
 *  @return 输出时间
 */
+(NSDate*)stringToDate:(NSString*)str;

+(NSDate*)stringToDate:(NSString*)str format:(NSString*)format;
/**
 *  时间转日期yyyyMMdd字符串
 *
 *  @param date 时间对象
 *
 *  @return yyyyMMdd
 */
+(NSString*)dateToString:(NSDate*)date;

/**
 *  时间转字符串
 *
 *  @param date   时间
 *  @param format 转换格式 如 yyyy-MM-dd hh:mm:ss
 *
 *  @return 格式化后字符串
 */
+(NSString*)dateToString:(NSDate*)date target:(NSString*)format;

/**
 *  处理数据里的Null值
 *
 *  @param dic 字典
 *
 *  @return 优良数据格式
 */
+(NSDictionary*)checkNullWithDictionary:(NSDictionary *)dic;

/**
 *  32位随机字符串
 *
 *  @return 32位随机字符串
 */
+(NSString *)ret32bitString;

/**
 *  数字转换为单位计量
 *
 *  @param price 存数字字符串
 *
 *  @return 单位为  万，或者 亿
 */
+(NSString*)moneyWithPrice:(NSString*)price;
@end
