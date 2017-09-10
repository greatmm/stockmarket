//
//  FMUserDefault.m
//  FMMarket
//
//  Created by dangfm on 15/8/15.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMUserDefault.h"

@implementation FMUserDefault


#pragma mark -
#pragma mark UserDefaults Actioin

+(void)setSeting:(NSString *)key Value:(NSString*)value{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:key];
    [defaults synchronize];
    defaults = nil;
}

+(NSString *)getSeting:(NSString*)key{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *value=[defaults objectForKey:key];
    if (!value) {
        value = @"";
    }
    defaults = nil;
    return value;
}

+(AFNetworkReachabilityStatus)internetStatus{
   return [[self getSeting:kUserDefault_InternetStatus] intValue];
}
+(void)setInternetStatus:(AFNetworkReachabilityStatus)status{
    [self setSeting:kUserDefault_InternetStatus Value:[NSString stringWithFormat:@"%d",(int)status]];
}

+(void)setDefautValues{
    BOOL isStarted = [[self getSeting:kUserDefault_IsFirstStart] boolValue];
    // 第一次启动
    if (!isStarted) {
        [self setSeting:kUserDefault_IsFirstStart Value:@"1"];
        // 设置默认值
        [self setAPNS:YES];
        [self loginOut];
        [self setSelfStockLoopTime:5];
        [self setSeting:kUserDefault_SelfStocksHttpLoopTime_NG Value:@"5"];
        [self setSeting:kUserDefault_SelfStocksHttpLoopTime_WiFi Value:@"3"];
    }
}

#pragma mark -
#pragma mark 登陆注销

+(void)loginOut{
    [self setSeting:kUserDefault_NickName Value:@""];
    [self setSeting:kUserDefault_Email Value:@""];
    [self setSeting:kUserDefault_UserId Value:@""];
    [self setSeting:kUserDefault_Mobile Value:@""];
    [self setSeting:kUserDefault_UserFace Value:@""];
    [self setSeting:kUserDefault_QQOpenId Value:@""];
    [self setSeting:kUserDefault_QQAccessToken Value:@""];
    [self setSeting:kUserDefault_WXOpenId Value:@""];
    [self setSeting:kUserDefault_WxAccessToken Value:@""];
}
+(void)setUserWithDic:(NSDictionary *)dic{
    if (dic) {
        dic = [fn checkNullWithDictionary:dic];
        NSString *nickName = [dic objectForKey:@"nickName"];
        NSString *userId = [dic objectForKey:@"id"];
        NSString *userFace = [dic objectForKey:@"userFace"];
        NSString *tel = [dic objectForKey:@"tel"];
        NSString *qq_open_id = [dic objectForKey:@"qq_open_id"];
        NSString *qq_access_token = [dic objectForKey:@"qq_access_token"];
        NSString *weixin_open_id = [dic objectForKey:@"weixin_open_id"];
        NSString *weixin_access_token = [dic objectForKey:@"weixin_access_token"];
        NSString *levelId = [dic objectForKey:@"level_id"];
        if (![userFace hasPrefix:@"http"]) {
            userFace = kURL(userFace);
        }
        
        [self setSeting:kUserDefault_NickName Value:nickName];
        [self setSeting:kUserDefault_Email Value:@""];
        [self setSeting:kUserDefault_UserId Value:userId];
        [self setSeting:kUserDefault_Mobile Value:tel];
        [self setSeting:kUserDefault_UserFace Value:userFace];
        [self setSeting:kUserDefault_QQOpenId Value:qq_open_id];
        [self setSeting:kUserDefault_QQAccessToken Value:qq_access_token];
        [self setSeting:kUserDefault_WXOpenId Value:weixin_open_id];
        [self setSeting:kUserDefault_WxAccessToken Value:weixin_access_token];
        [self setSeting:kUserDefault_LevelId Value:levelId];

    }
    
}
#pragma mark -
#pragma mark 股票
+(NSInteger)getSelfStockLoopTime{
    if ([self internetStatus]==AFNetworkReachabilityStatusReachableViaWiFi) {
        // WiFi
        [FMUserDefault setSelfStockLoopTime:[[FMUserDefault getSeting:kUserDefault_SelfStocksHttpLoopTime_WiFi] integerValue]];
    }else{
        // 非WiFi
        [FMUserDefault setSelfStockLoopTime:[[FMUserDefault getSeting:kUserDefault_SelfStocksHttpLoopTime_NG] integerValue]];
    }
    return [[self getSeting:kUserDefault_SelfStocksHttpLoopTime] integerValue];
}
+(void)setSelfStockLoopTime:(NSInteger)second{
    [self setSeting:kUserDefault_SelfStocksHttpLoopTime Value:[NSString stringWithFormat:@"%d",(int)second]];
}

