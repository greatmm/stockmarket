//
//  FMMainTabController.m
//  FMMarket
//
//  Created by dangfm on 15/8/7.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMMainTabController.h"
#import "FMAppDelegate.h"
#import "FMSelfStocksViewController.h"
#import "FMSettingViewController.h"
#import "FMNavigationController.h"
#import "FMBaseViewController.h"
#import "FMTabBarItem.h"

#define TabbarVC    @"vc"
#define TabbarTitle @"title"
#define TabbarImage @"image"
#define TabbarSelectedImage @"selectedImage"
#define TabbarItemBadgeValue @"badgeValue"

@interface FMMainTabController ()<UINavigationControllerDelegate>



@end

@implementation FMMainTabController

+ (instancetype)instance{
    FMAppDelegate *delegete = (FMAppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *vc = delegete.window.rootViewController;
    if ([vc isKindOfClass:[FMMainTabController class]]) {
        return (FMMainTabController *)vc;
    }else{
        return nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpSubNav];
    [self getHttpUserUnReadCount];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setUpStatusBar];
}

-(void)viewWillLayoutSubviews
{
    self.view.frame = [UIScreen mainScreen].bounds;
}

-(BOOL)shouldAutorotate{
    return [FMAppDelegate isAllowRotation];
}


- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray*)tabbars{
    
    NSArray *item = @[
     
                      @{
                          TabbarVC           : @"FMSelfStocksViewController",
                          TabbarTitle        : @"行情",
                          TabbarImage        : @"icon_maintab_selfstocks_normal",
                          TabbarSelectedImage: @"icon_maintab_selfstocks_pressed",
                          TabbarItemBadgeValue: @(self.sessionUnreadCount)
                          },
//                      @{
//                          TabbarVC           : @"FMMarketViewController",
//                          TabbarTitle        : @"行情",
//                          TabbarImage        : @"icon_maintab_market_normal",
//                          TabbarSelectedImage: @"icon_maintab_market_pressed",
//                          TabbarItemBadgeValue: @(self.systemUnreadCount)
//                          },
                       @{
                          TabbarVC           : @"FMMeViewController",
                          TabbarTitle        : @"我",
                          TabbarImage        : @"icon_maintab_mind_normal",
                          TabbarSelectedImage: @"icon_maintab_mind_pressed",
                          TabbarItemBadgeValue: @(self.customSystemUnreadCount)
                          },
                      
                      ];
    return item;
}

//设置自控制器
- (void)setUpSubNav{
    NSMutableArray * array = [[NSMutableArray alloc] init];
    [self.tabbars enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary * item = obj;
        NSString * vcName = item[TabbarVC];
        NSString * title  = item[TabbarTitle];
        NSString * imageName = item[TabbarImage];
        NSString * imageSelected = item[TabbarSelectedImage];
        Class clazz = NSClassFromString(vcName);
        FMBaseViewController * vc = [[clazz alloc] init];
        vc.hidesBottomBarWhenPushed = NO;
        FMNavigationController *nav = [[FMNavigationController alloc] initWithRootViewController:vc];
        nav.delegate = self;
        UIImage *defaultImage = [UIImage imageNamed:imageName];
        defaultImage = [defaultImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        defaultImage = [UIImage imageWithTintColor:FMTabbarColor blendMode:kCGBlendModeDestinationIn WithImageObject:defaultImage];
        nav.tabBarItem = [[FMTabBarItem alloc] initWithTitle:title image:defaultImage selectedImage:[UIImage imageNamed:imageSelected]];
        nav.tabBarItem.tag = idx;
        NSInteger badge = [item[TabbarItemBadgeValue] integerValue];
        if (badge) {
            nav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%zd",badge];
        }
        [array addObject:nav];
    }];
    self.viewControllers = array;

}

//设置状态栏
- (void)setUpStatusBar{
    [self.navigationController.navigationBar setTranslucent:YES];
    [self.tabBar setTranslucent:YES];
    self.tabBar.tintColor = [UIColor whiteColor];
    self.tabBar.selectedImageTintColor = FMNavColor;
    UIStatusBarStyle style = UIStatusBarStyleLightContent;
    [[UIApplication sharedApplication] setStatusBarStyle:style animated:NO];
}

- (UINavigationController *)currnetNav{
    return (FMNavigationController *)self.selectedViewController;
}


- (void)refreshSessionBadge{
    FMNavigationController *nav = self.viewControllers[0];
    nav.tabBarItem.badgeValue = self.sessionUnreadCount ? @(self.sessionUnreadCount).stringValue : nil;
}

- (void)refreshContactBadge{
    FMNavigationController *nav = self.viewControllers[1];
    NSInteger badge = self.systemUnreadCount;
    nav.tabBarItem.badgeValue = badge ? @(badge).stringValue : nil;
}

- (void)refreshSettingBadge{
    FMNavigationController *nav = self.viewControllers.lastObject;
    NSInteger badge = self.customSystemUnreadCount;
    nav.tabBarItem.badgeValue = badge ? @(badge).stringValue : nil;
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

-(void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    
}


-(void)getHttpUserUnReadCount{
    WEAKSELF
    if ([[FMUserDefault getUserId]intValue]>0) {
        [http getUsersUnReadCountWithFromUserId:nil Start:^{
            
        } failure:^{
            
        } success:^(NSDictionary*dic){
            NSString *count = [NSString stringWithFormat:@"%@",dic[@"data"]];
            __weakSelf.customSystemUnreadCount = [count intValue];
            [__weakSelf refreshSettingBadge];
            
            [fn sleepSeconds:15 finishBlock:^{
                [__weakSelf getHttpUserUnReadCount];
            }];
        }];
    }else{
        [fn sleepSeconds:15 finishBlock:^{
            [__weakSelf getHttpUserUnReadCount];
        }];
    }
    
}

@end
