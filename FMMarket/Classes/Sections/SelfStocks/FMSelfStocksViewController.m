//
//  FMSelfStocksViewController.m
//  FMMarket
//
//  Created by dangfm on 15/8/7.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMSelfStocksViewController.h"
#import "FMSelfStockTableView.h"
#import "FMSelfStockTableViewCell.h"
#import "FMSelfStocksModel.h"
#import "FMSearchStocksViewController.h"
#import "FMSelfStockSecionView.h"
#import "FMSelfStockTopViews.h"
#import "FMNavigationController.h"
#import "FMKLineChartViewController.h"
#import "UIButton+stocking.h"
#import "FMStockAddButtonViews.h"
#import "FMEditStocksViewController.h"
#import "FMLoginViewController.h"
#import "FMMarketViewController.h"

@interface FMSelfStocksViewController ()
<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
{
    
}

@property (nonatomic,retain) FMTableView *tableView;
@property (nonatomic,retain) NSMutableArray *datas;
@property (nonatomic,retain) NSMutableArray *codes;
@property (nonatomic,assign) BOOL isOut;
@property (nonatomic,retain) FMSelfStockTopViews *topViews;
@property (nonatomic,retain) FMStockAddButtonViews *noDataViews;
@property (nonatomic,retain) UIButton *bottomView;
@property (nonatomic,retain) UISegmentedControl *segment;
@property (nonatomic,retain) FMMarketViewController *marketView;


@end

@implementation FMSelfStocksViewController

-(void)dealloc{
    NSLog(@"FMSelfStocksViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initParams];
    [self createViews];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.segment.selectedSegmentIndex = 0;
    [self loadLocalDatas];
    [self.navigation changeLineBackgroundColor:FMNavColor];
}
-(void)viewDidAppear:(BOOL)animated{
    // 更新数据
    _isOut = NO;
    [self loadDatas];
    //
    [self getHttpStocksNewData:YES];
    [self loopGetHttpDataWithTimeout:[FMUserDefault getSelfStockLoopTime]];
    
    
    //[self getHttpDapanStocksNewData:NO];
    //[self updateHeaderViewsBackground];
    [self createTableFooterView];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _isOut = YES;
    //_segment.selectedSegmentIndex = 0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initParams{
    _datas = [NSMutableArray new];
    _codes = [NSMutableArray new];
    [self loadLocalDatas];
    [self loadDatas];
    // 只在每次初始化开始定时循环
    // [self getHttpStocksNewData:NO];
    
}

-(void)loadDatas{
    if (_datas.count>0) {
        _noDataViews.hidden = YES;
    }else{
        _noDataViews.hidden = NO;
    }
    [_tableView reloadData];
}

-(void)loadLocalDatas{
    NSString *where = nil;
    if ([[FMUserDefault getUserId]floatValue]>0) {
        where = [NSString stringWithFormat:@" userId='%@'",[FMUserDefault getUserId]];
    }
    NSArray *rs = [db select:[FMSelfStocksModel class] Where:where Order:@" abs(orderValue) desc" Limit:nil];
    
    if (rs) {
        [_codes removeAllObjects];
        for (FMSelfStocksModel *m in rs) {
            [_codes addObject:m.code];
        }
        [_datas removeAllObjects];
        _datas = [NSMutableArray arrayWithArray:rs];
        
    }
    rs = nil;
    
}

#pragma mark -
#pragma mark UI Create
//首页顶部选项卡
-(void)createSegmentViews{
    UISegmentedControl *seg = [UISegmentedControl createWithTitles:@[@"自选股",@"行情"]];
    seg.frame = CGRectMake((UIScreenWidth-seg.frame.size.width)/2,
                           (self.header.frame.size.height-seg.frame.size.height)/2,
                           seg.frame.size.width, seg.frame.size.height);
    //[self.header addSubview:seg];
    seg.selectedSegmentIndex = 0;
    self.navigationItem.titleView = seg;
    [seg addTarget:self
            action:@selector(clickSegmentAction:)
  forControlEvents:UIControlEventValueChanged];
    _segment = seg;
    seg = nil;
}
-(void)createViews{
    [self createSegmentViews];
//    [self setTitle:@"自选中心" IsBack:NO ReturnType:0];
//        self.navigationItem.title = @"自选股";
    if (!_tableView) {
        CGRect frame = CGRectMake(0, 0, UIScreenWidth,
                                  UIScreenHeight-kTabBarNavigationHeight-kTabBarNavigationHeight64);
        _tableView = [[FMSelfStockTableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        //_tableView.backgroundColor = FMGreyColor;
        [self.view addSubview:_tableView];
        
    }
    [self createEditButton];
    [self createTableHeaderView];
    [self createTableFooterView];
    [self createNoDataViews];
    [self addMJHeader];
}

// 头部
-(void)createTableHeaderView{
    UISearchBar *sbar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, kNavigationHeight)];
    sbar.backgroundColor = [UIColor whiteColor];
    [sbar setBackgroundImage:[UIImage imageWithColor:FMBgGreyColor andSize:sbar.frame.size]];
    sbar.inputView.layer.borderColor = FMBottomLineColor.CGColor;
    sbar.inputView.layer.borderWidth = 0.5;
    sbar.placeholder = @"股票代码,首字母";
    
    sbar.delegate = self;
    _tableView.tableHeaderView = sbar;
    sbar = nil;
}
//
//// 头部
//-(void)createTableHeaderView{
//    if (!_topViews) {
//        _topViews = [[FMSelfStockTopViews alloc]
//                     initWithFrame:CGRectMake(0, 0, UIScreenWidth, kFMSelfStockTopViewsHeight)];
//        _tableView.tableHeaderView = _topViews;
//        //_tableView.tableFooterView.backgroundColor = FMGreyColor;
//        __weak typeof(self) weakSelf = self;
//        _topViews.clickStockTopViewBlock = ^(FMSelfStocksModel*m){
//            FMKLineChartViewController *kline = [[FMKLineChartViewController alloc]
//                                                 initWithStockCode:m.code
//                                                 StockName:m.name
//                                                 Price:m.price
//                                                 ClosePrice:m.closePrice
//                                                 Type:m.type];
//            [weakSelf.navigationController pushViewController:kline animated:YES];
//            kline = nil;
//        };
//    }
//    [self updateHeaderViewsBackground];
//}
// 底部
-(void)createTableFooterView{
    if (!_bottomView) {
        _bottomView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, kNavigationHeight+10)];
        [_bottomView setTitleColor:FMGreyColor forState:UIControlStateNormal];
        _bottomView.titleLabel.font = kDefaultFont;
        _tableView.tableFooterView = _bottomView;
        
    }
    
    if ([[FMUserDefault getUserId] floatValue]>0) {
        [_bottomView setTitle:[NSString stringWithFormat:@"已登陆，%@账号：%@",[fn getAppName],[FMUserDefault getNickName]]
                     forState:UIControlStateNormal];
        [_bottomView removeTarget:self
                           action:@selector(clickFooterButtonAction)
                 forControlEvents:UIControlEventTouchUpInside];
    }else{
        [_bottomView setTitle:@"登录，享受更多特殊服务 >" forState:UIControlStateNormal];
        [_bottomView addTarget:self
                        action:@selector(clickFooterButtonAction)
              forControlEvents:UIControlEventTouchUpInside];
    }
    
}
//  根据大盘涨跌改变头部视图背景
//-(void)updateHeaderViewsBackground{
//    if (!_isOut) {
//        FMNavigationController *navigation = (FMNavigationController*)self.navigationController;
//        UIColor *color = _topViews.backgroundColor;
//        [navigation changeLineBackgroundColor:color];
//    }
//}

