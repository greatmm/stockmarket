//
//  FMKLineChartViewController.m
//  FMMarket
//
//  Created by dangfm on 15/8/16.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMKLineChartViewController.h"
#import "FMTableView.h"
#import "FMSelfStockTopViews.h"
#import "FMStockAddButtonViews.h"
#import "FMTableViewCell.h"
#import "FMStockInfoViews.h"
#import "FMStockInfoModel.h"
#import "FMKLineChartTabBar.h"
#import "FMStockChart.h"
#import "FMStockMinuteModel.h"
#import "FMKLineCashFlowViews.h"
#import "FMKLineRecentlyMainForce.h"
#import "FMAppDelegate.h"
#import "FMKLineIndexView.h"
//#import "FMPostSignalToServer.h"
#import "FMStockCompany.h"
#import "FMStockProfits.h"
#import "FMStockFinance.h"
#import "FMStockCapital.h"
#import "UILabel+stocking.h"
#import "FMBackgroundRun.h"

@interface FMKLineChartViewController()
<UITableViewDataSource,UITableViewDelegate,FMKLineChartTabBarDelegate,FMBaseViewDelegate>
{
    
}

@property (nonatomic,retain) FMTableView *tableView;
@property (nonatomic,retain) NSMutableArray *datas;
@property (nonatomic,retain) FMSelfStockTopViews *topViews;
@property (nonatomic,retain) FMStockAddButtonViews *noDataViews;
@property (nonatomic,retain) FMStockInfoViews *stockInfoViews;
@property (nonatomic,retain) FMKLineChartTabBar *chartTabBar;
@property (nonatomic,retain) FMKLineChartTabBar *sectionTwo;
@property (nonatomic,retain) FMKLineCashFlowViews *cashFlowViews;
@property (nonatomic,retain) FMKLineRecentlyMainForce *recentlyMainForce;
@property (nonatomic,retain) FMKLineIndexView *indexView;
@property (nonatomic,retain) FMStockCompany *stockCompany;
@property (nonatomic,retain) FMStockProfits *profitView;
@property (nonatomic,retain) FMStockFinance *stockFinance;
@property (nonatomic,retain) FMStockCapital *stockCapital;

@property (nonatomic,retain) UIButton *backButton;
@property (nonatomic,retain) NSString *stockCode;
@property (nonatomic,retain) NSString *stockName;
@property (nonatomic,retain) NSString *closePrice;
@property (nonatomic,retain) NSString *price;
@property (nonatomic,retain) NSString *openPrice;
@property (nonatomic,retain) NSString *highPrice;
@property (nonatomic,retain) NSString *lowPrice;

@property (nonatomic,retain) NSString *type;
@property (nonatomic,retain) NSString *lastTime;
@property (nonatomic,retain) NSString *lastDate;
@property (nonatomic,retain) UIButton *orderButton; // 下单按钮

@property (nonatomic,assign) NSInteger sectionTwoCount;

@property (nonatomic,retain) NSMutableArray *recentModels;
@property (nonatomic,retain) NSMutableArray *cashFlowModels;
@property (nonatomic,retain) NSMutableArray *profitModels;
@property (nonatomic,retain) FMStockCompanyModel *companyModel;
@property (nonatomic,retain) FMStockFinanceModel *financeModel;

// SDK
@property (nonatomic,retain) FMBaseView *klineView;
@property (nonatomic,retain) FMStockModel *klineModel;
@property (nonatomic,assign) FMMarketFuquan_Type fuquanType;
@property (nonatomic,assign) FMStockChartType stockCharType;
@property (nonatomic,assign) FMKLineStockIndexType stockIndexType;
@property (nonatomic,assign) FMKLineStockIndexType stockBottomIndexType;
@property (nonatomic,retain) UIView *klineBoxSuperView; // k线图盒子的父级时图
@property (nonatomic,retain) UILabel *vipTipView; // 非vip提示
@property (nonatomic,retain) UIView *tipViews;
@property (nonatomic,retain) UIButton *hKLineBt; // 点击横屏按钮

@property (nonatomic,retain) UIView *klineTopTipView; // 按压提示价格视图

@property (nonatomic,assign) BOOL isOut;
@property (nonatomic,assign) BOOL isOpenSignal;

@property (nonatomic,assign) float stockInfoCellHeight;
@property (nonatomic,assign) float sectionCount;
@property (nonatomic,assign) float klineBoxHeight;
@property (nonatomic,assign) float klineBoxWidth;

@property (nonatomic,assign) int sectionTwoType;

// 指标切换
@property (nonatomic,retain) NSArray *indexList;
@property (nonatomic,assign) int currentIndex;

@end

@implementation FMKLineChartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initParams];
    [self createViews];
    [self getHttpStockInfoFrom:YES];
    [self getHttpDapanStocksNewData:YES];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    // 更新数据
    _isOut = NO;
    [self loadDatas];
    [self updateHeaderViewsBackground];
    [self loopGetHttpDataWithTimeout:kFMKLineChartViewStockInfoLoopTime];
    [self loopGetHttpMinuteChartDataWithTimeout:kFMKLineChartViewMinuteChartLoopTime];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self readyScreenSwitch];
    [FMAppDelegate transtoRotation:UIDeviceOrientationUnknown];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _chartTabBar.moreViews.hidden = YES;
    _isOut = YES;
    [self resetDefaultScreenStatus];
    [FMAppDelegate allowRotation:NO Block:nil];
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound){
        //返回按钮
        [self free];
    }
}

// App 启动通知各个控制器返回首页
-(void)appWillEnterForeground{
    // 如果是横屏，那么转回来竖屏先
    [self changeScreenVertical];
    [super appWillEnterForeground];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    NSLog(@"FMKLineChartViewController dealloc");
}

-(void)free{
    [super free];
    [_chartTabBar free];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    _klineView.delegate = nil;
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _chartTabBar.delegate = nil;
    _tableView = nil;
    [_datas removeAllObjects];
    _datas = nil;
    
    _topViews = nil;
    _noDataViews = nil;
    [_stockInfoViews removeFromSuperview];
    _stockInfoViews = nil;
    _chartTabBar = nil;
    _sectionTwo = nil;
    _cashFlowViews = nil;
    _recentlyMainForce = nil;
    _indexView.clickKLineHorizontalNavButtonBlock = nil;
    _indexView = nil;
    _stockCompany = nil;
    _profitView = nil;
    _stockFinance = nil;
    _stockCapital.whenFinishedLoadDatasBlock = nil;
    _stockCapital = nil;
    
    _backButton = nil;
    
    [_recentModels removeAllObjects];
    _recentModels = nil;
    [_cashFlowModels removeAllObjects];
    _cashFlowModels = nil;
    _profitModels = nil;
    _companyModel = nil;
    _financeModel = nil;
    
    // SDK
    [FMStockChartManagerView destroyDealloc];
    _klineBoxSuperView = nil;
    [_klineView removeFromSuperview];
    [_klineView clear];
    _klineView = nil;
    _klineModel = nil;
}

//实现旋转
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation != UIDeviceOrientationPortraitUpsideDown;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}


#pragma mark -
#pragma mark Init

-(instancetype)initWithStockCode:(NSString*)code
                       StockName:(NSString*)name
                           Price:(NSString*)price
                      ClosePrice:(NSString *)closePrice
                            Type:(NSString *)type{
    if (self==[super init]) {
        _stockCode = code;
        _stockName = name;
        _closePrice = closePrice;
        _price = price;
        _type = type;
    }
    return self;
}

-(void)initParams{
    _isOut = NO;
    _datas = [NSMutableArray new];
    _cashFlowModels = [NSMutableArray new];
    _recentModels = [NSMutableArray new];
    _profitModels = [NSMutableArray new];
    // 资金栏目总数
    _sectionTwoCount = 2;
    if ([_type isEqualToString:@"1"]) {
        _sectionTwoCount = 1;
    }
    _sectionCount = 2;
    _stockInfoCellHeight = kFMStockInfoViewHeight;
    _klineBoxHeight = kFMKLineChartViewHeight-30;
    _klineBoxWidth = UIScreenWidth - 20;
    _stockIndexType = FMStockIndexType_SMA;
    _stockBottomIndexType = FMStockIndexType_MACD;
    
    _fuquanType = FMMarketFuquan_Before;
    if ([_type intValue]>0) {
        _fuquanType = FMMarketFuquan_None;
    }
    _stockCharType = FMStockType_MinuteChart;
    [self loadDatas];
    [FMAppDelegate allowRotation:NO Block:nil];
}

-(void)loadDatas{
    // 加载指标列表
    _indexList = (NSArray*)ThemeJson(@"stockindexs");
    [_datas removeAllObjects];
    [_tableView reloadData];
}
-(void)tableViewReloadData{
    [_tableView reloadData];
}

#pragma mark -
#pragma mark Screen Switch