+(FMSelfStocksModel *)getDapanDatas{
    NSString *json = [self getSeting:kUserDefault_DapanDatas];
    FMSelfStocksModel *m;
    if (json) {
        NSDictionary *dic = [json JSONValue];
        m = [[FMSelfStocksModel alloc] initWithDic:dic];
    }
    return m;
}
+(void)setDapanDatas:(FMSelfStocksModel *)model{
    NSArray *keys = [fn propertyKeysWithClass:[model class]];
    NSMutableDictionary *dic = [NSMutableDictionary new];
    for (NSString *key in keys) {
        id value = [model valueForKey:key];
        if (value) {
            [dic setObject:value forKey:key];
        }
        
    }
    NSString *json = [dic JSONRepresentation];
    if (json) {
        [self setSeting:kUserDefault_DapanDatas Value:json];
    }
}

#pragma mark -
#pragma mark 用户信息
+(NSString*)getUserId{
    return [self getSeting:kUserDefault_UserId];
}
+(void)setUserId:(NSString *)userId{
    if (!userId) {
        userId = @"";
    }
    [self setSeting:kUserDefault_UserId Value:userId];
}
+(NSString*)getNickName{
    return [self getSeting:kUserDefault_NickName];
}
+(void)setNickName:(NSString *)nickName{
    if (!nickName) {
        nickName = @"";
    }
    [self setSeting:kUserDefault_NickName Value:nickName];
}

+(NSString*)getGroupId{
    NSString *groupId = [self getSeting:kUserDefault_GroupId];
    if (!groupId) {
        groupId = @"0";
    }
    return groupId;
}
+(void)setGroupId:(NSString*)groupId{
    if (!groupId) {
        groupId = @"0";
    }
    [self setSeting:kUserDefault_GroupId Value:groupId];
}

+(NSString*)getMobile{
    return [self getSeting:kUserDefault_Mobile];
}
+(void)setMobile:(NSString *)mobile{
    if (!mobile) {
        mobile = @"";
    }
    [self setSeting:kUserDefault_Mobile Value:mobile];
}
+(NSString*)getQQOpenId{
    return [self getSeting:kUserDefault_QQOpenId];
}
+(void)setQQOpenId:(NSString*)openId{
    if (!openId) {
        openId = @"";
    }
    [self setSeting:kUserDefault_QQOpenId Value:openId];
}
+(NSString*)getQQAccessToken{
    return [self getSeting:kUserDefault_QQAccessToken];
}
+(void)setQQAccessToken:(NSString*)token{
    if (!token) {
        token = @"";
    }
    [self setSeting:kUserDefault_QQAccessToken Value:token];
}

+(NSString*)getWXOpenId{
    return [self getSeting:kUserDefault_WXOpenId];
}
+(void)setWXOpenId:(NSString*)openId{
    if (!openId) {
        openId = @"";
    }
    [self setSeting:kUserDefault_WXOpenId Value:openId];
}
+(NSString*)getWXAccessToken{
    return [self getSeting:kUserDefault_WxAccessToken];
}
+(void)setWXAccessToken:(NSString*)token{
    if (!token) {
        token = @"";
    }
    [self setSeting:kUserDefault_WxAccessToken Value:token];
}

+(BOOL)getUserIsPayed{
    return [[self getSeting:kUserDefault_IsPayed] boolValue];
}
+(void)setUserIsPayed:(int)isPayed{
    [self setSeting:kUserDefault_IsPayed Value:[NSString stringWithFormat:@"%d",isPayed]];
}

