//
//  FMMarketViewController.m
//  FMMarket
//
//  Created by dangfm on 15/11/18.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMMarketViewController.h"
#import "FMTableView.h"
#import "FMSelfStockTableViewCell.h"
#import "TopThreeView.h"
#import "FMMarketTableSection.h"
#import "FMKLineChartViewController.h"
#import "FMUpDownListViewController.h"
#import "FMSelfStocksViewController.h"
#import "FMSearchStocksViewController.h"
#import "FMPlateUpDownListViewController.h"

static NSString *marketIndexCacheKey = @"FMMarketViewControllerIndexCacheKey";
static NSString *marketUpDownListCacheKey = @"FMMarketViewControllerUpDownListCacheKey";


@interface FMMarketViewController()
<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    
}

@property (nonatomic,retain) NSMutableArray *datas;
@property (nonatomic,retain) FMTableView *tableView;
@property (nonatomic,retain) TopThreeView *threeView;
@property (nonatomic,retain) TopThreeView *tradeViewOne;
@property (nonatomic,retain) TopThreeView *tradeViewTwo;
@property (nonatomic,retain) TopThreeView *gainianViewOne;
@property (nonatomic,retain) TopThreeView *gainianViewTwo;
@property (nonatomic,retain) TopThreeView *diyuViewOne;
@property (nonatomic,retain) TopThreeView *diyuViewTwo;
@property (nonatomic,retain) UISegmentedControl *segment;
@property (nonatomic,assign) BOOL isout;
@property (nonatomic,assign) BOOL isRefreshing;

@end

@implementation FMMarketViewController

-(void)dealloc{
    self.tableView.delegate = nil;
    NSLog(@"FMMarketViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initParams];
    [self createViews];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    _segment.selectedSegmentIndex = 1;
    _isout = NO;
    [self runTimer:[FMUserDefault getSelfStockLoopTime]];
    [self.navigation changeLineBackgroundColor:FMNavColor];
    [self getHttpStockIndexList:YES];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidAppear:animated];
    _isout = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Init
-(void)initParams{
    _datas = [NSMutableArray new];
    
}

#pragma mark -
#pragma mark UI Create
-(void)createViews{
    
//        self.navigationItem.title = @"行情中心";
    //    [self setTitle:@"行情" IsBack:NO ReturnType:0];
    [self createSegmentViews];
    [self createEditButton];
    [self createTableView];
}

//  Create TableView
-(void)createTableView{
    if (!_tableView) {
        _tableView = [[FMTableView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, UIScreenHeight-kTabBarNavigationHeight64-kTabBarNavigationHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = FMBgGreyColor;
        [self.view addSubview:_tableView];
        [self createTopThreeViews];
        [self addMJHeader];
        // 缓存
        NSString *jsonStr = [[EGOCache globalCache] stringForKey:marketUpDownListCacheKey];
        if (jsonStr) {
            NSArray *obj = [jsonStr JSONValue];
            if (obj) {
                _datas = [NSMutableArray arrayWithArray:obj];
                [_tableView reloadData];
            }
        }
    }
}

-(void)createEditButton{
    
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

-(void)createSegmentViews{
    UISegmentedControl *seg = [UISegmentedControl createWithTitles:@[@"自选股",@"行情"]];
    seg.frame = CGRectMake((UIScreenWidth-seg.frame.size.width)/2,
                           (self.header.frame.size.height-seg.frame.size.height)/2,
                           seg.frame.size.width, seg.frame.size.height);
    seg.selectedSegmentIndex = 1;
    //    [self.header addSubview:seg];
    //    [seg addTarget:self action:@selector(clickSegmentAction:) forControlEvents:UIControlEventValueChanged];
    //    _segment = seg;
    //    seg = nil;
    
    self.navigationItem.titleView = seg;
    [seg addTarget:self
            action:@selector(clickSegmentAction:)
  forControlEvents:UIControlEventValueChanged];
    _segment = seg;
    seg = nil;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] init];
    
    self.navigationItem.leftBarButtonItem = item;
    
}

-(void)createTopThreeViews{
    float h = kThreeViewHeight;
    UIView *box = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, h)];
    _threeView = [[TopThreeView alloc] initWithFrame:CGRectMake(0, 5,UIScreenWidth,kThreeViewHeight)];
    // 点击按钮
    __weak typeof(self) weakSelf = self;
    _threeView.clickTopThreeButtonBlock = ^(TopThreeView *topthree,ThreeButton *button){
        NSString *code = button.code;
        NSString *type = button.type;
        NSString *name = button.titler.text;
        NSString *price = button.price.text;
        FMKLineChartViewController *kline = [[FMKLineChartViewController alloc] initWithStockCode:code StockName:name Price:price ClosePrice:nil Type:type];
        [weakSelf.navigationController pushViewController:kline animated:YES];
        kline = nil;
    };
    
    [box addSubview:_threeView];
    [fn drawLineWithSuperView:box Color:FMBottomLineColor Location:1];
    
    // 缓存
    NSString *jsonStr = [[EGOCache globalCache] stringForKey:cacheForTopThreeDataKey];
    if (jsonStr) {
        NSArray *obj = [jsonStr JSONValue];
        if (obj) {
            [_threeView updateViewsWithDatas:obj];
        }
    }
    
    _tableView.tableHeaderView = box;
}