-(void)readyScreenSwitch{
    WEAKSELF
    // 初始化横竖屏转换
    [FMAppDelegate allowRotation:YES Block:^(FMAppDelegate*app){
        if (app.deviceOrientation==UIDeviceOrientationLandscapeLeft || app.deviceOrientation==UIDeviceOrientationLandscapeRight) {
            [__weakSelf changeScreenHorizontal];
        }else{
            [__weakSelf changeScreenVertical];
        }
        //[FMAppDelegate allowRotation:NO Block:nil];
    }];
}
//  转成横轴
-(void)changeScreenHorizontal{
    float w = UIScreenWidth;
    float h = UIScreenHeight;
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    if (iPhone4) {
        if (UIScreenWidth<UIScreenHeight) {
            self.view.frame = CGRectMake(0, 0, UIScreenHeight, UIScreenWidth);
            w = UIScreenHeight;
            h = UIScreenWidth;
        }
        
    }
    //_signal.hidden = YES;
    _signal.frame = CGRectMake(UIScreenWidth/4+45, 2, _signal.frame.size.width, _signal.frame.size.height);
    _sectionCount = 1;
    _stockInfoCellHeight = 0;
    _klineBoxWidth = w - 20;
    if (_stockCharType!=FMStockType_MinuteChart && _stockCharType!=FMStockType_FiveDaysChart) {
        _klineBoxWidth = w - 20 - kFMKLineIndexViewWidth;
    }
    CGRect frame = CGRectMake(0, 0, w, h-kStatusBarHeight);
    _tableView.frame = frame;
    _tableView.tableHeaderView = nil;
    _topViews.hidden = YES;
    _stockInfoViews.hidden = YES;
    _chartTabBar.frame = CGRectMake(0, 0, w, kFMKLineChartTabBarHeight);
    _klineBoxHeight = (h-kFMKLineChartTabBarHeight-20)-self.navigationController.navigationBar.frame.size.height;
//    _klineModel.stage.width = _klineBoxWidth;
//    //[_klineView removeFromSuperview];
//    [_klineView clear];
//    _klineView.delegate = nil;
//    _klineView = nil;
//    _klineView = [[FMStockChartManagerView manager]
//                  createWithFrame:CGRectMake(10, 15, _klineBoxWidth, _klineBoxHeight)
//                  Model:_klineModel SuperView:_klineBoxSuperView];
//    _klineView.delegate = self;
    
    [self createKlineChartWithStockChartType:_stockCharType fuquanType:_fuquanType drawDatas:nil];
    
    self.navigation.line.hidden = YES;
    _tableView.scrollEnabled = NO;
    self.navigationItem.hidesBackButton = YES;
    [self createBackButtonWhenHorizontal];
    [_tableView reloadData];
    
    [_chartTabBar reloadViews];
    _orderButton.hidden = YES;
    [_chartTabBar updateHighlightsTitleWithIndex:_stockCharType];
    _chartTabBar.moreViews.hidden = YES;
    _hKLineBt.hidden = YES;
}
//  转成竖轴
-(void)changeScreenVertical{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    _signal.frame = CGRectMake(UIScreenWidth/4+30, 2, _signal.frame.size.width, _signal.frame.size.height);
    _sectionCount = 2;
    _klineBoxWidth = UIScreenWidth - 20;
    _stockInfoCellHeight = kFMStockInfoViewHeight;
    CGRect frame = CGRectMake(0, 0, UIScreenWidth, UIScreenHeight-kTabBarNavigationHeight);
    _tableView.frame = frame;
    _tableView.tableHeaderView = _topViews;
    [_tableView bringSubviewToFront:_tableView.header];
    _topViews.hidden = NO;
    _stockInfoViews.hidden = YES;
    _chartTabBar.frame = CGRectMake(0, 0, UIScreenWidth, kFMKLineChartTabBarHeight);
    _klineBoxHeight = kFMKLineChartViewHeight-30;
    //[_klineView removeFromSuperview];
//    [_klineView clear];
//    _klineView.delegate = nil;
//    _klineView = nil;
//    _klineModel.stage.width = _klineBoxWidth;
//    _klineView = [[FMStockChartManagerView manager]
//                  createWithFrame:CGRectMake(10, 15, _klineBoxWidth, _klineBoxHeight)
//                  Model:_klineModel SuperView:_klineBoxSuperView];
//    _klineView.delegate = self;
    [self createKlineChartWithStockChartType:_stockCharType fuquanType:_fuquanType drawDatas:nil];
    self.navigation.line.hidden = NO;
    _indexView.hidden = YES;
    _tableView.scrollEnabled = YES;
    self.navigationItem.hidesBackButton = NO;
    _backButton.hidden = YES;
    [_tableView reloadData];
    
    [_chartTabBar reloadViews];
    _orderButton.hidden = NO;
    [self.view bringSubviewToFront:_orderButton];
    [_chartTabBar updateHighlightsTitleWithIndex:_stockCharType];
    _chartTabBar.moreViews.hidden = YES;
    _hKLineBt.hidden = NO;
}

//  恢复原始竖屏并禁止旋转
-(void)resetDefaultScreenStatus{
    [self readyScreenSwitch];
    [FMAppDelegate transtoRotation:UIDeviceOrientationPortrait];
}

#pragma mark -
#pragma mark UI Create

-(void)setNavigationTitle{
    NSString *t = [NSString stringWithFormat:@"%@",_stockName];
    UILabel *titleLb = [UILabel createWithTitle:t Frame:CGRectMake(0, 0, 100, kNavigationHeight)];
//    titleLb.font = kFontBold(14);
//    titleLb.numberOfLines = 2;
    titleLb.textColor = [UIColor whiteColor];
    titleLb.textAlignment = NSTextAlignmentCenter;
    // 时间
    NSString *time = [_stockCode substringFromIndex:2];
    if (!time || [time isEqual:[NSNull null]]) {
        time = @"";
    }
//    if ([FMUserDefault marketIsClose]) {
//        time = [NSString stringWithFormat:@"已收盘 %@",time];
//    }
    
    if (time.length>0) {
        time = [NSString stringWithFormat:@"\n%@",time];
    }
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",t,time]];
    [str addAttribute:NSFontAttributeName value:kFontBold(18) range:NSMakeRange(0, t.length)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, t.length)];
    [str addAttribute:NSFontAttributeName value:kFont(12) range:NSMakeRange(t.length, time.length)];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(t.length, time.length)];
    titleLb.attributedText = str;
    
    self.navigationItem.titleView = titleLb;
}

-(void)createViews{
    
    //[self setTitle:_stockName IsBack:YES ReturnType:1];
    // self.navigationItem.title = [NSString stringWithFormat:@"%@(%@)",_stockName,[_stockCode substringFromIndex:2]];
    [self setNavigationTitle];
    if (!_tableView) {
        CGRect frame = CGRectMake(0, 0, UIScreenWidth,
                                  UIScreenHeight-kTabBarNavigationHeight);
        _tableView = [[FMTableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
        
    }
    [self createTableHeaderView];
    [self createNavBarButton];
    //[self readyScreenSwitch];
    [self addMJHeader];
    [self createOrderButton];
    [self createStockInfoViews];
}

//  导航按钮
-(void)createNavBarButton{
    
    UIBarButtonItem *refreshBt = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                  target:self
                                  action:@selector(clickRefreshButtonHandle:)];
    
    UIBarButtonItem *addBt = [[UIBarButtonItem alloc]
                              initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                              target:self
                              action:@selector(clickAddButtonHandle:)];
    
    self.navigationItem.rightBarButtonItems = @[refreshBt,addBt];
    [self createDeleteMyStocksButton];
}

-(void)createDeleteMyStocksButton{
    // 查询是否存在自选
    NSString *where = [NSString stringWithFormat:@"code='%@'",_stockCode];
    if ([[FMUserDefault getUserId]floatValue]>0) {
        where = [NSString stringWithFormat:@"code='%@' and userId='%@'",_stockCode,[FMUserDefault getUserId]];
    }
    NSInteger isExit = [db getCount:[FMSelfStocksModel class] where:where];
    if (isExit>0) {
        UIBarButtonItem *bt = (UIBarButtonItem*)self.navigationItem.rightBarButtonItems.lastObject;
        UIButton *deleteBt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, kNavigationHeight)];
        [deleteBt setTitle:@"删自选" forState:UIControlStateNormal];
        [deleteBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        deleteBt.titleLabel.font = kDefaultFont;
        [deleteBt addTarget:self action:@selector(clickDeleteButtonHandle:) forControlEvents:UIControlEventTouchUpInside];
        bt.customView = deleteBt;
        deleteBt = nil;
    }
}

//  当横屏出现时创建返回按钮
-(void)createBackButtonWhenHorizontal{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = CGRectMake(0, 0, 40, 32);
        UIImage *smallBackBg = ThemeImage(@"global/icon_close_normal");
        smallBackBg = [UIImage imageWithTintColor:[UIColor whiteColor] blendMode:kCGBlendModeDestinationIn WithImageObject:smallBackBg];
        [_backButton setImage:smallBackBg forState:UIControlStateNormal];
        [_backButton addTarget:self
                        action:@selector(resetDefaultScreenStatus)
              forControlEvents:UIControlEventTouchUpInside];
        [self.navigation.navigationBar addSubview:_backButton];
    }
    _backButton.hidden = NO;
}

