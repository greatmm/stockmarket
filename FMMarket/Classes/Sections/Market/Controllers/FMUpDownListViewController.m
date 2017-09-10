//
//  FMUpDownListViewController.m
//  FMMarket
//
//  Created by dangfm on 15/11/20.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMUpDownListViewController.h"
#import "FMTableView.h"
#import "FMSelfStockTableViewCell.h"
#import "TopThreeView.h"
#import "FMMarketTableSection.h"
#import "FMKLineChartViewController.h"
#import "FMKLineChartTabBar.h"

static int defaultPageSize = 20;

@interface FMUpDownListViewController()
<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    
}
@property (nonatomic,retain) NSMutableArray *datas;
@property (nonatomic,retain) FMTableView *tableView;
@property (nonatomic,retain) FMKLineChartTabBar *listTitleBar;
@property (nonatomic,assign) BOOL isout;
@property (nonatomic,assign) BOOL isRefreshing;
@property (nonatomic,assign) int page;
@property (nonatomic,assign) int pageSize;

@end
@implementation FMUpDownListViewController

-(void)dealloc{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    NSLog(@"FMUpDownListViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initParams];
    [self createTableView];
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.tabBarController.tabBar.hidden = YES;
    _isout = NO;
    [self getHttpUpDownList:YES page:_page pageSize:_pageSize];
    [self runTimer:[FMUserDefault getSelfStockLoopTime]];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
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
    _page = 0;
    _pageSize = defaultPageSize;
    [self setTitle:_typeName IsBack:YES ReturnType:1];
}

-(instancetype)initWithTypeCode:(NSString*)typeCode typeName:(NSString*)typeName{
    if (self==[super init]) {
        _typeCode = typeCode;
        _typeName = typeName;
    }
    return self;
}

#pragma mark -
#pragma mark UI Create
-(void)createViews{
    [self createTableView];
}

//  Create TableView
-(void)createTableView{
    if (!_tableView) {
        _tableView = [[FMTableView alloc] initWithFrame:CGRectMake(0, self.point.y, UIScreenWidth, UIScreenHeight-self.point.y) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = FMBgGreyColor;
        [self.view addSubview:_tableView];
        [self addMJHeader];
        
    }
}


#pragma mark -
#pragma mark UI Action



#pragma mark -
#pragma mark UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return kTableViewCellHeight;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return kFMMarketTableSectionHeight;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    int count = (int)_datas.count;
    return count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (!_listTitleBar) {
        NSArray *titles = @[@"名称",@"",@"最新价",@"涨跌幅"];
        if ([_typeCode isEqualToString:@"totalValue"]) {
            titles = @[@"名称",@"",@"最新价",@"总市值"];
        }
        if ([_typeCode isEqualToString:@"circulationValue"]) {
            titles = @[@"名称",@"",@"最新价",@"流通市值"];
        }
        if ([_typeCode isEqualToString:@"swing"]) {
            titles = @[@"名称",@"",@"最新价",@"振幅"];
        }
        if ([_typeCode isEqualToString:@"turnover"]) {
            titles = @[@"名称",@"",@"最新价",@"换手率"];
        }
        _listTitleBar = [[FMKLineChartTabBar alloc]
                         initWithFrame:CGRectMake(0, 0, UIScreenWidth, kFMKLineChartTabBarHeight)
                         Titles:titles
                         IsMove:NO showCounts:4];
        
    }
    return _listTitleBar;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIndentifier = @"cell";//[NSString stringWithFormat:@"cell_%d_%d",(int)indexPath.section,(int)indexPath.row];
    FMSelfStockTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[FMSelfStockTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:cellIndentifier];
        cell.typeIcon.hidden = YES;
        cell.code.frame = CGRectMake(cell.typeIcon.frame.origin.x, cell.code.frame.origin.y, cell.code.frame.size.width, cell.code.frame.size.height);
        
    }
    if (indexPath.row<_datas.count) {
        NSDictionary *dic = [_datas objectAtIndex:indexPath.row];
        FMSelfStocksModel *m = [[FMSelfStocksModel alloc] initWithDic:dic];
        [cell setContent:m];
        if (indexPath.row==_datas.count-1) {
            cell.isLast = YES;
        }else{
            cell.isLast = NO;
        }
        if ([m.changeRate doubleValue]>0) {
            [cell.changeRate setTitleColor:FMRedColor forState:UIControlStateNormal];
        }
        
        if ([m.changeRate doubleValue]<0) {
            [cell.changeRate setTitleColor:FMGreenColor forState:UIControlStateNormal];
        }
        if ([m.changeRate doubleValue]==0 || [m.changeRate floatValue]<-20) {
            [cell.changeRate setTitleColor:FMGreyColor forState:UIControlStateNormal];
        }
        if ([_typeCode isEqualToString:@"totalValue"] || [_typeCode isEqualToString:@"circulationValue"]) {
            // 市值排行  流通市值排行
            NSString *changeRate = [m.changeRate stringByReplacingOccurrencesOfString:@"+" withString:@""];
            changeRate = [changeRate stringByAppendingString:@"亿"];
            [cell.changeRate setTitle:changeRate forState:UIControlStateNormal];
            cell.changeRate.titleLabel.adjustsFontSizeToFitWidth = YES;
            [cell.changeRate setTitleColor:FMZeroColor forState:UIControlStateNormal];
        }
        cell.price.font = kFontNumber(20);
        cell.changeRate.titleLabel.font = kFontNumber(20);
        m = nil;
        dic = nil;
        
        [cell.changeRate setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]
                                                            andSize:cell.changeRate.frame.size] forState:UIControlStateNormal];
        cell.signal.hidden = YES;
    }
    
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    NSDictionary *dic = [_datas objectAtIndex:indexPath.row];
    FMSelfStocksModel *m = [[FMSelfStocksModel alloc] initWithDic:dic];
    
    FMKLineChartViewController *kline = [[FMKLineChartViewController alloc] initWithStockCode:m.code StockName:m.name Price:m.price ClosePrice:m.closePrice Type:m.type];
    [self.navigationController pushViewController:kline animated:YES];
    kline = nil;
    
    m = nil;
    dic = nil;
 
}