#pragma mark -
#pragma mark UI Action


-(void)clickSegmentAction:(UISegmentedControl*)seg{
    if (seg.selectedSegmentIndex==0) {
        [self.navigationController popViewControllerAnimated:NO];
        
        
    }else{
        
    }
}

-(void)clickMoreButtonAction:(UIButton*)sender{
    NSInteger tag = sender.tag;
    NSDictionary *sectionData = [_datas objectAtIndex:tag];
    NSString *typeCode = [sectionData objectForKey:@"typeCode"];
    NSString *typeName = [sectionData objectForKey:@"name"];
    if (tag<=2) {
        FMPlateUpDownListViewController *plate = [[FMPlateUpDownListViewController alloc] initWithTypeCode:typeCode typeName:typeName];
        [self.navigationController pushViewController:plate animated:YES];
        plate = nil;
    }else{
        FMUpDownListViewController *list = [[FMUpDownListViewController alloc] initWithTypeCode:typeCode typeName:typeName];
        [self.navigationController pushViewController:list animated:YES];
        list = nil;
    }
}

-(void)changeSegmentViewWithNotification:(NSNotification*)notification{
    NSString* action = [notification.userInfo objectForKey:@"action"];
    if ([action isEqualToString:@"location:market"]){
        
    }
    if ([action isEqualToString:@"location:optionlstocks"]) {
        if (_segment.selectedSegmentIndex==0) {
            [_segment setSelectedSegmentIndex:1];
            [self clickSegmentAction:_segment];
        }
        
    }
}