+(NSString*)getUserFace{
    return [self getSeting:kUserDefault_UserFace];
}
+(void)setUserFace:(NSString *)src{
    [self setSeting:kUserDefault_UserFace Value:src];
}
+(UIImage *)getUserFaceImage{
    WEAKSELF
    // 那本地缓存
    NSString *userId = [NSString stringWithFormat:@"%@",[self getUserId]];
    NSString *fileName = userId;
    NSString *filePath = [fn sandBoxPathWithFileName:fileName Path:kUserDefault_UserFace_CachePath];
    UIImage *images = [UIImage imageWithContentsOfFile:filePath];
    // 如果为空，请求网络
    NSURL *src = [NSURL URLWithString:[self getUserFace]];
    
    [[SDWebImageDownloader sharedDownloader]
     downloadImageWithURL:src
     options:SDWebImageDownloaderContinueInBackground
     progress:^(NSInteger resize,NSInteger qsize){
         
     }
     completed:^(UIImage *image,NSData *data,NSError* error,BOOL isfinish){
         if (image) {
             // 下载完成
             [__weakSelf setUserFaceImage:image];
             // 发送通知
             if (!images) {
                 [[NSNotificationCenter defaultCenter] postNotificationName:kUserDefaultUserFaceDownloadNotification object:image];
             }
             
         }
         
     }];
    if (!images || [userId floatValue]<=0) {
        images = ThemeImage(@"me/me_icon_userface_normal");
    }
    return images ;
}

+(void)setUserFaceImage:(UIImage *)image{
    // 保存在本地
    NSString *userId = [NSString stringWithFormat:@"%@",[self getUserId]];
    NSString *fileName = userId;
    NSString *filePath = [fn sandBoxPathWithFileName:fileName Path:kUserDefault_UserFace_CachePath];
    NSData *data = UIImagePNGRepresentation(image);
    [data writeToFile:filePath atomically:YES];
    data = nil;
}

#pragma mark -
#pragma mark 数据库版本信息
+(NSString *)getSearchStocksVersion{
    return [self getSeting:kUserDefault_SearchStocks_VersionKeyName];
}
+(void)setSearchStocksVersion:(NSString *)version{
    [self setSeting:kUserDefault_SearchStocks_VersionKeyName Value:version];
}
+(NSArray *)getSearchStocks{
    NSString *json = [self getSeting:kUserDefault_SearchStocks];
    NSArray *datas = [json JSONValue];
    json = nil;
    return datas;
}
+(void)setSearchStocks:(NSArray *)datas{
    if (datas) {
        NSString *json = [datas JSONRepresentation];
        [self setSeting:kUserDefault_SearchStocks Value:json];
        json = nil;
    }
    
}

#pragma mark -
#pragma mark 系统信息
+(NSString *)getDeviceToken{
    return [self getSeting:kUserDefault_DeviceToken];
}
+(void)setDeviceToken:(NSString *)deviceToken{
    NSLog(@"%@",deviceToken);
    [self setSeting:kUserDefault_DeviceToken Value:deviceToken];
}

+(BOOL)isAPNS{
    NSString *apns = [self getSeting:kUserDefault_APNS];
    if (!apns) {
        apns = @"0";
    }
    return [apns boolValue];
}
+(void)setAPNS:(BOOL)isOpen{
    [self setSeting:kUserDefault_APNS Value:[NSString stringWithFormat:@"%d",isOpen]];
}

#pragma mark -
#pragma mark 服务器配置
+(BOOL)marketIsClose{
    NSString *isClose = [self getSeting:kUserDefault_marketIsClose];
    if ([isClose floatValue]<=0) {
        isClose = @"0";
    }
    return [isClose boolValue];
}
+(void)setMarketIsClose:(BOOL)close{
    [self setSeting:kUserDefault_marketIsClose Value:[NSString stringWithFormat:@"%d",close]];
}

