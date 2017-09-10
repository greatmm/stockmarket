//
//  FMHelper.m
//  FMMarket
//
//  Created by dangfm on 15/8/11.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMHelper.h"
#import <objc/runtime.h>
#import <CommonCrypto/CommonCrypto.h>

@implementation FMHelper

+(double)getTimestamp{
    NSDate *date = [NSDate date];
    NSTimeInterval time = [date timeIntervalSince1970];
    double timestamp = ceil(time*1000);
    return timestamp;
}

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

//  十六进制转为颜色
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
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
                [target setValue:[NSString stringWithFormat:@"%@",propertyValue] forKey:key];
            }
        }
    }
    return ret;
}
// 汉子转拼音
+(NSString *)pinyin:(NSString*)sourceString {
    NSMutableString *source = [sourceString mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformStripDiacritics, NO);
    NSArray *ar = [source componentsSeparatedByString:@" "];
    sourceString = @"";
    for (NSString *item in ar) {
        if (item.length>1) {
            sourceString = [sourceString stringByAppendingString:[item substringToIndex:1]];
        }else{
            sourceString = [sourceString stringByAppendingString:item];
        }
        
    }
    return sourceString;
}

// 沙盒目录
+(NSString*)sandBoxPathWithFileName:(NSString*)filename Path:(NSString*)path{
    //获取应用程序沙盒的Library目录
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES);
    path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"/Caches/%@",path]];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    BOOL isdirectory = YES;
    if (![filemanager fileExistsAtPath:path isDirectory:&isdirectory]) {
        [filemanager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //NSLog(@"path:%@",path);
    //得到完整的文件名
    NSString *fullFileName=[path stringByAppendingPathComponent:filename];
    
    return fullFileName;
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

//  弹出提醒信息
+(void)showMessage:(NSString*)body Title:(NSString*)title timeout:(NSInteger)timeout{
    UIAlertView *alertView =  [[UIAlertView alloc] init];
    [alertView setTitle:title];
    [alertView setMessage:body];
    [alertView addButtonWithTitle:@"关闭"];
    [alertView show];
    [alertView performSelector:@selector(dismissWithClickedButtonIndex:animated:) withObject:nil afterDelay:timeout];
}

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

//  返回真实沙盒地址
+(NSString*)realPathWithFileName:(NSString*)filename Path:(NSString*)path{
    //获取应用程序沙盒的目录
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES);
    path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"/Caches/%@",path]];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    BOOL isdirectory = YES;
    if (![filemanager fileExistsAtPath:path isDirectory:&isdirectory]) {
        [filemanager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    //NSLog(@"path:%@",path);
    //得到完整的文件名
    NSString *fullFileName=[path stringByAppendingPathComponent:filename];
    
    return fullFileName;
}

+(NSArray*)searchStocks:(NSString*)keywords{
    //*代表通配符,Like也接受[cd].
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@",keywords];
    NSArray *stocks = [FMAppDelegate shareApp].stocks;
    NSArray *rs = [stocks filteredArrayUsingPredicate:predicate];
    if (rs.count<=0) {
        rs = @[keywords];
    }
    predicate = nil;
    stocks = nil;
    return rs;
}

+(void)sleepSeconds:(float)senconds finishBlock:(void(^)())block{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //sleep((int)senconds);
        [NSThread sleepForTimeInterval:senconds];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block();
            }
        });
    });
}

+(NSString*)getAppName{
    NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
    NSString* appName =[infoDict objectForKey:@"CFBundleDisplayName"];
    return appName;
}

+(NSString *)getVersion{
    //版本号
    NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
    NSString* version =[infoDict objectForKey:@"CFBundleShortVersionString"];
    return version;
}

#pragma mark 格式化Img标签
+(NSString *)formatImgWithHTML:(NSString *)html
{
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
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:[NSString stringWithFormat:@"<a href=\"jingling://show(%d)\">%@/></a>",i,text]];
        i++;
    }
    return html;
}

+(NSMutableArray*)findImgFromHTML:(NSString *)html
{
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
        if ([text rangeOfString:@"src="].location!=NSNotFound) {
            NSString *src = [text substringFromIndex:[text rangeOfString:@"src="].location+5];
            src = [src substringToIndex:[src rangeOfString:@"\""].location];
            src = [src stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            src = [src stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
                
                [imgs addObject:[NSMutableDictionary dictionaryWithDictionary:dic]];
                
                
            }
            
            src = nil;
        }
        
    }
    [imgs removeLastObject];
    return imgs;
}

