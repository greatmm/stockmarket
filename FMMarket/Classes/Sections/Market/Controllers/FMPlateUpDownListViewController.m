//
//  FMPlateUpDownListViewController.m
//  FMMarket
//
//  Created by dangfm on 16/5/10.
//  Copyright © 2016年 dangfm. All rights reserved.
//

#import "FMPlateUpDownListViewController.h"
#import "FMTableView.h"
#import "FMSelfStockTableViewCell.h"
#import "TopThreeView.h"
#import "FMMarketTableSection.h"
#import "FMKLineChartViewController.h"
#import "FMKLineChartTabBar.h"
#import "FMUpDownListViewController.h"

@interface FMPlateUpDownListViewController ()
<UITableViewDataSource,UITableViewDelegate>
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

@implementation FMPlateUpDownListViewController

-(void)dealloc{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    NSLog(@"FMPlateUpDownListViewController dealloc");
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
    [self getHttpUpDownList:YES];
    [self runTimer:[FMUserDefault getSelfStockLoopTime]];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
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
    _pageSize = 300;
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

-(void)returnBack{
    _listTitleBar.clickChartTabBarButtonHandle = nil;
    _listTitleBar.delegate = nil;
    _listTitleBar = nil;
    _datas = nil;
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
    _tableView = nil;
    [super returnBack];
}

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
        NSArray *titles = @[@"行业名称",@"",@"涨跌幅",@"领涨股"];
        if ([_typeCode isEqualToString:@"gainian"]) {
            titles = @[@"概念名称",@"",@"涨跌幅",@"领涨股"];
        }
        if ([_typeCode isEqualToString:@"diyu"]) {
            titles = @[@"地区名称",@"",@"涨跌幅",@"领涨股"];
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
        cell.code.hidden = YES;
    }
    if (indexPath.row<_datas.count) {
        NSDictionary *dic = [_datas objectAtIndex:indexPath.row];
        dic = [fn checkNullWithDictionary:dic];
        FMSelfStocksModel *m = [[FMSelfStocksModel alloc] initWithDic:dic];
        m.name = dic[@"title"];
        [cell setContent:m];
        cell.price.text = [NSString stringWithFormat:@"%.2f%%",[dic[@"rate"] floatValue]];
        [cell.changeRate setTitle:dic[@"name"] forState:UIControlStateNormal];
        
        if (indexPath.row==_datas.count-1) {
            cell.isLast = YES;
        }else{
            cell.isLast = NO;
        }
        if ([cell.price.text doubleValue]>0) {
            cell.price.textColor = FMRedColor;
        }
        if ([cell.price.text doubleValue]==0) {
            cell.price.textColor = FMGreyColor;
        }
        if ([cell.price.text doubleValue]<0) {
            cell.price.textColor = FMGreenColor;
        }
        
        cell.price.font = kFontNumber(20);
        cell.changeRate.titleLabel.font = cell.title.font;
        [cell.changeRate setTitleColor:FMZeroColor forState:UIControlStateNormal];
        m = nil;
        dic = nil;
        
        [cell.changeRate setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]
                                                            andSize:cell.changeRate.frame.size] forState:UIControlStateNormal];
        cell.title.frame = CGRectMake(cell.title.mj_x, 0, cell.title.mj_w, kTableViewCellHeight);
        cell.signal.hidden = YES;
    }
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSDictionary *dic = [_datas objectAtIndex:indexPath.row];
    dic = [fn checkNullWithDictionary:dic];
    NSString *typeCode = dic[@"id"];
    NSString *typeName = dic[@"title"];
    FMUpDownListViewController *list = [[FMUpDownListViewController alloc] initWithTypeCode:typeCode typeName:typeName];
    [self.navigationController pushViewController:list animated:YES];
    list = nil;
    dic = nil;
    
}



#pragma mark -
#pragma mark Http Request

// 请求个股涨跌幅
-(void)getHttpUpDownList:(BOOL)loop{
    if ([FMUserDefault marketIsClose] && !loop) {
        return;
    }
    if (_isRefreshing) {
        return;
    }
    WEAKSELF
    [http getPlateUpDownListWithStart:_page count:_pageSize typeCode:_typeCode start:^{
        __weakSelf.isRefreshing = YES;
    } failure:^{
        [_tableView.header endRefreshing];
        [_tableView.footer endRefreshing];
        __weakSelf.isRefreshing = NO;
        __weakSelf.page --;
    } success:^(NSDictionary*dic){
        [__weakSelf.tableView.header endRefreshing];
        [__weakSelf.tableView.footer endRefreshing];
        if (__weakSelf.page<=0) {
            [__weakSelf.datas removeAllObjects];
        }
        if (dic) {
            //[_datas removeAllObjects];
            NSArray *data = [dic objectForKey:@"data"];
            if ([[data class] isSubclassOfClass:[NSArray class]]) {
                [__weakSelf.datas addObjectsFromArray:data];
                [__weakSelf.tableView reloadData];
            }
            data = nil;
        }
        __weakSelf.isRefreshing = NO;
    }];
}

-(void)timerAction{
    [self getHttpUpDownList:NO];
}


-(void)addMJHeader{
    WEAKSELF
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        __weakSelf.page = 0;
        [__weakSelf getHttpUpDownList:YES];
    }];
    header.lastUpdatedTimeLabel.hidden = YES;
    _tableView.header = header;
    [_tableView.header beginRefreshing];
    //[self addMJFooter];
}
//-(void)addMJFooter{
//    WEAKSELF
//    _tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
//        //_page ++;
//        
//        //[__weakSelf getHttpUpDownList];
//    }];
//    _tableView.footer.hidden = YES;
//}

@end