-(void)createTableHeaderView{
    if (!_topViews) {
        _topViews = [[FMSelfStockTopViews alloc]
                     initWithFrame:CGRectMake(0, 0, UIScreenWidth, kFMSelfStockTopViewsHeight)];
        _tableView.tableHeaderView = _topViews;
        _topViews.time.hidden = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showStockInfoViews)];
        [_topViews addGestureRecognizer:tap];
    }
    FMSelfStocksModel *m = [[FMSelfStocksModel alloc] init];
    m.name = _stockName;
    m.code = _stockCode;
    m.price = _price;
    m.closePrice = _closePrice;
    m.highPrice = _highPrice;
    m.lowPrice = _lowPrice;
    m.openPrice = _openPrice;
    [_topViews updateViewsWithModel:m infoModel:_stockInfoViews.model];
    [self updateHeaderViewsBackground];
}
//  根据大盘涨跌改变头部视图背景
-(void)updateHeaderViewsBackground{
    FMNavigationController *navigation = (FMNavigationController*)self.navigationController;
    UIColor *color = FMNavColor;
    [navigation changeLineBackgroundColor:color];
}

//  股票信息视图
-(void)createStockInfoViews{
    if (!_stockInfoViews) {
        _stockInfoViews = [[FMStockInfoViews alloc]
                           initWithFrame:CGRectMake(0, 0, UIScreenWidth, UIScreenHeight)];
        
        [[UIApplication sharedApplication].keyWindow addSubview:_stockInfoViews];
        _stockInfoViews.hidden = YES;
    }
}

//  股票基本面
-(void)createStockCompanyWithCell:(UITableViewCell*)cell{
    if (!_stockCompany) {
        _stockCompany = [[FMStockCompany alloc]
                         initWithFrame:CGRectMake(0, 0, UIScreenWidth, kFMStockCompanyHeight)];
        [cell.contentView addSubview:_stockCompany];
        
    }
    if (_sectionTwoType==1) {
        _stockCompany.hidden = NO;
    }else{
        _stockCompany.hidden = YES;
    }
}

//  k线图切换工具栏
-(void)createChartTabBarWithCell:(UITableViewCell*)cell{
    if (!_chartTabBar) {
        _chartTabBar = [[FMKLineChartTabBar alloc]
                        initWithFrame:CGRectMake(0, 0, UIScreenWidth, kFMKLineChartTabBarHeight) Titles:nil superView:_tableView];
        _chartTabBar.delegate = self;
        _chartTabBar.backgroundColor = [UIColor whiteColor];
        [cell.contentView addSubview:_chartTabBar];
    }
}

//  创建k线图
-(void)createKLineChartViewsWithCell:(UITableViewCell*)cell{
    _klineBoxSuperView = cell.contentView;
    _klineModel = [[FMStockModel alloc] init];
    _klineModel.stockCode = _stockCode;
    _klineModel.stockType = _type;
    //_klineModel.klineWidth = 2;
    _klineModel.yestodayClosePrice = [_closePrice floatValue];
    _klineModel.stage.font = kFontNumber(10);
    //    _klineModel.stockIndexType = FMStockIndexType_BS;
    //    _klineModel.fuquanType = FMMarketFuquan_Before;
    _klineModel.stockIndexBottomType = [[FMUserDefault getSeting:kUserDefault_StocksKIndexType] intValue];
    _klineView = [[FMStockChartManagerView manager]
                  createWithFrame:CGRectMake(10, 15, _klineBoxWidth, _klineBoxHeight)
                  Model:_klineModel SuperView:_klineBoxSuperView];
    _klineView.delegate = self;
    [cell.contentView addSubview:_klineView];
    
    [self createHKlineBtWithSuperView:cell.contentView];
}
// 创建k线横屏切换按钮
-(void)createHKlineBtWithSuperView:(UIView*)superView{
    if (_hKLineBt.superview==nil) {
        [_hKLineBt removeFromSuperview];
        _hKLineBt = nil;
    }
    if (!_hKLineBt) {
        _hKLineBt = [[UIButton alloc] initWithFrame:CGRectMake(_klineBoxWidth-kFMFiveStallsViewDefaultWidth-30, _klineBoxHeight-30, 30, 30)];
//        _hKLineBt.backgroundColor = FMRedColor;
        [_hKLineBt setBackgroundImage:ThemeImage(@"global/ic_to_screen") forState:UIControlStateNormal];
        [superView addSubview:_hKLineBt];
        [_hKLineBt addTarget:self action:@selector(clickHKlineBtAction) forControlEvents:UIControlEventTouchUpInside];
    }
    if ([_type isEqualToString:@"1"] || _stockCharType!=FMStockType_MinuteChart) {
        _hKLineBt.frame = CGRectMake(_klineBoxWidth-30, _klineBoxHeight-30, 30, 30);
    }else{
        _hKLineBt.frame = CGRectMake(_klineBoxWidth-kFMFiveStallsViewDefaultWidth-30, _klineBoxHeight-30, 30, 30);
    }
    [superView bringSubviewToFront:_hKLineBt];
}

//  创建资金饼状图
-(void)createKLineCashFlowViewsWithCell:(UITableViewCell*)cell{
    if (!_cashFlowViews) {
        _cashFlowViews = [[FMKLineCashFlowViews alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, kFMKLineCashFlow_Height) withDatas:nil];
        [cell.contentView addSubview:_cashFlowViews];
    }
    if (_sectionTwoType==0 && ![_type isEqualToString:@"1"]) {
        _cashFlowViews.hidden = NO;
    }else{
        _cashFlowViews.hidden = YES;
    }
}

//  实时资金流向
-(void)createRecentlyMainForceWithCell:(UITableViewCell*)cell{
    if (!_recentlyMainForce) {
        
        _recentlyMainForce = [[FMKLineRecentlyMainForce alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, kFMKLineRecentlyMainForce_Height) datas:nil];
        [cell.contentView addSubview:_recentlyMainForce];
        //_recentlyMainForce.hidden = YES;
    }
    if (_sectionTwoType==0) {
        _recentlyMainForce.hidden = NO;
    }else{
        _recentlyMainForce.hidden = YES;
    }
}

//  利润表
-(void)createProfitViewWithCell:(UITableViewCell*)cell{
    if (!_profitView) {
        
        _profitView = [[FMStockProfits alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, kFMKLineRecentlyMainForce_Height) datas:nil];
        [cell.contentView addSubview:_profitView];
        //_recentlyMainForce.hidden = YES;
    }
    if (_sectionTwoType==1) {
        _profitView.hidden = NO;
    }else{
        _profitView.hidden = YES;
    }
}

//  财务
-(void)createFinanceViewWithCell:(UITableViewCell*)cell{
    if (!_stockFinance) {
        
        _stockFinance = [[FMStockFinance alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, kFMKLineRecentlyMainForce_Height)];
        [cell.contentView addSubview:_stockFinance];
        //_recentlyMainForce.hidden = YES;
    }
    if (_sectionTwoType==2) {
        _stockFinance.hidden = NO;
    }else{
        _stockFinance.hidden = YES;
    }
}

//  大盘指数资金流向
-(void)createStockCapitalViewWithCell:(UITableViewCell*)cell{
    if (!_stockCapital) {
        
        _stockCapital = [[FMStockCapital alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, kFMStockCapitalHeight)];
        [cell.contentView addSubview:_stockCapital];
        //_recentlyMainForce.hidden = YES;
        __weak typeof(self) weakSelf = self;
        _stockCapital.whenFinishedLoadDatasBlock = ^{
            [weakSelf tableViewReloadData];
        };
    }
    if (_sectionTwoType==0 && [_type isEqualToString:@"1"]) {
        _stockCapital.hidden = NO;
    }else{
        _stockCapital.hidden = YES;
    }
}

//  横屏指标视图
-(void)createKlineIndexViewWithCell:(UITableViewCell*)cell{
    if (!_indexView) {
        _indexView = [[FMKLineIndexView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-kFMKLineIndexViewWidth, 0, kFMKLineIndexViewWidth, _klineBoxHeight) type:_type];
        [cell.contentView addSubview:_indexView];
        _indexView.hidden = YES;
        // 点击指标
        __weak typeof(self) weakSelf = self;
        _indexView.clickKLineHorizontalNavButtonBlock = ^(NSString* code,int index){
            weakSelf.currentIndex = index;
            [weakSelf changeKLineViewWithIndexCode:code];
        };
    }
}

-(void)createSignalWithModel:(FMStockInfoModel*)model{
    //    if ([[FMUserDefault getUserId]floatValue]<=0) {
    //        return;
    //    }
    //    if (!_signal) {
    //        _signal = [UILabel createWithTitle:@"B" Frame:CGRectMake(UIScreenWidth/4+30, 2, 14, 14)];
    //        _signal.font = kFontNumber(12);
    //        _signal.layer.cornerRadius = _signal.frame.size.width/2;
    //        _signal.textAlignment = NSTextAlignmentCenter;
    //        _signal.layer.masksToBounds = YES;
    //        _signal.textColor = [UIColor whiteColor];
    //        _signal.hidden = YES;
    //        [_chartTabBar addSubview:_signal];
    //    }
    //    _signal.frame = CGRectMake(UIScreenWidth/4+30, 2, _signal.frame.size.width, _signal.frame.size.height);
    //    if (![model.signal isEqualToString:@""]) {
    //        if ([model.signal floatValue]==0) {
    //            _signal.hidden = NO;
    //            _signal.text = @"B";
    //            _signal.backgroundColor = FMRedColor;
    //        }
    //        if ([model.signal floatValue]==1) {
    //            _signal.hidden = NO;
    //            _signal.text = @"S";
    //            _signal.backgroundColor = FMGreenColor;
    //        }
    //    }else{
    //        _signal.hidden = YES;
    //    }
}

