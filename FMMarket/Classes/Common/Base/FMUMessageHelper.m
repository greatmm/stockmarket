//
//  FMUMessageHelper.m
//  golden_iphone
//
//  Created by dangfm on 15/7/14.
//  Copyright (c) 2015年 golden. All rights reserved.
//

#import "FMUMessageHelper.h"
#import "UMessage.h"
#import "FMAppDelegate.h"
#import "FMKLineChartViewController.h"
#import "FMWebViewController.h"
//#import "FMCelueViewController.h"
//#import "FMTeacherDetailViewController.h"
//#import "FMTacticsDetailViewController.h"
//#import "FMCommunityDetailViewController.h"

#define kFMUMessageAction_OpenStock @"openStock"
#define kFMUMessageAction_OpenNews @"openNews"
#define kFMUMessageAction_OpenBS @"openBS"
#define kFMUMessageAction_OpenObject @"openObject"

// ios 8.0 以后可用，这个参数要求指定为固定值
#define kCategoryIdentifier @"xiaoyaor"

@implementation FMUMessageHelper

+ (FMUMessageHelper *)shared {
    static FMUMessageHelper *sharedObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!sharedObject) {
            sharedObject = [[[self class] alloc] init];
        }
    });
    
    return sharedObject;
}

+ (void)startWithLaunchOptions:(NSDictionary *)launchOptions {
    // set AppKey and LaunchOptions
    [UMessage startWithAppkey:kUmeng_AppKey launchOptions:launchOptions];
    //1.3.0版本开始简化初始化过程。如不需要交互式的通知，下面用下面一句话注册通知即可。
    [UMessage registerForRemoteNotifications];
    
//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_8_0
//    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
//        // register remoteNotification types
//        UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
//        action1.identifier = @"action1_identifier";
//        action1.title=@"Accept";
//        action1.activationMode = UIUserNotificationActivationModeForeground;// 当点击的时候启动程序
//        
//        UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];  // 第二按钮
//        action2.identifier = @"action2_identifier";
//        action2.title = @"Reject";
//        action2.activationMode = UIUserNotificationActivationModeBackground;// 当点击的时候不启动程序，在后台处理
//        // 需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
//        action2.authenticationRequired = YES;
//        action2.destructive = YES;
//        
//        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
//        categorys.identifier = kCategoryIdentifier;// 这组动作的唯一标示
//        [categorys setActions:@[action1,action2] forContext:(UIUserNotificationActionContextDefault)];
//        
//        UIUserNotificationType types = UIUserNotificationTypeBadge
//        | UIUserNotificationTypeSound
//        | UIUserNotificationTypeAlert;
//        UIUserNotificationSettings *userSettings = [UIUserNotificationSettings settingsForTypes:types
//                                                                                     categories:[NSSet setWithObject:categorys]];
//        
//        [UMessage registerRemoteNotificationAndUserNotificationSettings:userSettings];
//    } else {
//        // register remoteNotification types
//        UIRemoteNotificationType types = UIRemoteNotificationTypeBadge
//        | UIRemoteNotificationTypeSound
//        | UIRemoteNotificationTypeAlert;
//        
//        [UMessage registerForRemoteNotificationTypes:types];
//    }
//#else
//    // iOS8.0之前使用此注册
//    // register remoteNotification types
//    UIRemoteNotificationType types = UIRemoteNotificationTypeBadge
//    | UIRemoteNotificationTypeSound
//    | UIRemoteNotificationTypeAlert;
//    
//    [UMessage registerForRemoteNotificationTypes:types];
//#endif
    
#if DEBUG
    [UMessage setLogEnabled:YES];
#else
    [UMessage setLogEnabled:NO];
#endif
}
+(void)startJPush:(NSDictionary*)launchOptions{
    NSString *advertisingId = nil;
    //Required
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    } else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                          UIRemoteNotificationTypeSound |
                                                          UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }
    //Required
    // 如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
    BOOL isProduction = NO;
