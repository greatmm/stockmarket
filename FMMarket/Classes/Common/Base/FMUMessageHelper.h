//
//  FMUMessageHelper.h
//  golden_iphone
//
//  Created by dangfm on 15/7/14.
//  Copyright (c) 2015年 golden. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMUMessageHelper : NSObject
@property (nonatomic, strong) NSDictionary *userInfo;
@property(nonatomic,assign) BOOL isLaunchByNotification;
+ (FMUMessageHelper *)shared;
// 在应用启动时调用此方法注册
+ (void)startWithLaunchOptions:(NSDictionary *)launchOptions;
+(void)startJPush:(NSDictionary*)launchOptions;
// 注册设备号
+ (void)registerDeviceToken:(NSData *)deviceToken;
+ (void)didReceiveRemoteNotification:(NSDictionary *)userInfo;
// 关闭接收消息通知
+ (void)unregisterRemoteNotifications;

// default is YES
// 使用友盟提供的默认提示框显示推送信息
+ (void)setAutoAlertView:(BOOL)shouldShow;

// 应用在前台时，使用自定义的alertview弹出框显示信息
+ (void)showCustomAlertViewWithUserInfo:(NSDictionary *)userInfo;

+ (void)notificationActionHandle:(NSString*)action;

@end