/**
 *  非收费用户提速
 */
-(void)createVipTipUserViews{
    UILabel *l = nil;
    float h = 25;
    float w = 0;
    float x = 0;
    float y = 0;
    
    if (_vipTipView==nil) {
        l = [UILabel createWithTitle:@"VIP用户才能看到实时的买卖点提示" Frame:CGRectMake(x,y,w,h)];
        l.font = kFont(9);
        l.backgroundColor = FMRedColor;
        l.alpha = 0.8;
        l.textColor = [UIColor whiteColor];
        l.layer.borderColor = FMRedColor.CGColor;
        l.layer.borderWidth = 0.5;
        l.layer.cornerRadius = 2;
        l.layer.masksToBounds = YES;
        l.textAlignment = NSTextAlignmentCenter;
        [l sizeToFit];
        
        [_klineBoxSuperView addSubview:l];
        _vipTipView = l;
        l = nil;
    }
    [_vipTipView sizeToFit];
    y = 15;
    w = _vipTipView.frame.size.width + 20;
    x = _klineBoxSuperView.frame.size.width-w-10;
    if (!_indexView.hidden) {
        x = x - _indexView.frame.size.width;
    }
    _vipTipView.frame = CGRectMake(x, y, w, h);
    _vipTipView.alpha = 0;
    _vipTipView.hidden = NO;
    [_klineBoxSuperView bringSubviewToFront:_vipTipView];
    WEAKSELF
    [UIView animateWithDuration:0.5 animations:^{
        __weakSelf.vipTipView.alpha = 1;
    } completion:^(BOOL finished){
        [__weakSelf.klineBoxSuperView bringSubviewToFront:_vipTipView];
    }];
}

// 我要下单按钮
-(void)createOrderButton{
    if (!_orderButton) {
        _orderButton = [UIButton createWithTitle:@"我要下单" Frame:CGRectMake(0,UIScreenHeight-kTabBarNavigationHeight-kNavigationHeight,UIScreenWidth,kNavigationHeight)];
        _orderButton.backgroundColor = FMGreyColor;
        _orderButton.titleLabel.font = kFontBold(16);
        [_orderButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        //        [self.view addSubview:_orderButton];
    }
}

#pragma mark -
#pragma mark UI Action
//  添加自选
-(void)clickAddButtonHandle:(UIBarButtonItem*)bt{
    
    //    FMStockShiJiaViewController *shijia = [[FMStockShiJiaViewController alloc] initWithStockCode:_stockCode StockName:_stockName Price:_price ClosePrice:_closePrice Type:_type];
    //    [self.navigationController pushViewController:shijia animated:YES];
    
    NSInteger isExit = [db getCount:[FMSelfStocksModel class] where:[NSString stringWithFormat:@"code='%@'",_stockCode]];
    if (isExit<=0) {
        FMSelfStocksModel *selfm = [[FMSelfStocksModel alloc] init];
        selfm.name = _stockName;
        selfm.code = _stockCode;
        selfm.type = [_stockCode substringToIndex:1];
        selfm.isStop = 0;
        selfm.signal = @"-1";
        selfm.userId = [FMUserDefault getUserId];
        selfm.orderValue = [NSString stringWithFormat:@"%d",(int)[db getSum:selfm Filed:@"orderValue" where:nil]+1];
        WEAKSELF
        [db insert:selfm  FinishBlock:^(bool issuccess){
            [__weakSelf createDeleteMyStocksButton];
            [[FMBackgroundRun instance] uploadAddSingleOneSelfStockWithCode:_stockCode block:nil];
        }];
    }
}
//  删除自选
-(void)clickDeleteButtonHandle:(UIButton*)bt{
    NSString *where = [NSString stringWithFormat:@"code='%@'",_stockCode];
    if ([[FMUserDefault getUserId]floatValue]>0) {
        where = [NSString stringWithFormat:@"code='%@' and userId='%@'",_stockCode,[FMUserDefault getUserId]];
    }
    NSInteger isExit = [db getCount:[FMSelfStocksModel class] where:where];
    if (isExit>0) {
        [db delete:[FMSelfStocksModel class] Where:where];
        UIBarButtonItem *bt = [self.navigationItem.rightBarButtonItems lastObject];
        bt.customView = nil;
        bt = nil;
        [[FMBackgroundRun instance] deleteSingleOneSelfStockWithCode:_stockCode block:nil];
    }
}
//  点击刷新按钮
-(void)clickRefreshButtonHandle:(UIBarButtonItem*)bt{
    UIActivityIndicatorView *jh = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    bt.customView = jh;
    [jh startAnimating];
    jh = nil;
    [self getHttpStockInfoFrom:YES];
    [self getHttpDapanStocksNewData:YES];
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:10];
}
-(void)stopRefresh{
    UIBarButtonItem *bt = [self.navigationItem.rightBarButtonItems firstObject];
    if (bt.customView) {
        UIActivityIndicatorView *jh = (UIActivityIndicatorView*)bt.customView;
        [jh stopAnimating];
        jh = nil;
        bt.customView = nil;
        self.navigationItem.rightBarButtonItems = nil;
        [self createNavBarButton];
    }
    
    bt = nil;
    [_tableView.header endRefreshing];
}

-(void)changeKLineViewWithIndexCode:(NSString*)code{
    if (_klineModel && _klineView) {
        if ([code isEqualToString:@"SMA"]) {
            _klineModel.stockIndexType = FMStockIndexType_SMA;
        }
        if ([code isEqualToString:@"EMA"]) {
            _klineModel.stockIndexType = FMStockIndexType_EMA;
        }
        if ([code isEqualToString:@"BOLL"]) {
            _klineModel.stockIndexType = FMStockIndexType_BOLL;
        }
        
        if ([code isEqualToString:@"VOL"]) {
            _klineModel.stockIndexBottomType = FMStockIndexType_VOL;
        }
        if ([code isEqualToString:@"MACD"]) {
            _klineModel.stockIndexBottomType = FMStockIndexType_MACD;
        }
        if ([code isEqualToString:@"KDJ"]) {
            _klineModel.stockIndexBottomType = FMStockIndexType_KDJ;
        }
        if ([code isEqualToString:@"RSI"]) {
            _klineModel.stockIndexBottomType = FMStockIndexType_RSI;
        }
        if ([code isEqualToString:@"OBV"]) {
            _klineModel.stockIndexBottomType = FMStockIndexType_OBV;
        }
        if ([code isEqualToString:@"DMI"]) {
            _klineModel.stockIndexBottomType = FMStockIndexType_DMI;
        }
        if ([code isEqualToString:@"SAR"]) {
            _klineModel.stockIndexType = FMStockIndexType_SAR;
        }
        
        _stockIndexType = _klineModel.stockIndexType;
        
        [FMUserDefault setSeting:kUserDefault_StocksKIndexType Value:[NSString stringWithFormat:@"%d",_klineModel.stockIndexBottomType]];
        [_klineView updateWithModel:_klineModel];
        
        if ([code isEqualToString:@"前复权"]) {
            _stockIndexType = FMStockIndexType_SMA;
            [self createKlineChartWithStockChartType:_stockCharType fuquanType:FMMarketFuquan_Before drawDatas:nil];
        }
        if ([code isEqualToString:@"默认"]) {
            _stockIndexType = FMStockIndexType_SMA;
            [self createKlineChartWithStockChartType:_stockCharType fuquanType:FMMarketFuquan_None drawDatas:nil];
        }
        if ([code isEqualToString:@"后复权"]) {
            _stockIndexType = FMStockIndexType_SMA;
            [self createKlineChartWithStockChartType:_stockCharType fuquanType:FMMarketFuquan_Back drawDatas:nil];
        }
        
        
        for (int i=0; i<_indexList.count; i++) {
            NSDictionary *item = _indexList[i];
            if (item[@"code"] == code) {
                _currentIndex = i;
                break;
            }
        }
        
    }
    
}

// 点击头部价格区域显示更多价格信息
-(void)showStockInfoViews{
    [self createStockInfoViews];
    if(_stockInfoViews.hidden){
        [_stockInfoViews show];
    }else{
        [_stockInfoViews hide];
    }
    
}

#pragma mark -
#pragma mark FMKLineStockChartTabBarDelegate
-(void)FMKLineChartTabBarClickButton:(FMStockChartType)stockChartType{
    _vipTipView.hidden = YES;
    [self createKlineChartWithStockChartType:stockChartType fuquanType:_fuquanType drawDatas:nil];
    
}

/**
 *  初始化K线图表
 *
 *  @param stockChartType 图表类型 分时 五日 日K 周K 月K
 *  @param fuquanType     复权类型
 */
