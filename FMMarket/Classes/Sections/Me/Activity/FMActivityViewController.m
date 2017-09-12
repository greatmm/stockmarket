//
//  FMActivityViewController.m
//  FMMarket
//
//  Created by dangfm on 16/5/22.
//  Copyright © 2016年 dangfm. All rights reserved.
//

#import "FMActivityViewController.h"
#import "FMActivityCell.h"
#import "FMTableView.h"
#import "FMWebViewController.h"

@interface FMActivityViewController ()
<UITableViewDataSource,UITableViewDelegate>
{
    
}
@property(nonatomic,retain) FMTableView *tableView;
@property(nonatomic,retain) NSMutableArray *datas;
@property(nonatomic,assign) int page;
@property(nonatomic,assign) int pageSize;
@end

@implementation FMActivityViewController

-(void)dealloc{
    NSLog(@"FMActivityViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initParams];
    [self createTableView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Create

-(void)initParams{
    _page = 1;
    _pageSize = 20;
    [self setTitle:@"最新活动" IsBack:YES ReturnType:1];
}

-(void)createTableView{
    if (!_tableView) {
        _tableView = [[FMTableView alloc] initWithFrame:CGRectMake(0, self.point.y, self.view.frame.size.width, self.view.frame.size.height-self.point.y) style:UITableViewStylePlain];
        [self.view addSubview:_tableView];
        _tableView.backgroundColor = FMBgGreyColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _datas = [NSMutableArray new];
        [self addMJHeader];
    }
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kNewActivityTableViewCellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _datas.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    FMActivityCell *cell = (FMActivityCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell==nil) {
        cell = [[FMActivityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (indexPath.row<_datas.count) {
        [cell setContentWithModel:[_datas objectAtIndex:indexPath.row]];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row<_datas.count) {
        FMActivityModel * m = [_datas objectAtIndex:indexPath.row];
        NSString *urlstr = m.url;
        NSString *title = m.title;
        urlstr = [urlstr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:urlstr];
        if (url){
            FMWebViewController *webVC = [[FMWebViewController alloc] initWithTitle:title url:url returnType:1];
            [self.navigationController pushViewController:webVC animated:YES];
            webVC = nil;
        }
        
        title = nil;
        urlstr = nil;
        url = nil;
        m = nil;
    }
}

#pragma mark - Http Request
-(void)getHttpActivityRequest{
    [http getActivityListWithPage:_page pageSize:_pageSize withStart:^{
    
    } failure:^{
        [SVProgressHUD showErrorWithStatus:@"网络不给力"];
        [_tableView.header endRefreshing];
        [_tableView.footer endRefreshing];
    } success:^(NSDictionary*dic){
        [_tableView.header endRefreshing];
        [_tableView.footer endRefreshing];
        NSArray *data = dic[@"data"];
        if (data && [data isKindOfClass:[NSArray class]]) {
            if (_page<=1) {
                [_datas removeAllObjects];
            }
            for (NSDictionary*item in data) {
                FMActivityModel *m = [[FMActivityModel alloc] initWithDic:item];
                [_datas addObject:m];
                m = nil;
            }
            [_tableView reloadData];
        }
    }];
}

#pragma mark -
#pragma mark 添加刷新控件

-(void)addMJHeader{
    WEAKSELF
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        __weakSelf.page = 1;
        [__weakSelf getHttpActivityRequest];
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
        [__weakSelf getHttpActivityRequest];
    }];
    // _tableView.footer.hidden = YES;
}
@end