#ifdef DEBUG
    isProduction = NO;
#else
    isProduction = YES;
#endif
    
    [JPUSHService setupWithOption:launchOptions appKey:kJpush_AppKey channel:kJpush_cannel apsForProduction:isProduction];
    
}

+ (void)registerDeviceToken:(NSData *)deviceToken {
    //[UMessage registerDeviceToken:deviceToken];
    [JPUSHService registerDeviceToken:deviceToken];
    return;
}

+ (void)unregisterRemoteNotifications {
    [UMessage unregisterForRemoteNotifications];
    return;
}

+ (void)didReceiveRemoteNotification:(NSDictionary *)userInfo {
    //[UMessage didReceiveRemoteNotification:userInfo];
    [JPUSHService handleRemoteNotification:userInfo];
    return;
}

+ (void)setAutoAlertView:(BOOL)shouldShow {
    [UMessage setAutoAlert:shouldShow];
    return;
}

+ (void)showCustomAlertViewWithUserInfo:(NSDictionary *)userInfo{
    [FMUMessageHelper shared].userInfo = userInfo;
    if (![FMUMessageHelper shared].isLaunchByNotification || !userInfo) {
        return;
    }
    //[UIApplication sharedApplication].applicationIconBadgeNumber = 1;
    // 应用当前处于前台时，需要手动处理
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive || [UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UMessage setAutoAlert:NO];
            //NSURL *url = [NSURL URLWithString:[CommonOperation URLEncodedString:userInfo[@"action"]]];
            NSDictionary *params = [self urlParams:userInfo[@"action"]];
            NSString *title = [params objectForKey:@"title"];
            title = [title stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            if (!title) {
                title = @"推送消息";
            }
            NSString *intro = params[@"intro"];
            if (!intro || [intro isEqual:[NSNull null]]) {
                intro = userInfo[@"aps"][@"alert"];
            }else if ([intro isEqualToString:@""]){
                intro = userInfo[@"aps"][@"alert"];
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                                message:intro
                                                               delegate:[FMUMessageHelper shared]
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"确定", nil];
            [alertView show];
            
        });
    }
    NSLog(@"%ld",(long)[UIApplication sharedApplication].applicationState);
    return;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        // 点击确定
        // ........
        // ........
        // mfs://openStock=sh600000
        // action
        NSDictionary *userInfo = [FMUMessageHelper shared].userInfo;
        NSLog(@"userInfo:%@",userInfo[@"action"]);
        NSString *action = userInfo[@"action"];
        if (action) {
            [FMUMessageHelper notificationActionHandle:action];
        }
        
        [UMessage sendClickReportForRemoteNotification:[FMUMessageHelper shared].userInfo];
        [FMUMessageHelper shared].userInfo = nil;
    }  
    return;  
}


