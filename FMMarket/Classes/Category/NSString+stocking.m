//
//  NSString+stocking.m
//  FMMarket
//
//  Created by dangfm on 15/8/18.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "NSString+stocking.h"


@implementation NSString (date)

- (NSString *)dateWithFormat:(NSString *)source target:(NSString *)target {
    NSDateFormatter *sourceDateFormatter = [[NSDateFormatter alloc] init];
    [sourceDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    sourceDateFormatter.dateFormat = source;
    NSDateFormatter *targetDateFormatter = [[NSDateFormatter alloc] init];
    [targetDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    targetDateFormatter.dateFormat = target;
    NSString *str = [targetDateFormatter stringFromDate:[sourceDateFormatter dateFromString:self]];
    
    if (str == nil) {
        return @"";
    } else {
        return str;
    }
}

- (NSDate *)stringToDateWithFormat:(NSString *)format{
    NSDateFormatter *sourceDateFormatter = [[NSDateFormatter alloc] init];
    [sourceDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    sourceDateFormatter.dateFormat = format;
    return [sourceDateFormatter dateFromString:self];
}

+ (NSString *)stringFromDate:(NSDate *)date format:(NSString *)format {
    NSDateFormatter *targetDateFormatter = [[NSDateFormatter alloc] init];
    [targetDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    targetDateFormatter.dateFormat = format;
    NSString *str = [targetDateFormatter stringFromDate:date];
    
    if (str == nil) {
        return @"";
    } else {
        return str;
    }
}

- (NSString *)plainDate {
    NSString *str = [self stringByReplacingOccurrencesOfString:@"/" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"-" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@":" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"年" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"月" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"日" withString:@""];
    return str;
}
// 当前时间添加年，月，日
+(NSDate *)dateWithAddYear:(int)year Month:(int)month Day:(int)day withData:(NSDate *)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    //NSCalendarIdentifierGregorian:iOS8之前用NSGregorianCalendar
    NSDateComponents *comps = nil;
    
    comps = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    //NSCalendarUnitYear:iOS8之前用NSYearCalendarUnit,NSCalendarUnitMonth,NSCalendarUnitDay同理
    
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    
    [adcomps setYear:year];
    
    [adcomps setMonth:month];
    
    [adcomps setDay:day];
    
    return [calendar dateByAddingComponents:adcomps toDate:date options:0];
}

- (NSString *)yyyyMMddHHmmss {
    return [[self plainDate] dateWithFormat:@"yyyyMMddHHmmss" target:@"yyyyMMddHHmmss"];
}

- (NSString *)yyyyMMddHHmm {
    return [[self plainDate] dateWithFormat:@"yyyyMMddHHmmss" target:@"yyyyMMddHHmm"];
}

- (NSString *)yyyyMMdd {
    return [[self plainDate] dateWithFormat:@"yyyyMMddHHmmss" target:@"yyyyMMdd"];
}

- (NSString *)yyMMdd {
    return [[self plainDate] dateWithFormat:@"yyyyMMdd" target:@"yyMMdd"];
}

- (NSString *)MMdd {
    return [[self plainDate] dateWithFormat:@"yyyyMMddHHmmss" target:@"MMdd"];
}

- (NSString *)HHmmss {
    return [[self plainDate] dateWithFormat:@"yyyyMMddHHmmss" target:@"HHmmss"];
}

- (NSString *)HHmm {
    return [[self plainDate] dateWithFormat:@"yyyyMMddHHmmss" target:@"HHmm"];
}

- (NSString *)yyyyMMddHHmm:(NSString *)split {
    return [[self plainDate] dateWithFormat:@"yyyyMMddHHmm" target:[NSString stringWithFormat:@"yyyy%@MM%@dd HH:mm", split, split]];
}

- (NSString *)yyyyMMddHHmmss:(NSString *)split {
    return [[self plainDate] dateWithFormat:@"yyyyMMddHHmmss" target:[NSString stringWithFormat:@"yyyy%@MM%@dd HH:mm:ss", split, split]];
}

- (NSString *)yyyyMMdd:(NSString *)split {
    return [[self plainDate] dateWithFormat:@"yyyyMMdd" target:[NSString stringWithFormat:@"yyyy%@MM%@dd", split, split]];
}

- (NSString *)yyMMdd:(NSString *)split {
    return [[self plainDate] dateWithFormat:@"yyyyMMdd" target:[NSString stringWithFormat:@"yy%@MM%@dd", split, split]];
}

- (NSString *)MMdd:(NSString *)split {
    return [[self plainDate] dateWithFormat:@"MMdd" target:[NSString stringWithFormat:@"MM%@dd", split]];
}

- (NSString*)distanceNowTime{
    double nowTime = [[NSDate date] timeIntervalSince1970];
    double time = [self doubleValue];
    if (time > 999999999999) {
        time = time/1000;
    }
    double secondes = nowTime - time;
    NSString *result = @"";
    result = [NSString stringWithFormat:@"%.f秒前",secondes];
    
    if (secondes>60.0) {
        result = [NSString stringWithFormat:@"%.f分钟前",secondes/60];
    }
    if (secondes>60.0*60.0) {
        result = [NSString stringWithFormat:@"%.f小时前",secondes/(60*60)];
    }
    if (secondes>60.0*60.0*24.0) {
        result = [NSString stringWithFormat:@"%.f天前",secondes/(60*60*24)];
    }
    if (secondes>60.0*60.0*24.0*30.0) {
        result = [NSString stringWithFormat:@"%.f个月前",secondes/(60*60*24*30)];
    }
    if (secondes>60.0*60.0*24.0*365.0) {
        result = [NSString stringWithFormat:@"%.f年前",secondes/(60*60*24*365)];
    }
    
    return result;
}

@end

@implementation NSString (cstring)
//查找和替换
- (NSString *)replaceAll:(NSString *)search target:(NSString *)target {
    NSString *str = [self stringByReplacingOccurrencesOfString:search withString:target];
    return str;
}

//对应位置插入
- (NSString *)insertAt:(NSString *)str post:(NSUInteger)post {
    NSString *str1 = [self substringToIndex:post];
    NSString *str2 = [self substringFromIndex:post];
    return [[str1 stringByAppendingString:str] stringByAppendingString:str2];
}

- (NSUInteger)indexOf:(NSString *)str {
    if (str == nil) {
        return NSNotFound;
    }
    
    if ([str isEqualToString:@""]) {
        return NSNotFound;
    }
    
    return [self rangeOfString:str].location;
}

//尾部位置追加
- (NSString *)append:(NSString *)str {
    return [self stringByAppendingString:str];
}

//头部位置插入
- (NSString *)concate:(NSString *)str {
    return [str stringByAppendingString:self];
}

//对应字符分割
- (NSArray *)split:(NSString *)split {
    return [self componentsSeparatedByString:split];
}

//去除多余的空白字符
- (NSString *)trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

//去除多余的特定字符
- (NSString *)trim:(NSString *)trim {
    NSString *str = self;
    str = [str trimLeft:trim];
    str = [str trimRight:trim];
    return str;
}

//去除左边多余的空白字符
- (NSString *)trimLeft {
    return [self trimLeft:@" "];
}

//去除左边多余的特定字符
- (NSString *)trimLeft:(NSString *)trim {
    NSString *str = self;
    while ([str hasPrefix:trim]) {
        str = [str substringFromIndex:[trim length]];
    }
    return str;
}

//去除右边多余的空白字符
- (NSString *)trimRight {
    return [self trimRight:@" "];
}

//去除右边多余的特定字符
- (NSString *)trimRight:(NSString *)trim {
    NSString *str = self;
    while ([str hasSuffix:trim]) {
        str = [str substringToIndex:([str length] - [trim length])];
    }
    return str;
}

//取得字符串的左边特定字符数
- (NSString *)left:(NSUInteger)num {
    //TODO:判断Index
    return [self substringToIndex:num];
}

//取得字符串的右边特定字符数
- (NSString *)right:(NSUInteger)num {
    //TODO:判断Index
    return [self substringFromIndex:([self length] - num)];
}

//取得字符串的右边特定字符数
- (NSString *)left:(NSUInteger)left right:(NSUInteger)right {
    return [[self left:left] right:right];
}

- (NSString *)right:(NSUInteger)right left:(NSUInteger)left {
    return [[self right:right] left:left];
}
@end

@implementation NSString (convert)

//-(NSString *) nilIsZero
//{
//    return [self nilIs:@"0"];
//}
//
//-(NSString *) nilIsBlank
//{
//    return [self nilIs:@""];
//}
//
//-(NSString *) nilIsSpace
//{
//    return [self nilIs:@" "];
//}
//
//-(NSString *) nilIs:(NSString *)replace
//{
//    if (self == nil)
//    {
//        return replace;
//    }else {
//        return self;
//    }
//}

//"" -> nil
- (NSString *)blankIsNil {
    return [self blankIs:nil];
}

//"" -> " "
- (NSString *)blankIsSpace {
    return [self blankIs:@" "];
}

//"" -> 0
- (NSString *)blankIsZero {
    return [self blankIs:@"0"];
}

//"" -> replace
- (NSString *)blankIs:(NSString *)replace {
    if ([self isEqualToString:@""]) {
        return replace;
    } else {
        return self;
    }
}


//" " -> nil
- (NSString *)spaceIsNil {
    return [self spaceIs:nil];
}

//" " -> ""
- (NSString *)spaceIsBlank {
    return [self spaceIs:@""];
}

//" " -> 0
- (NSString *)spaceIsZero {
    return [self spaceIs:@"0"];
}

//" " -> replace
- (NSString *)spaceIs:(NSString *)replace {
    if ([self isEqualToString:@" "]) {
        return replace;
    } else {
        return self;
    }
}

@end

@implementation NSString (decimal)

- (NSString *)decimal; {
    //定义格式化串
    NSNumberFormatter *decimalformatter = [[NSNumberFormatter alloc] init];
    decimalformatter.numberStyle = NSNumberFormatterDecimalStyle;
    
    return [decimalformatter stringFromNumber:[NSNumber numberWithDouble:[[self numberic] doubleValue]]];
}


- (NSString *)zero {
    return [self zeroIs:@"-"];
}

- (NSString *)zeroIsBlank {
    return [self zeroIs:@""];
}

- (NSString *)zeroIsNil {
    return [self zeroIs:nil];
}

- (NSString *)zeroIsSpace {
    return [self zeroIs:@" "];
}

- (NSString *)zeroIs {
    return [self zeroIs:@"-"];
}

- (NSString *)zeroIs:(NSString *)replace {
    //如果当期值不是0
    if ([[self numberic] doubleValue] == 0) {
        return replace;
    } else {
        return self;
    }
}

- (NSString *)numberic; {
    //字符串还原
    NSString *str = [self stringByReplacingOccurrencesOfString:@"," withString:@""];
    if (str.length > 1 && [str floatValue] == 0.0 && [[str substringToIndex:1] isEqualToString:@"-"]) {
        str = [str substringToIndex:1];
    }
    str = [str stringByReplacingOccurrencesOfString:@"," withString:@""];
    return str;
}

- (NSString *)decimal:(NSUInteger)deci {
    NSMutableString *ms = [[NSMutableString alloc] init];
    [ms appendString:@"###,###,###,##0"];
    if (deci != 0) {
        [ms appendString:@"."];
    }
    for (int i = 0; i < deci; i++) {
        [ms appendString:@"0"];
    }
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setPositiveFormat:ms];
    return [numberFormatter stringFromNumber:[NSNumber numberWithDouble:[[self numberic] doubleValue]]];
}

- (NSString *)currency:(NSString *)code {
    if ([code isEqualToString:@"HKD"]) {
        return [self decimal:3];
    } else if ([code isEqualToString:@"USD"]) {
        return [self decimal:2];
    } else if ([code isEqualToString:@"JPY"]) {
        return [self decimal:0];
    } else {
        return self;
    }
}

- (NSString *)normal; {
    //字符串还原
    return [self numberic];
}

- (NSString *)decimalWithSign {
    NSString *str = [self decimal];
    
    if ([[str numberic] doubleValue] > 0) {
        return [NSString stringWithFormat:@"+%@", str];
    } else {
        return str;
    }
}

- (NSString *)decimalWithSign:(NSUInteger)deci {
    NSString *str = [self decimal:deci];
    if ([[str numberic] doubleValue] > 0) {
        return [NSString stringWithFormat:@"+%@", str];
    } else {
        return str;
    }
}

- (UIColor *)colorForSign {
    if ([[self numberic] doubleValue] > 0) {
        return [UIColor redColor];
    } else if ([[self numberic] doubleValue] == 0) {
        return [UIColor blackColor];
    } else if ([[self numberic] doubleValue] < 0) {
        return [UIColor blueColor];
    } else {
        return nil;
    }
}

- (UIColor *)colorForCompare:(NSString *)value {
    if ([[self numberic] doubleValue] > [[value numberic] doubleValue]) {
        return [UIColor redColor];
    } else if ([[self numberic] doubleValue] == [[value numberic] doubleValue]) {
        return [UIColor blackColor];
    } else if ([[self numberic] doubleValue] < [[value numberic] doubleValue]) {
        return [UIColor blueColor];
    } else {
        return nil;
    }
}

- (UIColor *)colorForCompareDouble:(double)value {
    if ([[self numberic] doubleValue] > value) {
        return [UIColor redColor];
    } else if ([[self numberic] doubleValue] == value) {
        return [UIColor blackColor];
    } else if ([[self numberic] doubleValue] < value) {
        return [UIColor blueColor];
    } else {
        return nil;
    }
}


@end

@implementation NSString (tag)

#pragma mark -
#pragma mark 标签处理

//查找和替换
- (NSString *)replaceAll:(NSString *)search target:(NSString *)target {
    NSString *str = [self stringByReplacingOccurrencesOfString:search withString:target];
    return str;
}

-(NSString *)URLEncodedString
{
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)self,
                                                              (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                                              NULL,
                                                              kCFStringEncodingUTF8));
    //    NSString *encodedString = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return encodedString;
}
-(NSString *)clearHTML
{
    NSString *html = self;
    if (!html) {
        return nil;
    }
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    NSString * srctext = nil;
    int imgcount = 0;
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<img" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&srctext];
        // 获取图片地址
        NSString *src = [srctext substringFromIndex:[srctext rangeOfString:@"src="].location+5];
        src = [src substringToIndex:[src rangeOfString:@"\""].location];
        src = [src stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        src = [src URLEncodedString];
        //替换字符
        if (![src isEqualToString:@""] && ![src isEqual:[NSNull null]] && src) {
            if ([src rangeOfString:@"http://"].location ==  NSNotFound) {
                html = [html stringByReplacingOccurrencesOfString:src withString:@""];
            }else{
                html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",srctext] withString:[NSString stringWithFormat:@"[_image]%@[/_image]",src]];
            }
            imgcount += 1;
        }
        
        src = nil;
    }
    scanner = [NSScanner scannerWithString:html];
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    if ([html rangeOfString:@"[_image]"].location==NSNotFound) {
        html = [html stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    }
    
    html = [html stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    html = [html stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
    
    html = [html stringByReplacingOccurrencesOfString:@"[_image]" withString:@"\n<_image>"];
    html = [html stringByReplacingOccurrencesOfString:@"[/_image]" withString:@"</_image>\n"];
    
    html = [html stringByReplacingOccurrencesOfString:@"	" withString:@" "];
    html = [html stringByReplacingOccurrencesOfString:@"" withString:@" "];
    //html = [html stringByAppendingString:@"<_image>giraffe.png</_image>"];
    
    
    return html;
}

//  除了img标签和p标签
-(NSString *)clearHTMLWithoutImgAndP
{
    NSString *html = self;
    if (!html) {
        return nil;
    }
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    scanner = [NSScanner scannerWithString:html];
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        if (![text hasPrefix:@"<p"] && ![text hasPrefix:@"</p"] && ![text hasPrefix:@"<img"]) {
            html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
        }
        
    }
    
    return html;
}
// 清除A标签
-(NSString *)clearHref
{
    NSString *html = self;
    if (!html) {
        return nil;
    }
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<a" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
        //找到标签的起始位置
        [scanner scanUpToString:@"</a" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    return html;
}
// 清除Img标签
-(NSString *)clearImgs
{
    NSString *html = self;
    if (!html) {
        return nil;
    }
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<img" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@"/>" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/>",text] withString:@""];
        
    }
    return html;
}