-(void)createEditButton{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    UIButton * editBt = [UIButton buttonWithType:UIButtonTypeCustom];
    editBt.frame = CGRectMake(0, 0, 55, 44);
    [editBt setTitle:@"编辑" forState:UIControlStateNormal];
    [editBt setTitleEdgeInsets:UIEdgeInsetsMake(0, -25, 0, 0)];
    [editBt.titleLabel setFont:kFont(16)];
    [editBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [editBt addTarget:self
               action:@selector(clickEditButtonHandle:)
     forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBt = [[UIBarButtonItem alloc] initWithCustomView:editBt];
    self.navigationItem.leftBarButtonItem = leftBt;
    //self.header.backButton = editBt;
    
    UIBarButtonItem *refreshBt = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                  target:self
                                  action:@selector(clickRefreshButtonHandle:)];
    
    UIBarButtonItem *searchBt = [[UIBarButtonItem alloc]
                                 initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                 target:self
                                 action:@selector(clickSearchButtonHandle:)];
    self.navigationItem.rightBarButtonItems = @[refreshBt,searchBt];
}
//  自选为空时提示添加自选界面
-(void)createNoDataViews{
    if (!_noDataViews) {
        _noDataViews = [[FMStockAddButtonViews alloc] initWithFrame:CGRectMake(0, kFMSelfStockSectionViewHeight+kFMSelfStockTopViewsHeight, UIScreenWidth, _tableView.frame.size.height-kFMSelfStockSectionViewHeight-kFMSelfStockTopViewsHeight)];
        //_tableView.tableFooterView = _noDataViews;
        [_tableView addSubview:_noDataViews];
        _noDataViews.hidden = YES;
        __weak typeof(self) weakself = self;
        _noDataViews.clickAddStocksButtonBlock = ^{
            // 弹出搜索界面
            [weakself clickSearchButtonHandle:nil];
        };
    }
}

#pragma mark -
#pragma mark UI Action
//点击选项卡
-(void)clickSegmentAction:(UISegmentedControl*)seg{
    if (!_marketView) {
        _marketView = [[FMMarketViewController alloc] init];
        
    }
    if (seg.selectedSegmentIndex==1) {
        [self.navigationController pushViewController:_marketView animated:NO];
    }else{
        
    }
    
}
//  点击编辑按钮
-(void)clickEditButtonHandle:(UIButton*)bt{
    FMEditStocksViewController *edit = [[FMEditStocksViewController alloc] initWithDatas:_datas];
    FMNavigationController *n = [[FMNavigationController alloc] initWithRootViewController:edit];
    [self presentViewController:n animated:YES completion:^{
    }];
    edit = nil;
}
//  点击搜索按钮
-(void)clickSearchButtonHandle:(UIBarButtonItem*)bt{
    WEAKSELF
    FMSearchStocksViewController *search = [[FMSearchStocksViewController alloc] init];
    FMNavigationController *n = [[FMNavigationController alloc] initWithRootViewController:search];
    [self presentViewController:n animated:YES completion:^{
        //[__weakSelf updateHeaderViewsBackground];
    }];
    n = nil;
    search = nil;
}
//  点击刷新按钮
-(void)clickRefreshButtonHandle:(UIBarButtonItem*)bt{
    
    [self getHttpStocksNewData:YES];
    //[self getHttpDapanStocksNewData:YES];
    [self performSelector:@selector(stopRefresh) withObject:nil afterDelay:10];
}
-(void)stopRefresh{
    UIBarButtonItem *bt = [self.navigationItem.rightBarButtonItems firstObject];
    if ([bt.customView isKindOfClass:[UIActivityIndicatorView class]])
    {
        UIActivityIndicatorView *jh = (UIActivityIndicatorView*)bt.customView;
        [jh stopAnimating];
        jh = nil;
        bt.customView = nil;
        self.navigationItem.rightBarButtonItems = nil;
        [self createEditButton];
    }
    bt = nil;
    
}

-(void)startRefresh{
    UIBarButtonItem *bt = [self.navigationItem.rightBarButtonItems firstObject];
    if (![bt.customView isKindOfClass:[UIActivityIndicatorView class]])
    {
        UIActivityIndicatorView *jh = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        bt.customView = jh;
        [jh startAnimating];
        jh = nil;
    }
    bt = nil;
}

//  点击登录
-(void)clickFooterButtonAction{
    FMLoginViewController *login = [[FMLoginViewController alloc] init];
    [self.navigationController pushViewController:login animated:YES];
    login = nil;
}


#pragma mark -
#pragma mark UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kTableViewCellHeight;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return kFMSelfStockSectionViewHeight;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _datas.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    FMSelfStockSecionView *sview = [[FMSelfStockSecionView alloc]
                                    initWithFrame:CGRectMake(0, 0, UIScreenWidth, kFMSelfStockSectionViewHeight)];
    
    return sview;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIndentifier = @"cell";
    FMSelfStockTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[FMSelfStockTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:cellIndentifier];
        
    }
    _noDataViews.hidden = YES;
    if (indexPath.row<_datas.count) {
        [cell setContent:[_datas objectAtIndex:indexPath.row]];
    }
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    FMSelfStocksModel *model = (FMSelfStocksModel*)[_datas objectAtIndex:indexPath.row];
    FMKLineChartViewController *kline = [[FMKLineChartViewController alloc]
                                         initWithStockCode:model.code
                                         StockName:model.name
                                         Price:model.price
                                         ClosePrice:model.closePrice
                                         Type:model.type];
    [self.navigationController pushViewController:kline animated:YES];
    kline = nil;
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
}