-(void)createKlineChartWithStockChartType:(FMStockChartType)stockChartType fuquanType:(FMMarketFuquan_Type)fuquanType drawDatas:(NSMutableDictionary*)drawDatas{
    _vipTipView.hidden = YES;
    _stockCharType = stockChartType;
    _fuquanType = fuquanType;
    //[_klineView removeFromSuperview];
    [_klineView clear];
    _klineView.delegate = nil;
    _klineModel = nil;
    _klineView = nil;
    _klineModel = [[FMStockModel alloc] init];
    _klineModel.type = _stockCharType; // 图表类型
    _klineModel.stockCode = _stockCode;
    _klineModel.yestodayClosePrice = [_closePrice floatValue];
    _klineModel.stockType = _type;
    _klineModel.fuquanType = _fuquanType; // 复权类型
    _klineModel.drawDatas = drawDatas;
    //_klineModel.klineWidth = 2;
    _klineModel.realtimeData = _lastDate;
    _klineModel.stockIndexType = _stockIndexType;  // 指标类型
    
    _klineModel.stockIndexBottomType = [[FMUserDefault getSeting:kUserDefault_StocksKIndexType] intValue];;
    if ([[FMUserDefault getUserId] floatValue]>0) {
        _klineModel.isOpenSignal = YES;
    }else{
        _klineModel.isOpenSignal = NO;
    }
    if (stockChartType==FMStockType_MinuteChart) {
        _klineModel.isOpenSignal = NO;
    }
    if (drawDatas) {
        //_klineModel.isOpenSignal = NO;
    }
    _klineModel.stage.font = kFontNumber(10);
    _klineModel.stage.tipFont = kFontNumber(8);
    _klineBoxWidth = self.view.frame.size.width - 20;
    if ((_stockCharType!=FMStockType_MinuteChart && _stockCharType!=FMStockType_FiveDaysChart) && ([FMAppDelegate deviceOrientation]==UIDeviceOrientationLandscapeLeft || [FMAppDelegate deviceOrientation]==UIDeviceOrientationLandscapeRight)) {
        _klineBoxWidth = self.view.frame.size.width - 20 - kFMKLineIndexViewWidth;
    }else{
        _indexView.hidden = YES;
    }
    _klineView = [[FMStockChartManagerView manager]
                  createWithFrame:CGRectMake(10, 15, _klineBoxWidth, _klineBoxHeight)
                  Model:_klineModel SuperView:_klineBoxSuperView];
    _klineView.delegate = self;
    
     [self createHKlineBtWithSuperView:_klineBoxSuperView];
  
}

#pragma mark -
#pragma mark FMBaseViewDelegate
//  点击股票线图表
-(void)FMBaseViewSingleClickAction:(FMBaseView *)baseView{
//    if (!_chartTabBar.moreViews.hidden) {
//        _chartTabBar.moreViews.hidden = YES;
////        return;
//    }
//    [self readyScreenSwitch];
//    NSLog(@"%d", (int)FMAppDelegate.deviceOrientation);
//    if (FMAppDelegate.deviceOrientation!=UIDeviceOrientationPortrait &&
//        FMAppDelegate.deviceOrientation!=UIDeviceOrientationUnknown) {
//        [FMAppDelegate transtoRotation:UIDeviceOrientationPortrait];
//    }else{
//        [FMAppDelegate transtoRotation:UIDeviceOrientationLandscapeLeft];
//    }
}

-(void)FMBaseViewSingleClickBottomViewAction:(FMBaseView *)baseView{
    if (_stockCharType==FMStockType_MinuteChart || _stockCharType==FMStockType_FiveDaysChart) {
        return;
    }
    // 点击幅图
    _currentIndex ++;
    if (_currentIndex>_indexList.count-1) {
        _currentIndex = 7;
        if ([_type isEqualToString:@"1"]) {
            _currentIndex = 5;
        }
    }
    if (_currentIndex<=5) {
        _currentIndex = 5;
    }
    if ([_type isEqualToString:@"0"]) {
        if (_currentIndex<=7) {
            _currentIndex = 7;
        }
    }
    if (_currentIndex<_indexList.count) {
        NSString *code = _indexList[_currentIndex][@"code"];
        [self changeKLineViewWithIndexCode:code];
    }
}

-(void)clickHKlineBtAction{
    if (!_chartTabBar.moreViews.hidden) {
        _chartTabBar.moreViews.hidden = YES;
        //        return;
    }
    [self readyScreenSwitch];
    NSLog(@"%d", (int)FMAppDelegate.deviceOrientation);
    if (FMAppDelegate.deviceOrientation!=UIDeviceOrientationPortrait &&
        FMAppDelegate.deviceOrientation!=UIDeviceOrientationUnknown) {
        [FMAppDelegate transtoRotation:UIDeviceOrientationPortrait];
    }else{
        [FMAppDelegate transtoRotation:UIDeviceOrientationLandscapeLeft];
    }
}

-(void)FMBaseViewDrawFinished:(FMBaseView *)baseView{
    if ([FMAppDelegate deviceOrientation]==UIDeviceOrientationLandscapeLeft || [FMAppDelegate deviceOrientation]==UIDeviceOrientationLandscapeRight) {
        if (_stockCharType!=FMStockType_MinuteChart && _stockCharType!=FMStockType_FiveDaysChart) {
            // 指标图
            if ([[[UIDevice currentDevice]systemVersion]floatValue]<8.0) {
                [self createKlineIndexViewWithCell:(UITableViewCell*)_klineView.superview.superview.superview];
            }else{
                [self createKlineIndexViewWithCell:(UITableViewCell*)_klineView.superview.superview];
            }
            if (_indexView.hidden) {
                _indexView.frame = CGRectMake(self.view.frame.size.width, 15, kFMKLineIndexViewWidth, _klineBoxHeight);
            }
            _indexView.hidden = NO;
            WEAKSELF
            [UIView animateWithDuration:0.3 animations:^{
                __weakSelf.indexView.frame = CGRectMake(self.view.frame.size.width-kFMKLineIndexViewWidth, 15, kFMKLineIndexViewWidth, __weakSelf.klineBoxHeight);
            } completion:^(BOOL finished){
                //[_chartTabBar updateHighlightsTitleWithIndex:_circleType];
            }];
        }else{
            _indexView.hidden = YES;
        }
        
    }
    [_chartTabBar updateHighlightsTitleWithIndex:_stockCharType];
    
    
    
    // 发送数据 计算信号
    //    if (_klineModel.type==FMStockType_DaysChart) {
    //        [[FMPostSignalToServer shareManager] postStartWithPrices:_klineModel.prices];
    //    }
    
}