// 格式化Img标签
-(NSString *)formatImg
{
    NSString *html = self;
    if (!html) {
        return nil;
    }
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    int i=0;
    
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<img" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@"/>" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/>",text] withString:[NSString stringWithFormat:@"<a href=""show(%d)"">%@/></a>",i,text]];
        i++;
    }
    return html;
}

-(NSArray*)findImgs
{
    NSString *html = self;
    if (!html) {
        return nil;
    }
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    NSMutableArray *imgs = [NSMutableArray new];
    while([scanner isAtEnd]==NO)
    {
        
        //找到标签的起始位置
        [scanner scanUpToString:@"<img" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        // 获取图片地址
        NSString *src = [text substringFromIndex:[text rangeOfString:@"src="].location+5];
        src = [src substringToIndex:[src rangeOfString:@"\""].location];
        src = [src stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        src = [src URLEncodedString];
        NSString *width ;//= [text substringFromIndex:[text rangeOfString:@"width:"].location+6];
        //width = [width substringToIndex:[width rangeOfString:@"px"].location];
        NSString *height ;//= [text substringFromIndex:[text rangeOfString:@"height:"].location+7];
        //height = [height substringToIndex:[height rangeOfString:@"px"].location];
        width = @"";
        height = @"";
        if (src) {
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                 src,@"src",
                                 width,@"width",
                                 height,@"height",
                                 nil];
            
            [imgs addObject:dic];
            
            
        }
        
        src = nil;
    }
    [imgs removeLastObject];
    return imgs;
}



@end