#pragma mark -
#pragma mark UISearchBarDelegate
-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    [self clickSearchButtonHandle:nil];
    return false;
}

#pragma mark -
#pragma mark HTTP Request

-(void)getHttpStocksNewData:(BOOL)noloop{
    if (_isOut){
        [self stopRefresh];
        [_tableView.header endRefreshing];
        return;
    }
    // 如果收盘了就不请求了
    if ([FMUserDefault marketIsClose]) {
        if (!noloop) {
            [self stopRefresh];
            [_tableView.header endRefreshing];
            [fn sleepSeconds:10 finishBlock:^{
                [self loopGetHttpDataWithTimeout:[FMUserDefault getSelfStockLoopTime]];
            }];
            return;
        }
    }
    WEAKSELF
    if (_codes.count>0) {
        [http getStockWithCodes:_codes start:^{
            [__weakSelf startRefresh];
        } failure:^{
            [__weakSelf stopRefresh];
            [_tableView.header endRefreshing];
            if (_isOut)  return;
            // 继续请求
            if (!noloop) {
                [__weakSelf loopGetHttpDataWithTimeout:[FMUserDefault getSelfStockLoopTime]];
            }
            
        } success:^(NSDictionary* dic){
            
            [__weakSelf stopRefresh];
            [_tableView.header endRefreshing];
            if (_isOut)  return;
            NSArray *list = [dic objectForKey:@"data"];
            if (list.count>0 && !_isOut) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    for (NSDictionary *item in list) {
                        FMSelfStocksModel *m = [[FMSelfStocksModel alloc] initWithDic:item];
                        m.timestamp = [NSString stringWithFormat:@"%.f",[fn getTimestamp]];
                        //m.orderValue = [NSString stringWithFormat:@"%d",(int)[list indexOfObject:item]];
                        if (m) {
                            [db update:m
                                 Where:[NSString stringWithFormat:@"code='%@'",m.code]
                           FinishBlock:^(bool issuccess){
                               if ([item isEqual:[list lastObject]]){
                                   [__weakSelf loadLocalDatas];
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       [__weakSelf loadDatas];
                                       //                                       [_tableView reloadData];
                                       // 继续请求
                                       if (!noloop) {
                                           [__weakSelf loopGetHttpDataWithTimeout:[FMUserDefault getSelfStockLoopTime]];
                                       }
                                   });
                                   
                               }
                           }];
                        }
                        m = nil;
                    }
                });
                
                
            }else{
                
                // 继续请求
                if (!noloop) {
                    [__weakSelf loopGetHttpDataWithTimeout:[FMUserDefault getSelfStockLoopTime]];
                }
            }
        }];
    }
}