#pragma mark -
#pragma mark Http Request

// 请求个股涨跌幅
-(void)getHttpUpDownList:(BOOL)loop page:(int)page pageSize:(int)pageSize{
    if ([FMUserDefault marketIsClose] && !loop) {
        return;
    }
    if (_isRefreshing) {
        return;
    }
    WEAKSELF
    [http getUpDownListWithStart:page count:pageSize typeCode:_typeCode start:^{
        __weakSelf.isRefreshing = YES;
    } failure:^{
        [_tableView.header endRefreshing];
        [_tableView.footer endRefreshing];
        __weakSelf.isRefreshing = NO;
        __weakSelf.page --;
      
    } success:^(NSDictionary*dic){
        [_tableView.header endRefreshing];
        [_tableView.footer endRefreshing];
        if (page<=0) {
            [__weakSelf.datas removeAllObjects];
        }
        if (dic) {
            //[_datas removeAllObjects];
            NSArray *data = [dic objectForKey:@"data"];
            if ([[data class] isSubclassOfClass:[NSArray class]]) {
                [__weakSelf.datas addObjectsFromArray:data];
                [_tableView reloadData];
            }
            data = nil;
        }
        __weakSelf.isRefreshing = NO;
 
        
    }];
}


-(void)timerAction{
    // 每次更新整个页面所有股票
    int pageSize = defaultPageSize * (_page+1);
    [self getHttpUpDownList:NO page:0 pageSize:pageSize];
}


-(void)addMJHeader{
    WEAKSELF
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        __weakSelf.page = 0;
        [__weakSelf getHttpUpDownList:YES page:_page pageSize:_pageSize];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    _tableView.header = header;
    [_tableView.header beginRefreshing];
    [self addMJFooter];
}
-(void)addMJFooter{
    WEAKSELF
    _tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        __weakSelf.page ++;
        
        [__weakSelf getHttpUpDownList:YES page:_page pageSize:_pageSize];
    }];
    _tableView.footer.hidden = YES;
}
@end
