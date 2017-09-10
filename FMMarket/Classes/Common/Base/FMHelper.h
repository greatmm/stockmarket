//
//  FMHelper.h
//  FMMarket
//
//  Created by dangfm on 15/8/11.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMHelper : NSObject
/**
 *  获取时间戳
 *
 *  @return 精确到秒
 */
+(double)getTimestamp;

/**
 *  MD5加密
 *
 *  @param str 待加密字符串
 *
 *  @return 加密后字符串
 */
+ (NSString *)md5:(NSString *)str;

/**
 *  颜色码转颜色
 *
 *  @param stringToConvert 十六进制颜色值
 *
 *  @return 颜色
 */
+ (UIColor *) colorWithHexString: (NSString *) stringToConvert;

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
 *  汉子转拼音
 *
 *  @param sourceString 源字符串
 *
 *  @return 返回拼音字符串
 */
+(NSString *)pinyin:(NSString*)sourceString;

/**
 *  沙盒路径
 *
 *  @param filename 文件名称
 *  @param path     路径名称
 *
 *  @return 返回真实沙盒路径地址
 */
+(NSString*)sandBoxPathWithFileName:(NSString*)filename Path:(NSString*)path;

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
 *  提示框
 *
 *  @param body    内容
 *  @param title   标题
 *  @param timeout 超时关闭
 */
+(void)showMessage:(NSString*)body Title:(NSString*)title timeout:(NSInteger)timeout;
/**
 *  过滤接口数据Null值
 *
 *  @param dic 接口数据
 *
 *  @return 新数据
 */
+(NSDictionary*)checkNullWithDictionary:(NSDictionary*)dic;

/**
 *  返回真实沙盒地址 Library/Caches/
 *
 *  @param filename 文件名
 *  @param path     文件夹
 *
 *  @return 沙盒绝对路径
 */
+(NSString*)realPathWithFileName:(NSString*)filename Path:(NSString*)path;

/**
 *  搜索股票
 *
 *  @param keywords 关键词
 *
 *  @return 股票集合
 */
+(NSArray*)searchStocks:(NSString*)keywords;

/**
 *  延迟执行
 *
 *  @param senconds 延迟秒数
 *  @param block    回调
 */
+(void)sleepSeconds:(float)senconds finishBlock:(void(^)())block;

/**
 *  App名称 版本号
 *
 *  @return plist 键值
 */
+(NSString*)getAppName;
+(NSString *)getVersion;

#pragma mark 格式化Img标签
/**
 *  把webView里面的图片格式化，共前端调用
 *
 *  @param html html代码
 *
 *  @return 格式化后字符串
 */
+(NSString *)formatImgWithHTML:(NSString *)html;

/**
 *  查找html代码里面的图片标签
 *
 *  @param html html代码
 *
 *  @return 图片数组
 */
+(NSMutableArray*)findImgFromHTML:(NSString *)html;

/**
 *  解析股票代码
 *
 *  @param html 内容
 *
 *  @return 股票代码数组 [$浦发银行(600000)$,...]
 */
+(NSMutableArray*)findStocksFromContent:(NSString *)html;

/**
 *  图像翻转方向
 *
 *  @param image       图片对象
 *  @param orientation 方向参数
 *
 *  @return 翻转后图片
 */
+ (UIImage *)image:(UIImage *)image rotation:(UIImageOrientation)orientation;

/**
 *  截屏
 *
 *  @param theView 截屏的view
 *
 *  @return 截屏的图片
 */
+(UIImage *)imageFromView:(UIView *)theView;

/**
 *  查找当前VC
 *
 *  @return 当前VC
 */
+(UIViewController *)getCurrentVC;

/**
 *  单个文件的大小
 *
 *  @param filePath 文件地址
 *
 *  @return 字节大小
 */
+(long long)fileSizeAtPath:(NSString*)filePath;

/**
 *  遍历文件夹获得文件夹大小，返回多少M
 *
 *  @param folderPath 文件夹路径
 *
 *  @return 文件夹大小 单位 M
 */
+(float)folderSizeAtPath:(NSString*)folderPath;

/**
 *  删除文件夹下所有文件
 *
 *  @param folderPath 文件夹路径
 */
+(void)deleteFolderAtPath:(NSString*)folderPath;

/**
 *  截屏
 *
 *  @return 图片
 */
+(UIImage *)captureScreen;
/**
 *  计算两个日期之间相隔的天数
 *
 *  @param fromDate 较早的日期
 *  @param toDate   较晚的日期
 *
 *  @return 相隔天数
 */
+(int)daysWithFromDate:(NSDate*)fromDate toDate:(NSDate*)toDate;
@end