//  点击搜索按钮
-(void)clickSearchButtonHandle:(UIBarButtonItem*)bt{
    //WEAKSELF
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
    
    [self getHttpStockIndexList:YES];
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



#pragma mark -
#pragma mark UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    // 行业涨跌幅 概念涨跌幅
    if (indexPath.section<=2) {
        return kThreeViewTradeHeight*2;
    }
    return kTableViewCellHeight;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return kFMMarketTableSectionHeight;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return _datas.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // 行业涨跌幅 概念涨跌幅
    if (section<=2) {
        return 1;
    }
    NSDictionary *sectionData = [_datas objectAtIndex:section];
    NSArray *list = [sectionData objectForKey:@"data"];
    int count = 0;
    if ([[list class] isSubclassOfClass:[NSArray class]]) {
        count = (int)list.count;
    }
    list = nil;
    sectionData = nil;
    return count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    NSDictionary *sectionData = [_datas objectAtIndex:section];
    NSString *title = [sectionData objectForKey:@"name"];
    NSString *typeCode = [sectionData objectForKey:@"typeCode"];
    FMMarketTableSection *s = [[FMMarketTableSection alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, kFMMarketTableSectionHeight) title:title typeCode:typeCode];
    s.moreBt.tag = section;
    [s.moreBt addTarget:self action:@selector(clickMoreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    sectionData = nil;
    title = nil;
    typeCode = nil;
    return s;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIndentifier = [NSString stringWithFormat:@"cell_%d_%d",(int)indexPath.section,(int)indexPath.row];
    FMSelfStockTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[FMSelfStockTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:cellIndentifier];
        cell.typeIcon.hidden = YES;
        cell.code.frame = CGRectMake(cell.typeIcon.frame.origin.x, cell.code.frame.origin.y, cell.code.frame.size.width, cell.code.frame.size.height);
        
    }
    if (indexPath.section<=2) {
        WEAKSELF
        if (indexPath.section==0) {
            if (!_tradeViewOne) {
                _tradeViewOne = [[TopThreeView alloc] initWithFrame:CGRectMake(0, 0,
                                                                               UIScreenWidth,
                                                                               kThreeViewTradeHeight)];
                [fn drawLineWithSuperView:_threeView Color:FMBottomLineColor Location:1];
                // 点击按钮
                _tradeViewOne.clickTopThreeButtonBlock = ^(TopThreeView *topthree,ThreeButton *button){
                    NSString *typeCode = button.tradeType;
                    NSString *typeName = button.trade.text;
                    FMUpDownListViewController *list = [[FMUpDownListViewController alloc] initWithTypeCode:typeCode typeName:typeName];
                    [__weakSelf.navigationController pushViewController:list animated:YES];
                    list = nil;
                };
                [fn drawLineWithSuperView:_tradeViewOne
                                    Color:FMBottomLineColor
                                    Frame:CGRectMake(5, _tradeViewOne.frame.size.height-0.5, _tradeViewOne.frame.size.width-10, 0.5)];
                _tradeViewTwo = [[TopThreeView alloc] initWithFrame:CGRectMake(0, kThreeViewTradeHeight,
                                                                               UIScreenWidth,
                                                                               kThreeViewTradeHeight)];
                // 点击按钮
                _tradeViewTwo.clickTopThreeButtonBlock = ^(TopThreeView *topthree,ThreeButton *button){
                    NSString *typeCode = button.tradeType;
                    NSString *typeName = button.trade.text;
                    FMUpDownListViewController *list = [[FMUpDownListViewController alloc] initWithTypeCode:typeCode typeName:typeName];
                    [__weakSelf.navigationController pushViewController:list animated:YES];
                    list = nil;
                };
                [fn drawLineWithSuperView:_tradeViewTwo Color:FMBottomLineColor Location:1];
                [cell addSubview:_tradeViewOne];
                [cell addSubview:_tradeViewTwo];
                
            }
            
            
            NSDictionary *sectionData = [_datas objectAtIndex:indexPath.section];
            NSArray *subData = [sectionData objectForKey:@"data"];
            if ([[subData class] isSubclassOfClass:[NSArray class]]) {
                NSMutableArray *list = [NSMutableArray arrayWithArray:subData];
                if (list.count>=3) {
                    [_tradeViewOne updateViewsWithDatas:[list subarrayWithRange:NSMakeRange(0, 3)]];
                }
                if (list.count>=6) {
                    [_tradeViewTwo updateViewsWithDatas:[list subarrayWithRange:NSMakeRange(3, 3)]];
                }
                list = nil;
            }
            subData = nil;
            sectionData = nil;
            
        }
        if (indexPath.section==1) {
            if (!_gainianViewOne) {
                _gainianViewOne = [[TopThreeView alloc] initWithFrame:CGRectMake(0, 0,
                                                                                 UIScreenWidth,
                                                                                 kThreeViewTradeHeight)];
                //[fn drawLineWithSuperView:_gainianViewOne Color:FMBottomLineColor Location:1];
                // 点击按钮
                _gainianViewOne.clickTopThreeButtonBlock = ^(TopThreeView *topthree,ThreeButton *button){
                    NSString *typeCode = button.tradeType;
                    NSString *typeName = button.trade.text;
                    FMUpDownListViewController *list = [[FMUpDownListViewController alloc] initWithTypeCode:typeCode typeName:typeName];
                    [__weakSelf.navigationController pushViewController:list animated:YES];
                    list = nil;
                };
                [fn drawLineWithSuperView:_gainianViewOne
                                    Color:FMBottomLineColor
                                    Frame:CGRectMake(5, _tradeViewOne.frame.size.height-0.5, _tradeViewOne.frame.size.width-10, 0.5)];
                _gainianViewTwo = [[TopThreeView alloc] initWithFrame:CGRectMake(0, kThreeViewTradeHeight,
                                                                                 UIScreenWidth,
                                                                                 kThreeViewTradeHeight)];
                // 点击按钮
                _gainianViewTwo.clickTopThreeButtonBlock = ^(TopThreeView *topthree,ThreeButton *button){
                    NSString *typeCode = button.tradeType;
                    NSString *typeName = button.trade.text;
                    FMUpDownListViewController *list = [[FMUpDownListViewController alloc] initWithTypeCode:typeCode typeName:typeName];
                    [__weakSelf.navigationController pushViewController:list animated:YES];
                    list = nil;
                };
                [fn drawLineWithSuperView:_gainianViewTwo Color:FMBottomLineColor Location:1];
                [cell addSubview:_gainianViewOne];
                [cell addSubview:_gainianViewTwo];
                
            }
            
            
            NSDictionary *sectionData = [_datas objectAtIndex:indexPath.section];
            NSArray *subData = [sectionData objectForKey:@"data"];
            if ([[subData class] isSubclassOfClass:[NSArray class]]) {
                NSMutableArray *list = [NSMutableArray arrayWithArray:subData];
                if (list.count>=3) {
                    [_gainianViewOne updateViewsWithDatas:[list subarrayWithRange:NSMakeRange(0, 3)]];
                }
                if (list.count>=6) {
                    [_gainianViewTwo updateViewsWithDatas:[list subarrayWithRange:NSMakeRange(3, 3)]];
                }
                list = nil;
            }
            subData = nil;
            sectionData = nil;
            
        }
        
        if (indexPath.section==2) {
            if (!_diyuViewOne) {
                _diyuViewOne = [[TopThreeView alloc] initWithFrame:CGRectMake(0, 0,
                                                                              UIScreenWidth,
                                                                              kThreeViewTradeHeight)];
                //[fn drawLineWithSuperView:_gainianViewOne Color:FMBottomLineColor Location:1];
                // 点击按钮
                _diyuViewOne.clickTopThreeButtonBlock = ^(TopThreeView *topthree,ThreeButton *button){
                    NSString *typeCode = button.tradeType;
                    NSString *typeName = button.trade.text;
                    FMUpDownListViewController *list = [[FMUpDownListViewController alloc] initWithTypeCode:typeCode typeName:typeName];
                    [__weakSelf.navigationController pushViewController:list animated:YES];
                    list = nil;
                };
                [fn drawLineWithSuperView:_diyuViewOne
                                    Color:FMBottomLineColor
                                    Frame:CGRectMake(5, _diyuViewOne.frame.size.height-0.5, _diyuViewOne.frame.size.width-10, 0.5)];
                _diyuViewTwo = [[TopThreeView alloc] initWithFrame:CGRectMake(0, kThreeViewTradeHeight,
                                                                              UIScreenWidth,
                                                                              kThreeViewTradeHeight)];
                // 点击按钮
                _diyuViewTwo.clickTopThreeButtonBlock = ^(TopThreeView *topthree,ThreeButton *button){
                    NSString *typeCode = button.tradeType;
                    NSString *typeName = button.trade.text;
                    FMUpDownListViewController *list = [[FMUpDownListViewController alloc] initWithTypeCode:typeCode typeName:typeName];
                    [__weakSelf.navigationController pushViewController:list animated:YES];
                    list = nil;
                };
                [fn drawLineWithSuperView:_diyuViewTwo Color:FMBottomLineColor Location:1];
                [cell addSubview:_diyuViewOne];
                [cell addSubview:_diyuViewTwo];
                
            }
            
            
            NSDictionary *sectionData = [_datas objectAtIndex:indexPath.section];
            NSArray *subData = [sectionData objectForKey:@"data"];
            if ([[subData class] isSubclassOfClass:[NSArray class]]) {
                NSMutableArray *list = [NSMutableArray arrayWithArray:subData];
                if (list.count>=3) {
                    [_diyuViewOne updateViewsWithDatas:[list subarrayWithRange:NSMakeRange(0, 3)]];
                }
                if (list.count>=6) {
                    [_diyuViewTwo updateViewsWithDatas:[list subarrayWithRange:NSMakeRange(3, 3)]];
                }
                list = nil;
            }
            subData = nil;
            sectionData = nil;
        }
        
    }else {
        NSDictionary *sectionData = [_datas objectAtIndex:indexPath.section];
        NSArray *list = [sectionData objectForKey:@"data"];
        if ([[list class] isSubclassOfClass:[NSArray class]]) {
            NSDictionary *dic = [list objectAtIndex:indexPath.row];
            FMSelfStocksModel *m = [[FMSelfStocksModel alloc] initWithDic:dic];
            [cell setContent:m];
            if (indexPath.row==list.count-1) {
                cell.isLast = YES;
            }else{
                cell.isLast = NO;
            }
            if ([m.changeRate doubleValue]>0) {
                [cell.changeRate setTitleColor:FMRedColor forState:UIControlStateNormal];
            }
            if ([m.changeRate doubleValue]==0) {
                [cell.changeRate setTitleColor:FMGreyColor forState:UIControlStateNormal];
            }
            if ([m.changeRate doubleValue]<0) {
                [cell.changeRate setTitleColor:FMGreenColor forState:UIControlStateNormal];
            }
            if (indexPath.section==_datas.count-1 || indexPath.section==_datas.count-2) {
                // 市值排行  流通市值排行
                NSString *changeRate = [m.changeRate stringByReplacingOccurrencesOfString:@"+" withString:@""];
                [cell.changeRate setTitle:changeRate forState:UIControlStateNormal];
                cell.changeRate.titleLabel.adjustsFontSizeToFitWidth = YES;
                [cell.changeRate setTitleColor:FMZeroColor forState:UIControlStateNormal];
            }
            cell.price.font = kFontNumber(20);
            cell.changeRate.titleLabel.font = kFontNumber(20);
            m = nil;
            dic = nil;
            list = nil;
        }
        
        sectionData = nil;
        
        [cell.changeRate setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]
                                                            andSize:cell.changeRate.frame.size] forState:UIControlStateNormal];
        cell.signal.hidden = YES;
    }
    
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *sectionData = [_datas objectAtIndex:indexPath.section];
    NSArray *list = [sectionData objectForKey:@"data"];
    NSDictionary *dic = [list objectAtIndex:indexPath.row];
    FMSelfStocksModel *m = [[FMSelfStocksModel alloc] initWithDic:dic];
    
    FMKLineChartViewController *kline = [[FMKLineChartViewController alloc] initWithStockCode:m.code StockName:m.name Price:m.price ClosePrice:m.closePrice Type:m.type];
    [self.navigationController pushViewController:kline animated:YES];
    kline = nil;
    
    m = nil;
    dic = nil;
    list = nil;
    sectionData = nil;
    
}