//-(void)getHttpDapanStocksNewData:(BOOL)noloop{
//    // 如果收盘了就不请求了
//    if ([FMUserDefault marketIsClose]) {
//        if (!noloop) {
//            [self loopGetHttpDataWithTimeout:[FMUserDefault getSelfStockLoopTime]];
//        }
//    }
//    WEAKSELF
//    NSMutableArray *codes = [NSMutableArray new];
//    [codes addObject:kStocksDapanCode];
//    if (codes.count>0) {
//        [http getStockWithCodes:codes start:^{
//
//        } failure:^{
//            if (_datas.count<=0) {
//                // 继续请求
//                if (!noloop) {
//                    [__weakSelf loopGetHttpDataWithTimeout:[FMUserDefault getSelfStockLoopTime]];
//                }
//            }
//        } success:^(NSDictionary* dic){
//            NSArray *list = [dic objectForKey:@"data"];
//            if (list.count>0 && !_isOut) {
//                dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                    for (NSDictionary *item in list) {
//                        FMSelfStocksModel *m = [[FMSelfStocksModel alloc] initWithDic:item];
//                        if (m) {
//                            dispatch_async_main_safe(^{
//                                [_topViews updateViewsWithModel:m];
//                                //[__weakSelf updateHeaderViewsBackground];
//                                if (_datas.count<=0) {
//                                    // 继续请求
//                                    if (!noloop) {
//                                        [__weakSelf loopGetHttpDataWithTimeout:[FMUserDefault getSelfStockLoopTime]];
//                                    }
//                                }
//                            });
//                        }
//                        m = nil;
//                    }
//                });
//            }else{
//                if (_datas.count<=0) {
//                    // 继续请求
//                    if (!noloop) {
//                        [__weakSelf loopGetHttpDataWithTimeout:[FMUserDefault getSelfStockLoopTime]];
//                    }
//                }
//            }
//        }];
//    }
//}

//  按指定时间间隔请求数据
-(void)loopGetHttpDataWithTimeout:(NSInteger)loopTime{
    if (!_isOut) {
        if (loopTime<=0) {
            // 不刷新
            return;
        }
        [self performSelector:@selector(getHttpStocksNewData:) withObject:nil afterDelay:loopTime];
        //[self performSelector:@selector(getHttpDapanStocksNewData:) withObject:nil afterDelay:loopTime];
    }
    
}

-(void)addMJHeader{
    WEAKSELF
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [__weakSelf getHttpStocksNewData:YES];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    //    header.stateLabel.textColor = [UIColor whiteColor];
    //    header.lastUpdatedTimeLabel.textColor = [UIColor whiteColor];
    //    header.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    //    header.arrowView.image = [UIImage imageWithTintColor:[UIColor whiteColor] blendMode:kCGBlendModeDestinationIn WithImageObject:header.arrowView.image];
    header.backgroundColor = [UIColor clearColor];
    _tableView.header = header;
}
@end