// 按压手指移动
-(void)FMBaseViewMovingFinger:(FMBaseView *)baseView model:(FMStockDaysModel *)model isHide:(BOOL)isHide{
    NSLog(@"%d",isHide);
    float y = 0;
    if ([FMAppDelegate deviceOrientation]==UIDeviceOrientationLandscapeLeft || [FMAppDelegate deviceOrientation]==UIDeviceOrientationLandscapeRight) {
        y = 0;
    }else{
        y = kFMSelfStockTopViewsHeight;
    }
    
    if (!_klineTopTipView) {
        _klineTopTipView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, kFMKLineChartTabBarHeight)];
        _klineTopTipView.backgroundColor = [UIColor whiteColor];
        [_tableView addSubview:_klineTopTipView];
    }
    
    _klineTopTipView.frame = CGRectMake(0, y, UIScreenWidth, kFMKLineChartTabBarHeight);
    
    _klineTopTipView.hidden = isHide;
    [_tableView bringSubviewToFront:_klineTopTipView];
    
    for (UIView *item in _klineTopTipView.subviews) {
        [item removeFromSuperview];
    }
    
    if (isHide) {
        // 头部一起跟着显示动态价格
        FMSelfStocksModel *m = [[FMSelfStocksModel alloc] init];
        m.name = _stockName;
        m.code = _stockCode;
        m.price = _price;
        m.closePrice = _closePrice;
        m.highPrice = _highPrice;
        m.lowPrice = _lowPrice;
        m.openPrice = _openPrice;
        [_topViews updateViewsWithModel:m infoModel:_stockInfoViews.model];
    }
    
    [self updateHeaderViewsBackground];
    
    if (!_klineModel.isPressing || isHide) {
        return;
    }
    
    [fn drawLineWithSuperView:_klineTopTipView Color:FMBottomLineColor Location:1];
    //    [fn drawLineWithSuperView:_klineTopTipView Color:FMBottomLineColor Location:0];
    
    FMStockModel *_model = _klineModel;
    FMStockDaysModel *m = model;
    int fontSize = 12;
    if ([FMAppDelegate deviceOrientation]==UIDeviceOrientationLandscapeLeft || [FMAppDelegate deviceOrientation]==UIDeviceOrientationLandscapeRight) {
        fontSize = 14;
    }
    if (_model.type==FMStockType_MinuteChart) {
        // 13:20 价格12:34 涨幅+0.4% 成交2.4万手 均价12:1
        FMStockMinuteModel *min = (FMStockMinuteModel*)m;
        NSString *price = [NSString stringWithFormat:@"%.2f",[min.price floatValue]];
        NSString *changeRate = [NSString stringWithFormat:@"%.2f%%",[min.changeRate floatValue]];
        NSString *volumn = [NSString stringWithFormat:@"%.f手",[min.volumn floatValue]/100];
        NSString *average = [NSString stringWithFormat:@"%.2f",[min.averagePrice floatValue]];
        UIColor *color = _model.klineUpColor;
        if ([changeRate floatValue]<0) {
            color = _model.klineDownColor;
        }
        CGPoint point = CGPointMake(3, 9);
        
        CGSize size = [self createLableWithSize:fontSize
                                          Color:_model.stage.fontColor
                                          Point:point
                                           Text:[self datetime:min.datetime]
                                      SuperView:_klineTopTipView
                                            Tag:-1];
        point = CGPointMake(size.width+10, point.y);
        size = [self createLableWithSize:fontSize
                                   Color:_model.stage.fontColor
                                   Point:point
                                    Text:@"价格"
                               SuperView:_klineTopTipView
                                     Tag:-1];
        
        point = CGPointMake(size.width, point.y);
        size = [self createLableWithSize:fontSize
                                   Color:color
                                   Point:point
                                    Text:price
                               SuperView:_klineTopTipView
                                     Tag:-1];
        point = CGPointMake(size.width+10, point.y);
        size = [self createLableWithSize:fontSize
                                   Color:_model.stage.fontColor
                                   Point:point
                                    Text:@"涨幅"
                               SuperView:_klineTopTipView
                                     Tag:-1];
        point = CGPointMake(size.width, point.y);
        size = [self createLableWithSize:fontSize
                                   Color:color
                                   Point:point
                                    Text:changeRate
                               SuperView:_klineTopTipView
                                     Tag:-1];
        point = CGPointMake(size.width+10, point.y);
        size = [self createLableWithSize:fontSize
                                   Color:_model.stage.fontColor
                                   Point:point
                                    Text:@"成交"
                               SuperView:_klineTopTipView
                                     Tag:-1];
        point = CGPointMake(size.width, point.y);
        size = [self createLableWithSize:fontSize
                                   Color:_model.stage.fontColor
                                   Point:point
                                    Text:volumn
                               SuperView:_klineTopTipView
                                     Tag:-1];
        color = _model.klineUpColor;
        if ([average floatValue]<0) {
            color = _model.klineDownColor;
        }
        point = CGPointMake(size.width+10, point.y);
        size = [self createLableWithSize:fontSize
                                   Color:_model.stage.fontColor
                                   Point:point
                                    Text:@"均价"
                               SuperView:_klineTopTipView
                                     Tag:-1];
        point = CGPointMake(size.width, point.y);
        size = [self createLableWithSize:fontSize
                                   Color:color
                                   Point:point
                                    Text:average
                               SuperView:_klineTopTipView
                                     Tag:-1];
        
        // 头部一起跟着显示动态价格
        FMSelfStocksModel *m = [[FMSelfStocksModel alloc] init];
        m.name = _stockName;
        m.code = _stockCode;
        m.price = min.price;
        m.closePrice = _closePrice;
        m.highPrice = _highPrice;
        m.lowPrice = _lowPrice;
        m.openPrice = _openPrice;
        [_topViews updateViewsWithModel:m infoModel:_stockInfoViews.model];
        
        
    }
    if (_model.type!=FMStockType_MinuteChart && _model.type!=FMStockType_FiveDaysChart) {
        // 10-20 开12:34 高15:32 低11.43 收12:1 涨幅+3.9%
        FMStockDaysModel *min = (FMStockDaysModel*)m;
        NSString *openPrice = [NSString stringWithFormat:@"%.2f",[min.openPrice floatValue]];
        NSString *heightPrice = [NSString stringWithFormat:@"%.2f",[min.heightPrice floatValue]];
        NSString *lowPrice = [NSString stringWithFormat:@"%.2f",[min.lowPrice floatValue]];
        NSString *closePrice = [NSString stringWithFormat:@"%.2f",[min.closePrice floatValue]];
        NSString *changeRate = [NSString stringWithFormat:@"%.2f%%",([min.closePrice floatValue]-[min.yestodayClosePrice floatValue]) / [min.yestodayClosePrice floatValue]*100];
        float yestodayClose = [min.yestodayClosePrice floatValue];
        UIColor *color = _model.klineUpColor;
        if ([openPrice floatValue]<yestodayClose) {
            color = _model.klineDownColor;
        }
        CGPoint point = CGPointMake(3, 9);
        CGSize size = [self createLableWithSize:fontSize
                                          Color:_model.stage.fontColor
                                          Point:point
                                           Text:[self datetime:min.datetime]
                                      SuperView:_klineTopTipView
                                            Tag:-1];
        point = CGPointMake(size.width+10, point.y);
        size = [self createLableWithSize:fontSize
                                   Color:_model.stage.fontColor
                                   Point:point
                                    Text:@"开"
                               SuperView:_klineTopTipView
                                     Tag:-1];
        
        point = CGPointMake(size.width, point.y);
        size = [self createLableWithSize:fontSize
                                   Color:color
                                   Point:point
                                    Text:openPrice
                               SuperView:_klineTopTipView
                                     Tag:-1];
        color = _model.klineUpColor;
        if ([heightPrice floatValue]<yestodayClose) {
            color = _model.klineDownColor;
        }
        point = CGPointMake(size.width+10, point.y);
        size = [self createLableWithSize:fontSize
                                   Color:_model.stage.fontColor
                                   Point:point
                                    Text:@"高"
                               SuperView:_klineTopTipView
                                     Tag:-1];
        point = CGPointMake(size.width, point.y);
        size = [self createLableWithSize:fontSize
                                   Color:color
                                   Point:point
                                    Text:heightPrice
                               SuperView:_klineTopTipView
                                     Tag:-1];
        color = _model.klineUpColor;
        if ([lowPrice floatValue]<yestodayClose) {
            color = _model.klineDownColor;
        }
        point = CGPointMake(size.width+10, point.y);
        size = [self createLableWithSize:fontSize
                                   Color:_model.stage.fontColor
                                   Point:point
                                    Text:@"低"
                               SuperView:_klineTopTipView
                                     Tag:-1];
        point = CGPointMake(size.width, point.y);
        size = [self createLableWithSize:fontSize
                                   Color:color
                                   Point:point
                                    Text:lowPrice
                               SuperView:_klineTopTipView
                                     Tag:-1];
        color = _model.klineUpColor;
        if ([closePrice floatValue]<yestodayClose) {
            color = _model.klineDownColor;
        }
        point = CGPointMake(size.width+10, point.y);
        size = [self createLableWithSize:fontSize
                                   Color:_model.stage.fontColor
                                   Point:point
                                    Text:@"收"
                               SuperView:_klineTopTipView
                                     Tag:-1];
        point = CGPointMake(size.width, point.y);
        size = [self createLableWithSize:fontSize
                                   Color:color
                                   Point:point
                                    Text:closePrice
                               SuperView:_klineTopTipView
                                     Tag:-1];
        color = _model.klineUpColor;
        if ([changeRate floatValue]<0) {
            color = _model.klineDownColor;
        }
        point = CGPointMake(size.width+10, point.y);
        size = [self createLableWithSize:fontSize
                                   Color:_model.stage.fontColor
                                   Point:point
                                    Text:@"涨幅"
                               SuperView:_klineTopTipView
                                     Tag:-1];
        point = CGPointMake(size.width, point.y);
        size = [self createLableWithSize:fontSize
                                   Color:color
                                   Point:point
                                    Text:changeRate
                               SuperView:_klineTopTipView
                                     Tag:-1];
        
        FMSelfStocksModel *s = [FMSelfStocksModel new];
        s.price = model.closePrice;
        s.closePrice = model.yestodayClosePrice;
        s.openPrice = model.openPrice;
        s.highPrice = model.heightPrice;
        s.lowPrice = model.lowPrice;
        NSString *change = [NSString stringWithFormat:@"%.2f%%",([model.closePrice floatValue]-[model.yestodayClosePrice floatValue])];
        s.change = change;
        s.changeRate = changeRate;
        [_topViews updateViewsWithModel:s infoModel:_stockInfoViews.model];
    }
    
    
    
    
    
    
}

-(CGSize)createLableWithSize:(CGFloat)size Color:(UIColor*)color Point:(CGPoint)point Text:(NSString*)text SuperView:(UIView *)view Tag:(NSInteger)tag{
    
    UILabel *l;
    if (tag>=0) {
        l = (UILabel*)[view viewWithTag:tag];
    }
    if (!l) {
        l = [[UILabel alloc] init];
        [view addSubview:l];
    }
    if (tag>=0) l.tag = tag;
    l.text = text;
    l.textColor = color;
    l.font = kFontNumber(size);
    l.frame = CGRectMake(point.x, point.y, UIScreenWidth, 0);
    [l sizeToFit];
    CGSize sizes = CGSizeMake(l.frame.size.width+l.frame.origin.x, l.frame.size.height);
    l = nil;
    return sizes;
    
}

