//
//  FMBaseViewController.m
//  FMMarket
//
//  Created by dangfm on 15/8/7.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMBaseViewController.h"

@interface FMBaseViewController ()

@end

@implementation FMBaseViewController
-(void)dealloc{
    NSLog(@"FMBaseViewController dealloc");
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 初始化
    [self initViews];
    [self regitserAsObserver];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = NO;
    [self clearTimer];
    //self.navigationController.view.backgroundColor = [UIColor clearColor];
    [FMAppDelegate allowRotation:NO Block:nil];
    
    // 每次观看界面的时候就检查配置
    [http getServerConfig];
    // 查看App界面期间更新下启动图的时间，只有app回到后台的时候才开始计时，下次启动就可以计算时间了
    [FMUserDefault setStartADTime];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
    [self clearTimer];
    [self.view endEditing:YES];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

-(BOOL)shouldAutorotate{
    return [FMAppDelegate isAllowRotation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)free{
    [self unregisterAsObserver];
    self.navigation = nil;
    if(self.header) self.header = nil;
    self.stateView = nil;
    [self clearTimer];
}

- (void)initViews
{
    self.navigation = (FMNavigationController*)self.navigationController;
    [self.view setBackgroundColor:ThemeColor(@"Body_Bg_Color")];
    self.automaticallyAdjustsScrollViewInsets =NO;
}

-(void)appWillEnterForeground{
    if (self) {
        if (_returnType>0) {
            [self free];
            switch (self.returnType) {
                case 1:
                    [self.navigationController popViewControllerAnimated:NO];
                    break;
                case 2:
                    [self dismissViewControllerAnimated:NO completion:nil];
                    break;
                default:
                    [self.navigationController popViewControllerAnimated:NO];
                    break;
            }
        }
    }
}
-(void)appWillEnterbackground{
    [self clearTimer];
}

-(void)appWillBecomeActive{
    
    FMBaseViewController *base = (FMBaseViewController*)[FMAppDelegate shareApp].main.currnetNav.visibleViewController;
    
    if (_timeinterval>0 && base==self) {
        [self runTimer:_timeinterval];
    }
    base = nil;
}

#pragma mark - 
#pragma mark 初始化导航
-(void)setTitle:(NSString*)title IsBack:(BOOL)back ReturnType:(int)returnType{
    //NSLog(@"BaseViewController initNavigationWithTitle");
    
    self.returnType = returnType;
    // 初始化导航视图
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat w = UIScreenWidth;
    CGFloat h = kNavigationHeight;
    _header = [[FMNavigationHeaderView alloc] initWithFrame:CGRectMake(x, y, w, h)
                                                      title:title
                                                     isBack:back];
    [self.view addSubview:_header];
    [_header.backButton addTarget:self
                           action:@selector(returnBack)
                 forControlEvents:UIControlEventTouchUpInside];
    
    // 状态栏
    _stateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 20)];
    [self.view addSubview:_stateView];
    _stateView.backgroundColor = _header.backgroundColor;
    // 适配7.0
    _header.frame = CGRectMake(_header.frame.origin.x,
                               _stateView.frame.size.height,
                               _header.frame.size.width,
                               _header.frame.size.height);
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // 配置
    [self configureViews];
}

-(void)changeHeaderBackgroundColor:(UIColor *)color titleColor:(UIColor *)titleColor{
    [self.header changeViewBackgroundColor:color titleColor:titleColor];
    _stateView.backgroundColor = self.header.backgroundColor;
}

#pragma mark 设置标题
-(void)titleWithName:(NSString*)name{
    _header.titler.text = name;
//    _header.titler.adjustsFontSizeToFitWidth = YES;
    [_header.titler sizeToFit];
    float w = UIScreenWidth - 150;
    
    _header.titler.frame = CGRectMake((self.view.frame.size.width-w)/2,
                                      (_header.frame.size.height-_header.titler.frame.size.height)/2,
                                      w,
                                      _header.titler.frame.size.height);
}

#pragma mark 返回主界面
-(void)returnBack{
    NSLog(@"returnBack");
    [self free];
    switch (self.returnType) {
        case 1:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        case 2:
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        default:
            [self.navigationController popViewControllerAnimated:YES];
            break;
    }
    
}

- (void)configureViews
{
    //NSLog(@"configureViews");
    _size = CGSizeMake(UIScreenWidth,
                       UIScreenHeight-self.header.frame.origin.y-self.header.frame.size.height);
    _point = CGPointMake(self.view.frame.origin.x,
                         self.header.frame.origin.y+self.header.frame.size.height);
    // set the background of navigationbar
    
    [self.view setBackgroundColor:ThemeColor(@"Body_Bg_Color")];
    self.stateView.backgroundColor = _header.backgroundColor;
    
//    [_header changeViewBackgroundColor];
    
}

-(void)startLoadView{
    //NSLog(@"start_view");
}


-(void)runTimer:(float)timeinterval{
    if (timeinterval<=0) {
        return;
    }
    [self clearTimer];
    _timeinterval = timeinterval;
    if (!_timer) {
        WEAKSELF
        _timer = [NSTimer timerWithTimeInterval:timeinterval
                                         target:__weakSelf
                                       selector:@selector(timerAction)
                                       userInfo:nil
                                        repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    }
    
}

-(void)clearTimer{
    if (!self.donotCloseTimer) {
        [_timer invalidate];
        _timer = nil;
    }
}

// 定时执行的方法
-(void)timerAction{

}

- (void)regitserAsObserver
{
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(configureViews)
                   name:ThemeDidChangeNotification
                 object:nil];
    
    // 联网通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name:kFMReachabilityChangedNotification
                                               object:nil];
    // 这个通知主要是配合App伪重启，一般是启动玩广告图后发送，然后就会通知各个控制器陆续返回上一级
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground)
                                                 name:kFMAppWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterbackground)
                                                 name:kFMAppWillEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillBecomeActive)
                                                 name:kFMAppWillBecomeActiveNotification object:nil];
}

- (void)unregisterAsObserver
{
    //NSLog(@"unregisterAsObserver");
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self];
}

-(void)reachabilityChanged:(NSNotification*)notification{
    
}



@end