+(NSMutableArray*)findStocksFromContent:(NSString *)html
{
    if (!html) {
        return nil;
    }
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    NSMutableArray *stocks = [NSMutableArray new];
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"$" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@")$ " intoString:&text];
        // 获取股票代码
        if (text) {
            text = [text replaceAll:@"$ " target:@""];
            if (![text isEqualToString:@""]) {
                [stocks addObject:[text append:@")$"]];
            }
            text = nil;
        }
        
    }
//    [stocks removeLastObject];
    return stocks;
}

+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation
{
    long double rotate = 0.0;
    CGRect rect;
    float translateX = 0;
    float translateY = 0;
    float scaleX = 1.0;
    float scaleY = 1.0;
    switch (orientation) {
        case UIImageOrientationLeft:
            rotate = M_PI_2;
            rect = CGRectMake(0, 0, image.size.height, image.size.width);
            translateX = 0;
            translateY = -rect.size.width;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationRight:
            rotate = 3 * M_PI_2;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.height;
            translateY = 0;
            scaleY = rect.size.width/rect.size.height;
            scaleX = rect.size.height/rect.size.width;
            break;
        case UIImageOrientationDown:
            rotate = M_PI;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = -rect.size.width;
            translateY = -rect.size.height;
            break;
        default:
            rotate = 0.0;
            rect = CGRectMake(0, 0, image.size.width, image.size.height);
            translateX = 0;
            translateY = 0;
            break;
    }
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    //做CTM变换
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextRotateCTM(context, rotate);
    CGContextTranslateCTM(context, translateX, translateY);
    CGContextScaleCTM(context, scaleX, scaleY);
    //绘制图片
    CGContextDrawImage(context, CGRectMake(0, 0, rect.size.width, rect.size.height), image.CGImage);
    UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
    return newPic;
    
}

+(UIImage *)imageFromView:(UIView *)theView
{
    
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

+(UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

+ (UIViewController *)getCurrentRootViewController {
    
    UIViewController *result;
    UIWindow *topWindow = [[UIApplication sharedApplication] keyWindow];
    
    if (topWindow.windowLevel != UIWindowLevelNormal){
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(topWindow in windows){
            if (topWindow.windowLevel == UIWindowLevelNormal)
                break;
        }
    }
    
    UIView *rootView = [topWindow subviews].firstObject;
    id nextResponder = [rootView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]]){
        result = nextResponder;
    }
    else if ([nextResponder isKindOfClass:[UITabBarController class]] | [nextResponder isKindOfClass:[UINavigationController class]]){
        result = [self findViewController:nextResponder];
    }
    else if ([topWindow respondsToSelector:@selector(rootViewController)] && topWindow.rootViewController != nil){
        result = topWindow.rootViewController;
    }
    
    else{
        NSAssert(NO, @"找不到顶端VC");
    }
    return result;
}

+(UIViewController *)findViewController:(id)controller{
    if ([controller isKindOfClass:[UINavigationController class]]) {
        return [self findViewController:[(UINavigationController *)controller visibleViewController]];
    }
    else if ([controller isKindOfClass:[UITabBarController class]]){
        return [self findViewController:[(UITabBarController *)controller selectedViewController]];
    }
    else if ([controller isKindOfClass:[UIViewController class]]){
        return controller;
    }
    else{
        NSAssert(NO, @"找不到顶端VC");
        return nil;
    }
}

//单个文件的大小
+(long long)fileSizeAtPath:(NSString*)filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

//遍历文件夹获得文件夹大小，返回多少M
+(float)folderSizeAtPath:(NSString*)folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        NSLog(@"文件夹：%@",fileAbsolutePath);
        NSArray *filter = kClearCacheFolders;
        for (NSString *folder in filter) {
            if ([fileAbsolutePath containsString:folder]) {
                folderSize += [self fileSizeAtPath:fileAbsolutePath];
            }
        }
    }
    return folderSize/(1024.0*1024.0);
}

+(void)deleteFolderAtPath:(NSString*)folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        // 过滤一下
        NSArray *filter = kClearCacheFolders;
        for (NSString *folder in filter) {
            if ([fileAbsolutePath containsString:folder]) {
                [manager removeItemAtPath:fileAbsolutePath error:NULL];
            }
        }
        
    }

}


+(UIImage *)captureScreen {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    CGRect rect = [keyWindow bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [keyWindow.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+(int)daysWithFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate{
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setFirstWeekday:2];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *fDate;
    NSDate *tDate;
    [gregorian rangeOfUnit:NSDayCalendarUnit startDate:&fDate interval:NULL forDate:fromDate];
    [gregorian rangeOfUnit:NSDayCalendarUnit startDate:&tDate interval:NULL forDate:toDate];
    NSDateComponents *dayComponents = [gregorian components:NSDayCalendarUnit fromDate:fDate toDate:tDate options:0];
    // dayComponents.day  即为间隔的天数
    return (int)dayComponents.day;
}
@end
