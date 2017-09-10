//
//  FMBaseViewController.h
//  FMMarket
//
//  Created by dangfm on 15/8/7.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMNavigationHeaderView.h"
#import "FMNavigationController.h"

@interface FMBaseViewController : UIViewController

@property (nonatomic,retain) FMNavigationHeaderView *header;    // 导航
@property (nonatomic,retain) UIView *footer;                    // 底部导航
@property (nonatomic,assign) int returnType;
@property (nonatomic,retain) UIView *stateView;
@property (nonatomic,assign) CGSize size;
@property (nonatomic,assign) CGPoint point;
@property (nonatomic,retain) NSOperationQueue *queue;
@property (nonatomic,retain) FMNavigationController *navigation;
@property (nonatomic,retain) NSTimer *timer;          // 定时器
@property (nonatomic,assign) float timeinterval;      // 定时时间
@property (nonatomic,assign) BOOL donotCloseTimer;    // 永远不要关闭定时器

//  初始化导航

-(void)setTitle:(NSString*)title IsBack:(BOOL)back ReturnType:(int)returnType;
-(void)titleWithName:(NSString*)name;
-(void)initViews;
-(void)configureViews;
-(void)startLoadView;
-(void)returnBack;
-(void)reachabilityChanged:(NSNotification*)notification;
-(void)runTimer:(float)timeinterval;
// 定时执行的方法
-(void)timerAction;
-(void)clearTimer;
-(void)free;
-(void)appWillEnterForeground;
-(void)changeHeaderBackgroundColor:(UIColor *)color titleColor:(UIColor *)titleColor;
@end
