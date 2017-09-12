//
//  FMNavigationController.m
//  FMMarket
//
//  Created by dangfm on 15/8/7.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMNavigationController.h"
#import "UIImage+stocking.h"

@interface FMNavigationController ()

@end

@implementation FMNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    
}

-(BOOL)shouldAutorotate{
    return [FMAppDelegate isAllowRotation];
}

-(void)initViews{
    // Do any additional setup after loading the view.
    self.navigationBar.backgroundColor = ThemeColor(@"Navigation_Bg_Color");
    self.navigationBar.barTintColor = ThemeColor(@"Navigation_Bg_Color");
    //[self.navigationBar setBackgroundImage:[UIImage imageWithColor:ThemeColor(@"Navigation_Bg_Color") andSize:self.navigationBar.frame.size] forBarMetrics:UIBarMetricsDefault];
    //[self.navigationBar setShadowImage:[UIImage imageWithColor:ThemeColor(@"Navigation_Bg_Color") andSize:self.navigationBar.frame.size]];
    self.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    //self.navigationBar.alpha = 0.5;
    if (!_line) {
        _line = [fn drawLineWithSuperView:self.navigationBar
                                    Color:self.navigationBar.backgroundColor
                                 Location:1];
    }
}

-(void)changeLineBackgroundColor:(UIColor *)color{
    _line.backgroundColor = color;
    self.navigationBar.backgroundColor = color;
    self.navigationBar.barTintColor = color;
    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:color andSize:CGSizeMake(UIScreenWidth, 64)] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[UIImage imageWithColor:color andSize:_line.frame.size]];
}

@end