#pragma mark -
#pragma mark Http Request
// 请求指数列表
// loop=NO 就是自动请求
-(void)getHttpStockIndexList:(BOOL)loop{
    WEAKSELF
    // 如果服务器收盘了，就不自动请求了,手动请求除外
    if ([FMUserDefault marketIsClose] && !loop) {
        [_tableView.header endRefreshing];
        [self stopRefresh];
        return;
    }
    if (_isRefreshing) {
//        [_tableView.header endRefreshing];
        [self stopRefresh];
        return;
    }
    [http getStockIndexListWithStart:^{
        __weakSelf.isRefreshing = YES;
        [__weakSelf startRefresh];
    } failure:^{
        [__weakSelf stopRefresh];
        [__weakSelf.tableView.header endRefreshing];
        __weakSelf.isRefreshing = NO;
    } success:^(NSDictionary* dic){
        
        if (dic) {
            NSArray *data = [dic objectForKey:@"data"];
            [__weakSelf.threeView updateViewsWithDatas:data];
            // 设置缓存
            [[EGOCache globalCache] setString:[data JSONRepresentation] forKey:cacheForTopThreeDataKey];
            
            data = nil;
            // 接下来请求个股涨跌幅
            [__weakSelf getHttpUpDownList:loop];
        }else{
            [__weakSelf stopRefresh];
            __weakSelf.isRefreshing = NO;
            [__weakSelf.tableView.header endRefreshing];
        }
        
    }];
}

