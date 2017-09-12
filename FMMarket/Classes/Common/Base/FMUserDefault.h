//
//  FMUserDefault.h
//  FMMarket
//
//  Created by dangfm on 15/8/15.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SDWebImageDownloader.h>
#define kUserDefault_UserFace_CachePath @"UserInfo/"
#define kUserDefault_StartAdImage_CachePath @"StartAd/"
#define kUserDefault_StartAdImage_FileName @"StartAd.png"

#define kUserDefault_UserId @"market_userId"
#define kUserDefault_Email @"market_email"
#define kUserDefault_NickName @"market_nickName"
#define kUserDefault_Mobile @"market_mobile"
#define kUserDefault_UserFace @"market_userFace"
#define kUserDefault_IsPayed @"market_ispayed"
#define kUserDefault_Telphone @"market_telphone"
#define kUserDefault_LevelId @"market_levelId"
#define kUserDefault_GroupId @"market_groupId"
// 第三方登录
#define kUserDefault_QQOpenId @"market_QQOpenID"
#define kUserDefault_QQAccessToken @"market_QQAccessToken"
#define kUserDefault_WXOpenId @"market_WXOpenID"
#define kUserDefault_WxAccessToken @"market_WXAccessToken"
#define kUserDefault_SelfStocksHttpLoopTime @"market_SelfStocksHttpLoopTime"  // 行情刷新秒数
#define kUserDefault_SelfStocksHttpLoopTime_NG @"market_SelfStocksHttpLoopTime_NG"  // 行情刷新秒数 2G/3G/4G
#define kUserDefault_SelfStocksHttpLoopTime_WiFi @"market_SelfStocksHttpLoopTime_WiFi"  // 行情刷新秒数 WiFi
#define kUserDefault_StocksKIndexType @"market_StocksKIndexType"         // K线默认设置
#define kUserDefault_SearchStocks_VersionKeyName @"searchStocks_Version" // 搜索数据库的版本

#define kUserDefault_DapanDatas @"market_dapanDatas"

#define kUserDefaultUserFaceDownloadNotification @"kUserDefaultUserFaceDownloadNotification"

#define kUserDefault_DeviceToken @"market_deviceToken"
#define kUserDefault_APNS @"market_apns"
#define kUserDefault_IsFirstStart @"market_isFirstStart"
#define kUserDefault_InternetStatus @"market_internetStatus" // 网络状态
#define kUserDefault_SearchStocks @"market_SearchStocks"     // 本地搜索数据库
#define kUserDefault_marketIsClose @"market_marketIsClose"   // 远程是否收盘，收盘的话就不用轮询刷新了
#define kUserDefault_LastStartTime @"market_lastStartTime"   // 启动图上次启动时间
#define kUserDefault_IsStartAd @"market_IsStartAd"           // 启动图是否启动
#define kUserDefault_StartAdDatas @"market_StartAdDatas"     // 启动图广告数据
#define kUserDefault_LastStartVersion @"market_LastStartVersion" // 引导图最后启动版本号



@interface FMUserDefault : NSObject
#pragma mark -
#pragma mark UserDefaults Actioin
+(void)setSeting:(NSString *)key Value:(NSString*)value;
+(NSString *)getSeting:(NSString*)key;
+(void)setDefautValues;
+(AFNetworkReachabilityStatus)internetStatus;
+(void)setInternetStatus:(AFNetworkReachabilityStatus)status;
#pragma mark -
#pragma mark 登陆注销
+(void)loginOut;
+(void)setUserWithDic:(NSDictionary*)dic;

#pragma mark -
#pragma mark 股票
//  自选股循环更新秒数
+(NSInteger)getSelfStockLoopTime;
+(void)setSelfStockLoopTime:(NSInteger)second;
//  大盘数据 Json格式
+(FMSelfStocksModel*)getDapanDatas;
+(void)setDapanDatas:(FMSelfStocksModel*)model;

#pragma mark -
#pragma mark 用户信息
//  获取用户ID
+(NSString*)getUserId;
+(void)setUserId:(NSString *)userId;
+(NSString*)getNickName;
+(void)setNickName:(NSString *)nickName;
+(NSString*)getMobile;
+(void)setMobile:(NSString *)mobile;
+(NSString*)getGroupId;
+(void)setGroupId:(NSString*)groupId;
// qq登录返回的openId
+(NSString*)getQQOpenId;
+(void)setQQOpenId:(NSString*)openId;
// qq登录返回的token
+(NSString*)getQQAccessToken;
+(void)setQQAccessToken:(NSString*)token;
// wx登录返回的openId
+(NSString*)getWXOpenId;
+(void)setWXOpenId:(NSString*)openId;
// wx登录返回的token
+(NSString*)getWXAccessToken;
+(void)setWXAccessToken:(NSString*)token;
// 是否付费用户
+(BOOL)getUserIsPayed;
+(void)setUserIsPayed:(int)isPayed;

//  设置用户头像
+(NSString*)getUserFace;
+(void)setUserFace:(NSString*)src;
+(UIImage*)getUserFaceImage;
+(void)setUserFaceImage:(UIImage*)image;

#pragma mark -
#pragma mark 数据库版本信息
+(NSString*)getSearchStocksVersion;
+(void)setSearchStocksVersion:(NSString*)version;
+(NSArray*)getSearchStocks;
+(void)setSearchStocks:(NSArray*)datas;

#pragma mark -
#pragma mark 系统信息
+(NSString*)getDeviceToken;
+(void)setDeviceToken:(NSString*)deviceToken;

+(BOOL)isAPNS;
+(void)setAPNS:(BOOL)isOpen;

#pragma mark -
#pragma mark 服务器配置
+(BOOL)marketIsClose;
+(void)setMarketIsClose:(BOOL)close;

#pragma mark -
#pragma mark 启动图配置
+(BOOL)isStartAD;
/**
 *  设置启动图启动时间
 */
+(void)setStartADTime;

// 获取已下载的启动广告数据
+(NSDictionary*)getStartADDatas;
// 保存已下载的启动广告数据
+(void)setStartADDatas:(NSDictionary*)datas;
// 获取已下载的启动图广告
+(UIImage *)getStartAdImage;
// 下载广告图存本地
+(void)setStartAdImage:(NSString *)src;
// 引导页
+(BOOL)isShowUserGuideLoad;

@end
