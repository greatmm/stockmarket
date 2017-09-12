//
//  AppDelegate.m
//  FMMarket
//
//  Created by dangfm on 15/8/7.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//
#import <FMStockChart/FMStockChart.h>
#import "FMMainTabController.h"
#import "FMUMessageHelper.h"
#import "FMBackgroundRun.h"
#import "FMAppDelegate.h"
#import "FMDBManager.h"
//#import "FMPostSignalToServer.h"
#import "UMSocialSinaSSOHandler.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"
//#import <AVOSCloudCrashReporting.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WXApi.h"
@interface FMAppDelegate ()<WXApiDelegate>

@end

@implementation FMAppDelegate

+(FMAppDelegate *)shareApp{
    return (FMAppDelegate *)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    self.deviceOrientation = UIDeviceOrientationPortrait;
    self.allowRotation = NO;
    // 第一次启动 设置一些默认配置值
    [FMUserDefault setDefautValues];
//    // 下载广告图
    [http getStartAd];
//    // 下载新闻栏目数据
    [http getArticleColumnListWithStart:nil failure:nil success:nil];
//    // 开启日志
    [[FMLogManager sharedManager] start];
//    // 创建数据库
    [FMDBManager shareManager];
//    // 设置广告最后启动时间 广告会每隔N分钟启动
    [FMUserDefault setStartADTime];
//    // 设置controller
    [self setupMainViewController];
    
    // 启动网络检查
    [http checkInternetIsConnect];
    // 配置k线图SDK Key
    [HttpManager config:kAPI_Key
                 server:kBaseURL
              userIdKey:kUserDefault_UserId
           userIsPayKey:kUserDefault_IsPayed];
    // umeng
    UMConfigInstance.appKey = kUmeng_AppKey;
    [MobClick startWithConfigure:UMConfigInstance];
//    [MobClick startWithAppkey:kUmeng_AppKey];
    // 注册推送
    [FMUMessageHelper startJPush:launchOptions];
    // 设置加载框风格
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    // 启动下载用户自选数据
    [[FMBackgroundRun instance] firstDownloadMySelfStocksWithBlock:nil];
    // 启动一些任务线程
//    [[FMPostSignalToServer shareManager] postStartWithPrices:nil];
    // 友盟分享
    [self addUmengShareSDK];
    // 微信登录
    [WXApi registerApp:kShare_WeixinAppKey];
    
    // Enable Crash Reporting
//    [AVOSCloudCrashReporting enable];
//    // 如果使用美国站点，请加上下面这行代码：
//    // [AVOSCloud setServiceRegion:AVServiceRegionUS];
//    [AVOSCloud setApplicationId:kLeancloud_AppId clientKey:kLeancloud_AppKey];
//    [AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    return YES;
}

#pragma mark 推送注册成功
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)pToken {
    NSLog(@"regisger success:%@", pToken);
    [FMUserDefault setDeviceToken:[NSString stringWithFormat:@"%@",[[[[pToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]stringByReplacingOccurrencesOfString: @">" withString: @""] stringByReplacingOccurrencesOfString: @" " withString: @""]]];
 
     [FMUMessageHelper registerDeviceToken:pToken];
    
}
#pragma mark 处理推送信息
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    // 处理推送消息
    //    NSLog(@"userInfo == %@",userInfo);
    [FMUMessageHelper showCustomAlertViewWithUserInfo:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
    // 处理推送消息
    //    NSLog(@"userInfo == %@",userInfo);
    [FMUMessageHelper showCustomAlertViewWithUserInfo:userInfo];
    
}
#pragma mark 注册推送失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    // 一般是系统禁用了推送
    NSLog(@"Regist fail%@",error);
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"APP 将要挂起");
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    NSLog(@"APP 回到后台");
    [FMUserDefault setMarketIsClose:YES];
    [FMUserDefault setStartADTime];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFMAppWillEnterBackgroundNotification object:nil];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    NSLog(@"APP 将要回到前台");
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // 发送一个App将要激活的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:kFMAppWillBecomeActiveNotification object:nil];
    [http getServerConfig];
    // 下载广告图
    [http getStartAd];
    // 推送信息是否被通知打断
    [FMUMessageHelper shared].isLaunchByNotification = YES;
    // 如果时间到，能启动广告图
    if ([FMUserDefault isStartAD]) {
        if (_main) {
            [FMUMessageHelper shared].isLaunchByNotification = NO;
            [fn sleepSeconds:0.5 finishBlock:^{
                // 通知启动广告图
                [[NSNotificationCenter defaultCenter] postNotificationName:kFMAppStartAdViewNotification object:nil];
                
            }];
        }
        
    }
//    self.main = nil;
//    self.stocks = nil;
//    self.window = nil;
//    [self setupMainViewController];
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    NSLog(@"APP 已激活");
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    NSLog(@"APP 终止");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL result = [UMSocialSnsService handleOpenURL:url];
    if (result == FALSE) {
        //调用其他SDK，例如支付宝SDK等
        // QQ登录
        result = [TencentOAuth HandleOpenURL:url];
        if (result==false) {
            result = [WXApi handleOpenURL:url delegate:self];
        }
    }
    
    return result;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    BOOL result = [UMSocialSnsService handleOpenURL:url];
    if (result == FALSE) {
        //调用其他SDK，例如支付宝SDK等
        // QQ登录
        result = [TencentOAuth HandleOpenURL:url];
        if (result==false) {
            result = [WXApi handleOpenURL:url delegate:self];
        }
    }
    
    return result;
}



