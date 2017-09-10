//
//  AppDelegate.h
//  FMMarket
//
//  Created by dangfm on 15/8/7.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMLogManager.h"
#import "FMMainTabController.h"

@class FMAppDelegate;
typedef void (^didRotationBlock)(FMAppDelegate *app);

@interface FMAppDelegate : UIResponder <UIApplicationDelegate>

@property (retain, nonatomic) UIWindow *window;
@property (retain, nonatomic) FMMainTabController *main;
@property BOOL allowRotation;
@property (nonatomic,assign) UIDeviceOrientation deviceOrientation;
@property (nonatomic,copy) didRotationBlock didRotationBlock;
@property (nonatomic,retain) NSMutableArray *stocks;

+(FMAppDelegate*)shareApp;
+(void)allowRotation:(BOOL)allow Block:(didRotationBlock)didRotationBlock;
+(UIDeviceOrientation)deviceOrientation;
+(void)transtoRotation:(UIDeviceOrientation)deviceOrientation;
+(BOOL)isAllowRotation;
@end