-(NSString*)datetime:(NSString*)mdate{
    NSString *time = mdate;
    if (mdate.length>=8) {
        NSString *year = [mdate substringToIndex:4];
        NSString *month = [mdate substringWithRange:NSMakeRange(4, 2)];
        NSString *day = [mdate substringWithRange:NSMakeRange(6, 2)];
        // 显示日期
        time = [NSString stringWithFormat:@"%@-%@-%@",year,month,day];
    }
    if (mdate.length>=13) {
        NSString *year = [mdate substringToIndex:4];
        NSString *month = [mdate substringWithRange:NSMakeRange(4, 2)];
        NSString *day = [mdate substringWithRange:NSMakeRange(6, 2)];
        NSString *hour = [mdate substringWithRange:NSMakeRange(9, 2)];
        NSString *minute = [mdate substringWithRange:NSMakeRange(11, 2)];
        // 显示时间
        time = [NSString stringWithFormat:@"%@-%@-%@ %@:%@",year,month,day,hour,minute];
    }
    return time;
}

#pragma mark -
#pragma mark UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //    if (indexPath.row==0 && indexPath.section==0) return _stockInfoCellHeight;
    if (indexPath.row==0 && indexPath.section==0) return kFMKLineChartTabBarHeight;
    if (indexPath.row==1 && indexPath.section==0) return _klineBoxHeight+30;
    if (indexPath.row==0 && indexPath.section==1) {
        if (_sectionTwoType==0) {
            // 指数
            if ([_type isEqualToString:@"1"]) {
                return _stockCapital.height;
            }
            return kFMKLineCashFlow_Height;
        }
        if (_sectionTwoType==1) {
            return _stockCompany.frame.size.height;
        }
        if (_sectionTwoType==2) {
            return _stockFinance.frame.size.height;
        }
    }
    if (indexPath.row==1 && indexPath.section==1) return kFMKLineRecentlyMainForce_Height;
    return kTableViewCellHeight;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return 2;
    }
    if (section==1) {
        return _sectionTwoCount;
    }
    return _datas.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _sectionCount;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return 0;
    }
    return kFMKLineChartTabBarHeight;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (!_sectionTwo) {
        NSArray *titles = @[@"资金",@"基本面",@"财务"];
        if ([_type isEqualToString:@"1"]) {
            titles = @[@"板块资金流向",@"",@""];
            _sectionTwoCount = 1;
        }
        _sectionTwo = [[FMKLineChartTabBar alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, kFMKLineChartTabBarHeight) Titles:titles IsMove:YES showCounts:3];
        // 点击菜单
        WEAKSELF
        _sectionTwo.clickChartTabBarButtonHandle = ^(NSInteger tag){
            __weakSelf.sectionTwoType = (int)tag;
            __weakSelf.sectionTwoCount = 1;
            if (tag==0) {
                __weakSelf.sectionTwoCount = 2;
            }
            if (tag==1) {
                __weakSelf.sectionTwoCount = 2;
                if (__weakSelf.profitModels.count<=0) {
                    [__weakSelf getHttpStockCompany:NO];
                }
            }
            if (tag==2) {
                __weakSelf.sectionTwoCount = 1;
                [__weakSelf getHttpStockProfits:NO];
                
            }
            
            [__weakSelf.tableView reloadData];
        };
        
    }
    return _sectionTwo;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIndentifier = [NSString stringWithFormat:@"cell_%d_%d",(int)indexPath.section,(int)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIndentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.section==0) {
            //            if (indexPath.row==0) {
            //                [self createStockInfoViewsWithCell:cell];
            //            }
            if (indexPath.row==0) {
                [self createChartTabBarWithCell:cell];
            }
            if (indexPath.row==1) {
                [self createKLineChartViewsWithCell:cell];
            }
        }
        if (indexPath.section==1) {
            if (indexPath.row==0) {
                [self createKLineCashFlowViewsWithCell:cell];
                [_cashFlowViews startWithDatas:_cashFlowModels];
                [self createStockCompanyWithCell:cell];
                [self createFinanceViewWithCell:cell];
                [self createStockCapitalViewWithCell:cell];
            }
            if (indexPath.row==1) {
                [self createRecentlyMainForceWithCell:cell];
                [_recentlyMainForce startWithDatas:_recentModels title:nil];
                [self createProfitViewWithCell:cell];
                [_profitView startWithDatas:_profitModels title:nil];
            }
        }
        
    }
    
    if (indexPath.section==1) {
        if (indexPath.row==0) {
            [self createKLineCashFlowViewsWithCell:cell];
            [self createStockCompanyWithCell:cell];
            [self createFinanceViewWithCell:cell];
            [self createStockCapitalViewWithCell:cell];
        }
        if (indexPath.row==1) {
            [self createRecentlyMainForceWithCell:cell];
            [self createProfitViewWithCell:cell];
            
        }
    }
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat y = scrollView.contentOffset.y;
    CGFloat h = _tableView.tableHeaderView.frame.size.height;
    CGFloat w = _tableView.tableHeaderView.frame.size.width;
    CGFloat x = y;
    if (x>0) {
        x = 0;
    }
    if (_topViews && y<0) {
        CGFloat scaley = (h-y)/h;
        CGFloat scalex = scaley;
        x = (w - scalex*w)/2;
        _topViews.bg.transform = CGAffineTransformScale(_topViews.transform, scalex, scaley);
        _topViews.bg.frame = CGRectMake(0,y , w,h*scaley);
    }else{
        _topViews.bg.transform = CGAffineTransformScale(_topViews.transform, 1.0, 1.0);
        _topViews.bg.frame = CGRectMake(0,0 , w, h);
    }
    
    //    CGRect frame = _chartTabBar.moreViews.frame;
    //    frame.origin.y = kStatusBarHeight + kNavigationHeight + kFMSelfStockTopViewsHeight + kFMKLineChartTabBarHeight - y;
    //    _chartTabBar.moreViews.frame = frame;
    
}


#pragma mark -
#pragma mark HTTP Request

-(void)getHttpStockInfoFrom:(BOOL)loop{
    // 如果收盘了就不请求了
    if ([FMUserDefault marketIsClose]) {
        if (!loop) {
            [_tableView.header endRefreshing];
            [self loopGetHttpDataWithTimeout:kFMKLineChartViewStockInfoLoopTime];
            return;
        }
    }
    WEAKSELF
    [http getStockInfoWithCodes:@[_stockCode] start:^{
        
    } failure:^{
        [__weakSelf stopRefresh];
        if (!loop) {
            [__weakSelf loopGetHttpDataWithTimeout:kFMKLineChartViewStockInfoLoopTime];
        }
    } success:^(NSDictionary *dic){
        [__weakSelf stopRefresh];
        NSDictionary *list = [dic objectForKey:@"data"];
        if ([list isKindOfClass:[NSDictionary class]]) {
            FMStockInfoModel *model = [[FMStockInfoModel alloc] initWithDic:list];
            [__weakSelf createSignalWithModel:model];
            [__weakSelf.stockInfoViews updateViewsWithModel:model];
            __weakSelf.lastDate = model.lastDate;
            __weakSelf.lastTime = [NSString stringWithFormat:@"%@ %@",model.lastDate,model.lastTime];
            [__weakSelf setNavigationTitle];
            // 请求资金流向
            if ([__weakSelf.type intValue]<=0) {
                [__weakSelf getHttpStockMainForce:loop];
            }else{
                if (!loop) {
                    [__weakSelf loopGetHttpDataWithTimeout:kFMKLineChartViewStockInfoLoopTime];
                }
            }
            
        }else{
            if (!loop) {
                [__weakSelf loopGetHttpDataWithTimeout:kFMKLineChartViewStockInfoLoopTime];
            }
        }
    }];
}

-(void)getHttpDapanStocksNewData:(BOOL)loop{
    // 如果收盘了就不请求了
    if ([FMUserDefault marketIsClose]) {
        if (!loop) {
            [_tableView.header endRefreshing];
            [self loopGetHttpMinuteChartDataWithTimeout:kFMKLineChartViewMinuteChartLoopTime];
            return;
        }
    }
    
    WEAKSELF
    NSMutableArray *codes = [NSMutableArray new];
    [codes addObject:_stockCode];
    if (codes.count>0) {
        [http getStockWithCodes:codes start:^{
            
        } failure:^{
            if (!loop) {
                [__weakSelf loopGetHttpMinuteChartDataWithTimeout:kFMKLineChartViewStockInfoLoopTime];
            }
        } success:^(NSDictionary* dic){
            NSArray *list = [dic objectForKey:@"data"];
            if (list.count>0) {
                for (NSDictionary *item in list) {
                    FMSelfStocksModel *m = [[FMSelfStocksModel alloc] initWithDic:item];
                    if (m) {
                        __weakSelf.price = m.price;
                        __weakSelf.closePrice = m.closePrice;
                        __weakSelf.highPrice = m.highPrice;
                        __weakSelf.lowPrice = m.lowPrice;
                        __weakSelf.openPrice = m.openPrice;
                        __weakSelf.lastDate = m.lastDate;
                        if (__weakSelf.klineTopTipView.hidden || !__weakSelf.klineTopTipView) {
                            
                            [__weakSelf.topViews updateViewsWithModel:m infoModel:__weakSelf.stockInfoViews.model];
                            [__weakSelf updateHeaderViewsBackground];
                        }
                        
                        // 更新分时图
                        if (__weakSelf.klineModel) {
                            if (__weakSelf.klineModel.type==FMStockType_MinuteChart && __weakSelf.klineModel.yestodayClosePrice<=0) {
                                [__weakSelf FMKLineChartTabBarClickButton:FMStockType_MinuteChart];
                            }
                        }
                        if (!loop) {
                            [__weakSelf loopGetHttpMinuteChartDataWithTimeout:kFMKLineChartViewStockInfoLoopTime];
                        }
                    }
                    m = nil;
                }
            }else{
                if (!loop) {
                    [__weakSelf loopGetHttpMinuteChartDataWithTimeout:kFMKLineChartViewStockInfoLoopTime];
                }
            }
        }];
    }
}