#pragma mark -
#pragma mark 屏幕旋转代理
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (self.allowRotation) {
        //self.interfaceOrientationType = UIInterfaceOrientationMaskAll;
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        //self.interfaceOrientationType = UIInterfaceOrientationMaskPortrait;
        return UIInterfaceOrientationMaskPortrait;
    }
    
}
-(void)application:(UIApplication *)application didChangeStatusBarOrientation:(UIInterfaceOrientation)oldStatusBarOrientation{
    NSLog(@"didChangeStatusBarOrientation");
    
    //self.interfaceOrientationType = oldStatusBarOrientation;
    if (self.didRotationBlock) {
        self.didRotationBlock(self);
    }
    //self.allowRotation = NO;
}
-(void)application:(UIApplication *)application willChangeStatusBarOrientation:(UIInterfaceOrientation)newStatusBarOrientation duration:(NSTimeInterval)duration{
    NSLog(@"willChangeStatusBarOrientation");
    self.deviceOrientation = (UIDeviceOrientation)newStatusBarOrientation;
}

#pragma mark -
#pragma mark 自定义方法
- (void)setupMainViewController
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor grayColor];
    [self.window makeKeyAndVisible];
    
    FMMainTabController *mainTab = [[FMMainTabController alloc]  init];
    self.window.rootViewController = mainTab;
    self.stocks = [NSMutableArray new];
    self.main = mainTab;
}

+(void)allowRotation:(BOOL)allow Block:(didRotationBlock)didRotationBlock{
    FMAppDelegate *me = (FMAppDelegate*)[UIApplication sharedApplication].delegate;
    me.allowRotation = allow;
    me.didRotationBlock = didRotationBlock;
    me = nil;
    
}

+(UIDeviceOrientation)deviceOrientation{
    FMAppDelegate *me = (FMAppDelegate*)[UIApplication sharedApplication].delegate;
    return me.deviceOrientation;
    me = nil;
}
// 强制旋转
+(void)transtoRotation:(UIDeviceOrientation)deviceOrientation{
    //强制旋转
    FMAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = YES;
    
    // 竖屏点击按钮 旋转到横屏
    UIDevice *device = [UIDevice currentDevice] ;
    if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
    }else{
        // 横屏点击按钮, 旋转到竖屏
        if (UIDeviceOrientationIsPortrait(device.orientation) && !UIDeviceOrientationIsPortrait(appDelegate.deviceOrientation)) {
            [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];//这句话是防止手动先把设备置为竖屏,导致下面的语句失效.
            [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
        }else{
            [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
        }
        
    }
    
    appDelegate = nil;
}

+(BOOL)isAllowRotation{
    FMAppDelegate *me = (FMAppDelegate*)[UIApplication sharedApplication].delegate;
    return me.allowRotation;
}

// 友盟分享
-(void)addUmengShareSDK{
    //设置友盟社会化组件appkey
    [UMSocialData setAppKey:kUmeng_AppKey];
    [UMSocialData openLog:NO];
    //设置微信AppId、appSecret，分享url
    [UMSocialWechatHandler setWXAppId:kShare_WeixinAppKey appSecret:kShare_WeixinAppSecret url:nil];
    //设置手机QQ 的AppId，Appkey，和分享URL，需要#import "UMSocialQQHandler.h"
    [UMSocialQQHandler setQQWithAppId:kShare_QQAppId appKey:kShare_QQAppKey url:@"http://www.baidu.com"];
    //打开新浪微博的SSO开关，设置新浪微博回调地址，这里必须要和你在新浪微博后台设置的回调地址一致。需要 #import "UMSocialSinaSSOHandler.h"
    [UMSocialSinaSSOHandler openNewSinaSSOWithAppKey:kShare_SinaAppKey
                                              secret:kShare_SinaAppSecret
                                         RedirectURL:kShare_SinaRedirectURL];
}


//授权后回调 WXApiDelegate
-(void)onResp:(BaseReq *)resp
{
    /*
     ErrCode ERR_OK = 0(用户同意)
     ERR_AUTH_DENIED = -4（用户拒绝授权）
     ERR_USER_CANCEL = -2（用户取消）
     code    用户换取access_token的code，仅在ErrCode为0时有效
     state   第三方程序发送时用来标识其请求的唯一性的标志，由第三方程序调用sendReq时传入，由微信终端回传，state字符串长度不能超过1K
     lang    微信客户端当前语言
     country 微信用户当前国家信息
     */
    
    if ([resp isKindOfClass:[SendAuthResp class]]) //判断是否为授权请求，否则与微信支付等功能发生冲突
    {
        SendAuthResp *aresp = (SendAuthResp *)resp;
        if (aresp.errCode== 0)
        {
            NSLog(@"code %@",aresp.code);
            [[NSNotificationCenter defaultCenter] postNotificationName:kWechatDidLoginNotification object:self userInfo:@{@"code":aresp.code}];
        }
        if (aresp.errCode<0) {
            [SVProgressHUD showErrorWithStatus:aresp.errStr];
        }
    }
}

@end
