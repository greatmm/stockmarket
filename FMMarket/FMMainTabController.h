//
//  FMMainTabController.h
//  FMMarket
//
//  Created by dangfm on 15/8/7.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FMMainTabController : UITabBarController

@property (nonatomic,assign) NSInteger sessionUnreadCount;

@property (nonatomic,assign) NSInteger systemUnreadCount;

@property (nonatomic,assign) NSInteger customSystemUnreadCount;

+ (instancetype)instance;

- (UINavigationController*)currnetNav;

- (void)refreshSettingBadge;

@end