#pragma mark -
#pragma mark 启动图配置
+(BOOL)isStartAD{
    // 时间戳
    NSString *lastTime = [self getSeting:kUserDefault_LastStartTime];
    if ([lastTime doubleValue]>0) {
        // 时间比对是否超过1个小时
        double t = ceil([fn getTimestamp]/1000 - [lastTime doubleValue]);
        if (t>kUserDefault_StartTimeout) {
            return YES;
        }else{
            return false;
        }
    }else{
        return YES;
    }
    return false;
}

+(void)setStartADTime{
    NSString *lastTime = [NSString stringWithFormat:@"%.f",([fn getTimestamp]/1000)];
    [self setSeting:kUserDefault_LastStartTime Value:lastTime];
}

+(NSDictionary*)getStartADDatas{
    NSString *lastTime = [self getSeting:kUserDefault_StartAdDatas];
    if (lastTime) {
        NSDictionary *datas = [lastTime JSONValue];
        if ([datas isKindOfClass:[NSDictionary class]]) {
            return datas;
        }
    }
    return nil;
}

+(void)setStartADDatas:(NSDictionary*)datas{
    if ([datas isKindOfClass:[NSDictionary class]]) {
        [self setSeting:kUserDefault_StartAdDatas Value:[datas JSONRepresentation]];
        // 获取启动广告图路径并下载
        NSDictionary *data = datas[@"data"];
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSString *pic_ios = data[@"pic_ios"];
            NSString *pic_domain = data[@"pic_domain"];
            if (![pic_ios isEqual:[NSNull null]]) {
                if ([pic_ios hasPrefix:@"["]) {
                    pic_ios = [pic_ios replaceAll:@"[" target:@""];
                    pic_ios = [pic_ios replaceAll:@"]" target:@""];
                    pic_ios = [pic_ios replaceAll:@"\\" target:@""];
                    pic_ios = [pic_ios replaceAll:@"\"" target:@""];
                    if ([pic_ios indexOf:@","]) {
                        NSArray *a = [pic_ios componentsSeparatedByString:@","];
                        pic_ios = a.firstObject;
                    }else{
                        
                    }
                }
                if ([pic_ios isKindOfClass:[NSString class]]) {
                    NSString *src = [pic_domain stringByAppendingString:pic_ios];
                    if (src) {
                        [self setStartAdImage:src];
                    }else{
                        
                    }
                }
            }
            
        }
    }
    
}
+(UIImage *)getStartAdImage{
    // 那本地缓存
    NSString *fileName = kUserDefault_StartAdImage_FileName;
    NSString *filePath = [fn sandBoxPathWithFileName:fileName Path:kUserDefault_StartAdImage_CachePath];
    UIImage *image = [UIImage imageWithContentsOfFile:filePath];
    return image;
}

+(void)setStartAdImage:(NSString *)src{
    NSString *fileName = kUserDefault_StartAdImage_FileName;
    NSString *filePath = [fn sandBoxPathWithFileName:fileName Path:kUserDefault_StartAdImage_CachePath];
    if ([src isEqualToString:@""] || !src) {
        // 清空本地广告图
        NSFileManager *manager = [NSFileManager defaultManager];
        [manager removeItemAtPath:filePath error:nil];
        return;
    }
    NSURL *url = [NSURL URLWithString:src];
    [[SDWebImageDownloader sharedDownloader]
     downloadImageWithURL:url
     options:SDWebImageDownloaderContinueInBackground
     progress:^(NSInteger resize,NSInteger qsize){
         
     }
     completed:^(UIImage *image,NSData *data,NSError* error,BOOL isfinish){
         if (image) {
             // 下载完成
             // 保存在本地
             
             NSData *data = UIImageJPEGRepresentation(image, 100);
             [data writeToFile:filePath atomically:YES];
             data = nil;
         }
         
     }];
}

+ (BOOL)isShowUserGuideLoad{
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lastRunVersion = [defaults objectForKey:kUserDefault_LastStartVersion];
    if (!lastRunVersion) {
        [defaults setObject:currentVersion forKey:kUserDefault_LastStartVersion];
        return YES;
    }else if (![lastRunVersion isEqualToString:currentVersion]) {
        [defaults setObject:currentVersion forKey:kUserDefault_LastStartVersion];
        return YES;
    }
    return NO;
}

@end
