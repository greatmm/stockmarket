//
//  FMCommon.m
//  FMStockChart
//
//  Created by dangfm on 15/7/26.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMCommon.h"
#import <CommonCrypto/CommonCrypto.h>
#import <objc/runtime.h>

@implementation FMCommon

+ (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, strlen(cStr), result); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}


//  16进制数值转化为颜色对象
+(UIColor*)colorWithHex:(int)hex{
    return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0
                           green:((float)((hex & 0xFF00) >> 8))/255.0
                            blue:((float)(hex & 0xFF))/255.0
                           alpha:1.0];
}

// 颜色转换  #fff000 转换成颜色对象
+ (UIColor *) colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

//  线条
+(UIView*)drawLineWithSuperView:(UIView*)superView Color:(UIColor*)color Location:(NSInteger)location{
    CGRect frame = superView.frame;
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0.5)];
    if (location>0) {
        line.frame = CGRectMake(0, frame.size.height-0.5, frame.size.width, 0.5);
    }
    line.backgroundColor = color;
    [superView addSubview:line];
    return line;
}

//  自定义线条
+(UIView*)drawLineWithSuperView:(UIView*)superView Color:(UIColor*)color Frame:(CGRect)frame{
    UIView *line = [[UIView alloc] initWithFrame:frame];
    line.backgroundColor = color;
    [superView addSubview:line];
    return line;
}

//  反射对象所有属性
+(NSArray*)propertyKeysWithClass:(Class)classs
{
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(classs, &outCount);
    NSMutableArray *keys = [[NSMutableArray alloc] initWithCapacity:outCount];
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        [keys addObject:propertyName];
    }
    free(properties);
    return keys;
}

//  赋值对象所有属性
+(BOOL)reflectDataFromOtherObject:(NSObject*)dataSource WithTarget:(id)target
{
    BOOL ret = NO;
    for (NSString *key in [self propertyKeysWithClass:[target class]]) {
        if ([dataSource isKindOfClass:[NSDictionary class]]) {
            ret = ([dataSource valueForKey:key]==nil)?NO:YES;
        }
        else
        {
            ret = [dataSource respondsToSelector:NSSelectorFromString(key)];
        }
        if (ret) {
            id propertyValue = [dataSource valueForKey:key];
            //该值不为NSNULL，并且也不为nil
            if (![propertyValue isKindOfClass:[NSNull class]] && propertyValue!=nil) {
                [target setValue:propertyValue forKey:key];
            }
        }
    }
    return ret;
}

//  时间间隔
+(NSTimeInterval)compareDate:(NSDate*)startDate EndDate:(NSDate*)endDate{
    NSTimeInterval time = [startDate timeIntervalSinceDate:endDate];
    return time;
}

//  字符串转时间
+(NSDate*)stringToDate:(NSString*)str{
    NSDate *strDate = [self stringToDate:str format:@"yyyyMMdd"];
    return strDate;
}

+(NSDate*)stringToDate:(NSString*)str format:(NSString*)format{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSDate *strDate = [dateFormatter dateFromString:str];
    dateFormatter = nil;
    return strDate;
}

// 时间转日期yyyyMMdd字符串
+(NSString*)dateToString:(NSDate*)date{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    dateFormatter = nil;
    return strDate;
}

// 时间转字符串
+(NSString*)dateToString:(NSDate*)date target:(NSString*)format{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    NSString *strDate = [dateFormatter stringFromDate:date];
    dateFormatter = nil;
    return strDate;
}

// 处理NUll值
+(NSDictionary*)checkNullWithDictionary:(NSDictionary *)dic{
    NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    for (NSString *key in dic.allKeys) {
        id value = [dic objectForKey:key];
        
        if (!value || [value isEqual:[NSNull null]]) {
            value = @"";
        }
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        NSString *tempValue = [NSString stringWithFormat:@"%@",value];
        if ([f numberFromString:tempValue]) {
            value = [NSString stringWithFormat:@"%@",value];
        }
        f = nil;
        tempValue = nil;
        [newDic setObject:value forKey:key];
    }
    return newDic;
}

// 32位随机字符串
+(NSString *)ret32bitString{
    char data[32];
    for (int x=0;x<32;data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [[NSString alloc] initWithBytes:data length:32 encoding:NSUTF8StringEncoding];
}

// 加单位
+(NSString*)moneyWithPrice:(NSString*)price{
    float p = [price floatValue];
    price = [NSString stringWithFormat:@"%.2f",p];
    if (fabsf(p)>10000.0f) {
        price = [NSString stringWithFormat:@"%.2f万",p/10000];
    }
    if (fabsf(p)>10000*10000.0f) {
        price = [NSString stringWithFormat:@"%.2f亿",p/10000/10000];
    }
    return price;
}



@end
