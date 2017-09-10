//
//  FMRefreshTimeViewController.m
//  FMMarket
//
//  Created by dangfm on 15/10/3.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMRefreshTimeViewController.h"
#import "FMTableView.h"
#import "FMTableViewCell.h"
#import "FMSectionHeaderView.h"
#import "UILabel+stocking.h"



@interface FMRefreshTimeViewController ()
<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    NSMutableArray *_datas;
    FMTableView *_tableView;
    FMSectionHeaderView *_sectionHeaderView;
}
@end

@implementation FMRefreshTimeViewController

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

#pragma mark -
#pragma mark Init
-(void)initParams{
    _datas = [NSMutableArray arrayWithArray:(NSArray*)ThemeJson(@"marketRefresh")];
    [self setTitle:@"行情刷新频率" IsBack:YES ReturnType:1];
}

#pragma mark -
#pragma mark UI Create
-(void)createViews{
    [self createTableView];
}

//  Create TableView
-(void)createTableView{
    self.view.backgroundColor = FMBgGreyColor;
    if (!_tableView) {
        _tableView = [[FMTableView alloc] initWithFrame:CGRectMake(0, self.point.y, UIScreenWidth, UIScreenHeight-self.point.y-kNavigationHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = FMBgGreyColor;
        [self.view addSubview:_tableView];
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
    
    return kFMTableViewSectionOtherHeight;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _datas.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_datas[section] count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    _sectionHeaderView = [[FMSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, kFMTableViewSectionOtherHeight)];
    _sectionHeaderView.backgroundColor = [UIColor clearColor];
    _sectionHeaderView.section = section;
    _sectionHeaderView.tableView = tableView;
    UILabel *l = [UILabel createWithTitle:@"2G/3G/4G" Frame:CGRectMake(15, 0, UIScreenWidth, kFMTableViewSectionOtherHeight)];
    if (section==1) {
        l.text = @"Wi-Fi";
    }
    [_sectionHeaderView addSubview:l];
    l = nil;
    [fn drawLineWithSuperView:_sectionHeaderView Color:FMBottomLineColor Location:1];
    return _sectionHeaderView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = (NSDictionary*)_datas[indexPath.section][indexPath.row];
    NSString *cellIndentifier = [NSString stringWithFormat:@"cell_%d_%d",(int)indexPath.section,(int)indexPath.row];
    FMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[FMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIndentifier];
        cell.intro.textColor = FMGreyColor;
        cell.leftImageWidth = 15;
        cell.title.font = kDefaultFont;
        cell.arrow.image = ThemeImage(@"global/icon_right_normal");
        cell.arrow.frame = CGRectMake(UIScreenWidth-15-cell.arrow.image.size.width, (kTableViewCellHeight-cell.arrow.image.size.height)/2, cell.arrow.image.size.width, cell.arrow.image.size.height);
    }
    
    cell.title.text = [dic objectForKey:@"title"];
    cell.arrow.hidden = YES;
    NSString *value = [dic objectForKey:@"value"];
    if ([value isEqualToString:[FMUserDefault getSeting:kUserDefault_SelfStocksHttpLoopTime_NG]] && indexPath.section==0) {
        cell.arrow.hidden = NO;
    }
    if ([value isEqualToString:[FMUserDefault getSeting:kUserDefault_SelfStocksHttpLoopTime_WiFi]] && indexPath.section==1) {
        cell.arrow.hidden = NO;
    }
    if (indexPath.row>=([_datas[indexPath.section] count]-1)) {
        cell.isLast = YES;
    }

    dic = nil;
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *dic = (NSDictionary*)_datas[indexPath.section][indexPath.row];
    NSString *value = [dic objectForKey:@"value"];
    if (indexPath.section==0) {
        // 设置2G/3G/4G
        [FMUserDefault setSeting:kUserDefault_SelfStocksHttpLoopTime_NG Value:value];
    }
    if (indexPath.section==1) {
        // 设置WiFi
        [FMUserDefault setSeting:kUserDefault_SelfStocksHttpLoopTime_WiFi Value:value];
    }
    [_tableView reloadData];
    dic = nil;
}


@end