-(void)getHttpStockMainForce:(BOOL)loop{
    WEAKSELF
    [http getStockMainForceWithCodes:@[_stockCode] start:^{
        
    } failure:^{
        if (!loop) {
            [__weakSelf loopGetHttpDataWithTimeout:kFMKLineChartViewStockInfoLoopTime];
        }
    } success:^(NSDictionary*dic){
        NSArray *list = [dic objectForKey:@"data"];
        if (list.count>0) {
            // 处理数据
            [__weakSelf.recentModels removeAllObjects];
            [__weakSelf.cashFlowModels removeAllObjects];
            double mfPrices_in = 0;
            double mfPrices_out = 0;
            double shPrice_in = 0;
            double shPrice_out = 0;
            for (NSDictionary *item in list) {
                FMRecentlyModel *m = [[FMRecentlyModel alloc] initWithDic:item];
                [__weakSelf.recentModels addObject:m];
                
                // 超大单和大单为主力流入流出
                if ([m.title hasSuffix:@"大单"]) {
                    mfPrices_in += m.inflow;
                    mfPrices_out += m.flowOut;
                }else{
                    shPrice_in += m.inflow;
                    shPrice_out += m.flowOut;
                }
                
                m = nil;
            }
            // 总资金量
            double toPrice = fabs(mfPrices_in) + fabs(mfPrices_out) + fabs(shPrice_in) + fabs(shPrice_out);
            if (toPrice<=0) {
                if (!loop) {
                    [__weakSelf loopGetHttpDataWithTimeout:kFMKLineChartViewStockInfoLoopTime];
                }
                return ;
            }
            double shPercent_in = fabs(shPrice_in)/toPrice;
            double shPercent_out = fabs(shPrice_out)/toPrice;
            double mfPercent_in = fabs(mfPrices_in)/toPrice;
            double mfPercent_out = fabs(mfPrices_out)/toPrice;
            
            FMCashFlowModel *m2 = [[FMCashFlowModel alloc] init];
            m2.title = @"散户流出";
            m2.percent = shPercent_out;
            m2.info = [NSString stringWithFormat:@"%.f万元",fabs(shPrice_out)];;
            m2.color = FMLowGreenColor;
            [__weakSelf.cashFlowModels addObject:m2];
            m2 = nil;
            FMCashFlowModel *m4 = [[FMCashFlowModel alloc] init];
            m4.title = @"主力流出";
            m4.percent = mfPercent_out;
            m4.info = [NSString stringWithFormat:@"%.f万元",fabs(mfPrices_out)];;
            m4.color = FMGreenColor;
            [__weakSelf.cashFlowModels addObject:m4];
            m4 = nil;
            FMCashFlowModel *m3 = [[FMCashFlowModel alloc] init];
            m3.title = @"主力流入";
            m3.percent = mfPercent_in;
            m3.info = [NSString stringWithFormat:@"%.f万元",fabs(mfPrices_in)];;
            m3.color = FMRedColor;
            [__weakSelf.cashFlowModels addObject:m3];
            m3 = nil;
            FMCashFlowModel *m1 = [[FMCashFlowModel alloc] init];
            m1.title = @"散户流入";
            m1.percent = shPercent_in;
            m1.info = [NSString stringWithFormat:@"%.f万元",fabs(shPrice_in)];
            m1.color = FMYellowColor;
            [__weakSelf.cashFlowModels addObject:m1];
            m1 = nil;
            
            [__weakSelf.recentlyMainForce startWithDatas:_recentModels title:nil];
            [__weakSelf.cashFlowViews startWithDatas:_cashFlowModels];
            if (!loop) {
                [__weakSelf loopGetHttpDataWithTimeout:kFMKLineChartViewStockInfoLoopTime];
            }
        }else{
            if (!loop) {
                [__weakSelf loopGetHttpDataWithTimeout:kFMKLineChartViewStockInfoLoopTime];
            }
        }
        
    }];
}

-(void)getHttpStockProfits:(BOOL)loop{
    if (_financeModel) {
        return;
    }
    WEAKSELF
    [http getStockProfitsWithCode:_stockCode start:^{
        
    } failure:^{
        
    } success:^(NSDictionary*dic){
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSDictionary *list = [dic objectForKey:@"data"];
            if (list.count>0) {
                // 处理数据
                __weakSelf.financeModel = nil;
                __weakSelf.financeModel = [[FMStockFinanceModel alloc] initWithDic:list];
                dispatch_async_main_safe(^{
                    [__weakSelf.stockFinance updateWithModel:__weakSelf.financeModel];
                });
                
            }
            
        });
        
    }];
}

-(void)getHttpStockCompany:(BOOL)loop{
    WEAKSELF
    [http getStockCompanyWithCode:_stockCode start:^{
        
    } failure:^{
        
    } success:^(NSDictionary*dic){
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSDictionary *list = [dic objectForKey:@"data"];
            if (list.count>0) {
                FMStockCompanyModel *m = [[FMStockCompanyModel alloc] initWithDic:list];
                // 处理数据
                [__weakSelf.profitModels removeAllObjects];
                NSArray *datas = [list objectForKey:@"data"];
                for (NSDictionary *item in datas) {
                    FMProfitModel *m = [[FMProfitModel alloc] initWithDic:item];
                    [__weakSelf.profitModels addObject:m];
                    m = nil;
                }
                
                dispatch_async_main_safe(^{
                    [__weakSelf.profitView startWithDatas:_profitModels title:nil];
                    [__weakSelf.stockCompany updateWithModel:m];
                    [__weakSelf.tableView reloadData];
                    
                })
            }
            
        });
        
    }];
}

//  按指定时间间隔请求数据
-(void)loopGetHttpDataWithTimeout:(NSInteger)loopTime{
    if (!_isOut) {
        if (loopTime<=0) {
            // 停止刷新
            return;
        }
        [self performSelector:@selector(getHttpStockInfoFrom:) withObject:nil afterDelay:loopTime];
    }
    
}

// 分时图
-(void)loopGetHttpMinuteChartDataWithTimeout:(NSInteger)loopTime{
    if (!_isOut) {
        if (loopTime<=0) {
            // 停止刷新
            return;
        }
        [self performSelector:@selector(getHttpDapanStocksNewData:) withObject:nil afterDelay:loopTime];
    }
    
}

// 是否vip用户
-(void)checkHttpIsVipUser{
    WEAKSELF
    [http checkUserIsVipWithStart:^{} failure:^{} success:^(NSDictionary*dic){
        if (![dic[@"data"] isEqual:[NSNull null]]) {
            BOOL success = [dic[@"data"]boolValue];
            if (success) {
                // 是vip
                [FMUserDefault setUserIsPayed:1];
            }else{
                [FMUserDefault setUserIsPayed:0];
                // 非vip 提示需要收费用户才能看到实时的买卖点提示
                if (_stockCharType==FMStockType_DaysChart ||
                    _stockCharType==FMStockType_MonthChart ||
                    _stockCharType==FMStockType_WeekChart) {
                    
                    [__weakSelf createVipTipUserViews];
                    
                }else{
                    __weakSelf.vipTipView.hidden = YES;
                }
                
            }
        }else{
            [FMUserDefault setUserIsPayed:0];
            // 非vip 提示需要收费用户才能看到实时的买卖点提示
            if (_stockCharType==FMStockType_DaysChart ||
                _stockCharType==FMStockType_MonthChart ||
                _stockCharType==FMStockType_WeekChart) {
                
                [__weakSelf createVipTipUserViews];
                
            }else{
                __weakSelf.vipTipView.hidden = YES;
            }
        }
        
    }];
}

-(void)addMJHeader{
    WEAKSELF
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [__weakSelf getHttpStockInfoFrom:YES];
        [__weakSelf getHttpDapanStocksNewData:YES];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
//    header.stateLabel.textColor = [UIColor whiteColor];
//    header.lastUpdatedTimeLabel.textColor = [UIColor whiteColor];
//    header.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
//    header.arrowView.image = [UIImage imageWithTintColor:[UIColor whiteColor] blendMode:kCGBlendModeDestinationIn WithImageObject:header.arrowView.image];
    header.backgroundColor = [UIColor clearColor];
    _tableView.header = header;
    [header beginRefreshing];
}
@end