// 请求个股涨跌幅
-(void)getHttpUpDownList:(BOOL)loop{
    // 如果服务器收盘了，就不自动请求了,手动请求除外
    //    if ([FMUserDefault marketIsClose] && !loop) {
    //        _isRefreshing = NO;
    //        [self stopRefresh];
    //        [self performSelector:@selector(loopRequest) withObject:nil afterDelay:10];
    //        return;
    //    }
    WEAKSELF
    [http getUpDownListWithStart:0 count:10 typeCode:nil start:^{
        
    } failure:^{
        [__weakSelf stopRefresh];
        [__weakSelf.tableView.header endRefreshing];
        __weakSelf.isRefreshing = NO;
    } success:^(NSDictionary*dic){
        [__weakSelf stopRefresh];
        [__weakSelf.tableView.header endRefreshing];
        if (dic) {
            //[_datas removeAllObjects];
            __weakSelf.datas = [dic objectForKey:@"data"];
            if ([[__weakSelf.datas class] isSubclassOfClass:[NSArray class]]) {
                if (__weakSelf.datas.count>0) {
                    [[EGOCache globalCache] setString:[_datas JSONRepresentation] forKey:marketUpDownListCacheKey];
                    [__weakSelf.tableView reloadData];
                }
                
            }
            if ([__weakSelf.datas isEqual:[NSNull null]]) {
                __weakSelf.datas = nil;
            }
            
        }
        __weakSelf.isRefreshing = NO;
    }];
}

//-(void)loopRequest{
//    if (!_isout) {
//        if ([FMUserDefault getSelfStockLoopTime]<=0) {
//            return;
//        }
//        [self performSelector:@selector(getHttpStockIndexList:) withObject:nil afterDelay:[FMUserDefault getSelfStockLoopTime]];
//    }
//}

-(void)timerAction{
    [self getHttpStockIndexList:NO];
}


-(void)addMJHeader{
    WEAKSELF
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [__weakSelf getHttpStockIndexList:YES];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    _tableView.header = header;
    [_tableView.header beginRefreshing];
}
@end