#pragma mark 处理推送
+(void)notificationActionHandle:(NSString*)action{
    if(!action)return;
    action = [action stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:action];
    //NSString *scheme = [url scheme];
    NSString *type = url.host;
    NSDictionary *params = [self urlParams:action];
    // 打开
    if ([type isEqualToString:kFMUMessageAction_OpenStock]) {
        NSString *code = params[@"code"];
        NSString *title = params[@"name"];
        NSString *type = params[@"type"];
        title = [title stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //NSString *intro = params[@"intro"];
        if (code) {
            FMKLineChartViewController *kline = [[FMKLineChartViewController alloc] initWithStockCode:code StockName:title Price:nil ClosePrice:nil Type:type];
            [[FMAppDelegate shareApp].main.currnetNav pushViewController:kline
                                                                          animated:YES];
            kline = nil;
        }
        
    }
    if ([type isEqualToString:kFMUMessageAction_OpenNews]) {
        NSString *newsId = params[@"articleId"];
        NSString *title = params[@"title"];
        //NSString *intro = params[@"intro"];
        NSString *h5 = params[@"h5"];
        if ([h5 rangeOfString:@"http"].location!=NSNotFound) {
            h5 = [h5 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            FMWebViewController *web = [[FMWebViewController alloc] initWithTitle:title url:[NSURL URLWithString:h5] returnType:1];
            [[FMAppDelegate shareApp].main.currnetNav pushViewController:web
                                                                animated:YES];
            web = nil;
        }else{
            NSString *url = [NSString stringWithFormat:@"%@?articleId=%@",kAPI_ArticleContent,newsId];
            NSURL *u = [NSURL URLWithString:url];
            if (u) {
                FMWebViewController *detail = [[FMWebViewController alloc] initWithTitle:@"资讯" url:u returnType:1];
                [[FMAppDelegate shareApp].main.currnetNav pushViewController:detail animated:YES];
                detail = nil;
            }
        }
        
    }
    
//    if ([type isEqualToString:kFMUMessageAction_OpenBS]) {
//        FMCelueViewController *bs = [[FMCelueViewController alloc] init];
//        [[FMAppDelegate shareApp].main.currnetNav pushViewController:bs animated:YES];
//        bs = nil;
//    }
//    
//    // 打开对象  牛人界面，策略界面，话题详情
//    if ([type isEqualToString:kFMUMessageAction_OpenObject]) {
//        NSString *objectId = params[@"objectId"];
//        NSString *objectUserId = params[@"objectUserId"];
//        if ([objectId containsString:@"@"]) {
//            NSArray *o = [objectId componentsSeparatedByString:@"@"];
//            if (o.count>1) {
//                NSString *obj = o.firstObject;
//                NSString *objId = o.lastObject;
//                if ([obj isEqualToString:@"fm_teachers"]) {
//                    // 打开牛人详情页
//                    FMTeacherModel *m = [[FMTeacherModel alloc] init];
//                    m.teacherId = objId;
//                    m.userId = objectUserId;
//                    m.objectId = objectId;
//                    FMTeacherDetailViewController *v = [[FMTeacherDetailViewController alloc] initWithTeacher:m];
//                    [[FMAppDelegate shareApp].main.currnetNav pushViewController:v animated:YES];
//                    
//                }
//                if ([obj isEqualToString:@"fm_member_tactics"]) {
//                    // 打开策略详情页
//                    FMTacticsListModel *m = [[FMTacticsListModel alloc] init];
//                    m.tacticsId = objId;
//                    m.objectId = objectId;
//                    FMTacticsDetailViewController *v = [[FMTacticsDetailViewController alloc] initWithTacticsModel:m];
//                    [[FMAppDelegate shareApp].main.currnetNav pushViewController:v animated:YES];
//                    
//                }
//                if ([obj isEqualToString:@"fm_themes"]) {
//                    // 打开牛人详情页
//                    FMCommunityListModel *m = [[FMCommunityListModel alloc] init];
//                    m.themeId = objId;
//                    m.objectId = objectId;
//                    FMCommunityDetailViewController *v = [[FMCommunityDetailViewController alloc] initWithModel:m];
//                    [[FMAppDelegate shareApp].main.currnetNav pushViewController:v animated:YES];
//                    
//                }
//                
//            }
//        }
//        
//    }
    
}

+(NSDictionary*)urlParams:(NSString*)paths{
    if ([paths rangeOfString:@"?"].location==NSNotFound) {
        return nil;
    }
    paths = [paths substringFromIndex:[paths rangeOfString:@"?"].location+1];
    NSArray *d = [paths componentsSeparatedByString:@"&"];
    NSMutableDictionary *dic = [NSMutableDictionary new];
    for (NSString *item in d) {
        NSArray *keyvalues = [item componentsSeparatedByString:@"="];
        [dic setObject:[keyvalues lastObject] forKey:[keyvalues firstObject]];
        keyvalues = nil;
    }
    
    return dic;
}


@end
