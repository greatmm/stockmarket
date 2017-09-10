//
//  FMEditStocksViewController.m
//  FMMarket
//
//  Created by dangfm on 15/10/2.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMEditStocksViewController.h"
#import "FMTableView.h"
#import "FMKLineChartTabBar.h"
#import "FMEditStocksTableViewCell.h"
#import "FMEditStocksToolBar.h"
#import "FMRemindViewController.h"
#import "FMBackgroundRun.h"

@interface FMEditStocksViewController()
<UITableViewDataSource,UITableViewDelegate>
{
    
}
@property (nonatomic,retain) FMTableView *tableView;
@property (nonatomic,retain) FMKLineChartTabBar *chartTabBar;
@property (nonatomic,retain) FMEditStocksToolBar *toolBar;
@property (nonatomic,retain) NSMutableArray *selectDatas;
@end

@implementation FMEditStocksViewController

-(void)dealloc{
    NSLog(@"FMEditStocksViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initParams];
    [self createViews];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden =  YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Init

-(instancetype)initWithDatas:(NSMutableArray *)datas{
    if (self==[super init]) {
        _datas = nil;
        _datas = [NSMutableArray arrayWithArray:datas];
    }
    return self;
}

-(void)initParams{
    [self setTitle:@"编辑自选" IsBack:YES ReturnType:2];
    _selectDatas = [NSMutableArray new];
}
-(void)loadDatas{
    NSString *where = nil;
    if ([[FMUserDefault getUserId]floatValue]>0) {
        where = [NSString stringWithFormat:@" userId='%@'",[FMUserDefault getUserId]];
    }
    NSArray *rs = [db select:[FMSelfStocksModel class] Where:where Order:@" abs(orderValue) desc" Limit:nil];
    [_datas removeAllObjects];
    if (rs.count>0) {
        _datas = [NSMutableArray arrayWithArray:rs];
    }
    rs = nil;
}

#pragma mark -
#pragma mark UI Create

-(void)createViews{
    [self createTableViews];
    [self createChartTabBar];
    [self createBottomToolBar];
    [self createFinishButtonView];
}

-(void)createFinishButtonView{
    self.header.backButton.hidden = YES;
    UIButton *finish = [[UIButton alloc] initWithFrame:CGRectMake(UIScreenWidth-60, 0, 60, kNavigationHeight)];
    [finish setTitle:@"保存" forState:UIControlStateNormal];
    [finish setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    finish.titleLabel.font = kFont(16);
    [self.header addSubview:finish];
    [finish addTarget:self
               action:@selector(saveAllDatas)
     forControlEvents:UIControlEventTouchUpInside];
    finish = nil;
    
    UIButton *cannel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, kNavigationHeight)];
    [cannel setTitle:@"取消" forState:UIControlStateNormal];
    [cannel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cannel.titleLabel.font = kFont(16);
    [self.header addSubview:cannel];
    [cannel addTarget:self
               action:@selector(returnBack)
     forControlEvents:UIControlEventTouchUpInside];
    cannel = nil;
}

-(void)createTableViews{

    if (!_tableView) {
        CGRect frame = CGRectMake(0, self.point.y+kFMKLineChartTabBarHeight, UIScreenWidth,
                                  UIScreenHeight-kFMEditStocksToolBarHeight-(self.point.y+kFMKLineChartTabBarHeight)-5);
        _tableView = [[FMTableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView setEditing:YES];
        _tableView.bounces = NO;
        [self.view addSubview:_tableView];
    }

}

//  列表分类导航
-(void)createChartTabBar{
    if (!_chartTabBar) {
        _chartTabBar = [[FMKLineChartTabBar alloc]
                        initWithFrame:CGRectMake(0, self.point.y, UIScreenWidth, kFMKLineChartTabBarHeight)
                        Titles:@[@"全部",@"",@"提醒",@"置顶",@"拖动"]
                        IsMove:NO showCounts:5];
        [self.view addSubview:_chartTabBar];
    }
}

//  底部工具栏
-(void)createBottomToolBar{
    if (!_toolBar) {
        _toolBar = [[FMEditStocksToolBar alloc] initWithFrame:CGRectMake(0, UIScreenHeight-kFMEditStocksToolBarHeight, UIScreenWidth, kFMEditStocksToolBarHeight)];
        [self.view addSubview:_toolBar];
        // 点击全选
        __weak typeof(self) weakSelf = self;
        _toolBar.clickSelectButtonBlock = ^(int type){
            if (type==1) {
                // 全选
                [weakSelf selectAllActioin];
            }else{
                // 反选
                [weakSelf unSelectAllAction];
            }
        };
        // 删除
        _toolBar.clickDeleteButtonBlock = ^{
            [weakSelf deleteSelectedAction];
        };
    }
}

#pragma mark -
#pragma mark UI Action
//  全选
-(void)selectAllActioin{
    for (FMSelfStocksModel *m in _datas) {
        if ([_selectDatas indexOfObject:m.code]==NSNotFound) {
            [_selectDatas addObject:m.code];
        }
    }
    [_toolBar updateViewsWithSelectedCount:(int)_selectDatas.count];
    [_tableView reloadData];
}
//  反选
-(void)unSelectAllAction{
    [_selectDatas removeAllObjects];
    [_toolBar updateViewsWithSelectedCount:(int)_selectDatas.count];
    [_tableView reloadData];
}

//  删除所选
-(void)deleteSelectedAction{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        for (NSString *code in _selectDatas) {
            NSString *where = [NSString stringWithFormat:@"code='%@'",code];
            if ([[FMUserDefault getUserId]floatValue]>0) {
                where = [NSString stringWithFormat:@"code='%@' and userId='%@'",code,[FMUserDefault getUserId]];
            }
            [db delete:[FMSelfStocksModel class] Where:where];
            where = nil;
        }
        [self loadDatas];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self unSelectAllAction];
        });
    });
}

-(void)saveAllDatas{
    if (_datas.count<=0) {
        [SVProgressHUD dismiss];
        [self returnBack];
        return;
    }
    [SVProgressHUD show];
    WEAKSELF
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        int j = 0;
        for (int i=((int)_datas.count-1);i>=0;i--) {
            FMSelfStocksModel *m = _datas[i];
            m.orderValue = [NSString stringWithFormat:@"%d",j];
            [db update:m
                 Where:[NSString stringWithFormat:@"code='%@'",m.code]
           FinishBlock:^(bool success){
               if ([m isEqual:[_datas firstObject]]) {
                   dispatch_async(dispatch_get_main_queue(), ^{
                       // 批量更新同步远程数据库
                       [[FMBackgroundRun instance] uploadMySelfStocksWithBlock:nil];
                       [SVProgressHUD dismiss];
                       [__weakSelf returnBack];
                   });
               }
            }];
            j ++;
        }
        
    });
    
}


#pragma mark -
#pragma mark UITableViewDelegate

//打开编辑模式后，默认情况下每行左边会出现红的删除按钮，这个方法就是关闭这些按钮的
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

//这个方法用来告诉表格 这一行是否可以移动
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

//这个方法就是执行移动操作的
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)
sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSUInteger fromRow = [sourceIndexPath row];
    //NSInteger fromSection = [sourceIndexPath section];
    NSUInteger toRow = [destinationIndexPath row];
    //NSUInteger toSection = [destinationIndexPath section];
    id fromObj = [_datas objectAtIndex:fromRow];
    [_datas removeObjectAtIndex:fromRow];
    // 移动数据
    if (fromRow>toRow) {
        // 向前移动
        [_datas insertObject:fromObj atIndex:toRow];
    }else{
        // 向后移动
        int insertRow = (int)toRow;
        if (insertRow>=_datas.count-1) {
            [_datas addObject:fromObj];
        }else{
            [_datas insertObject:fromObj atIndex:insertRow];
        }
    }
    
    [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:1];
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kTableViewCellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _datas.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIndentifier = [NSString stringWithFormat:@"cell_%d",(int)indexPath.row];
    FMEditStocksTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[FMEditStocksTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:cellIndentifier];
        WEAKSELF
        cell.clickMoveUpButtonBlock = ^(FMEditStocksTableViewCell*myself){
            [tableView moveRowAtIndexPath:indexPath toIndexPath:0];
            id obj = [_datas objectAtIndex:indexPath.row];
            [_datas removeObjectAtIndex:indexPath.row];
            [_datas insertObject:obj atIndex:0];
            [tableView performSelector:@selector(reloadData) withObject:nil afterDelay:1];
        };
        cell.clickMySelfToSelectBlock = ^(FMEditStocksTableViewCell*myself){
            // 选择
            FMSelfStocksModel *m = [_datas objectAtIndex:indexPath.row];
            if ([_selectDatas indexOfObject:m.code]==NSNotFound) {
                [_selectDatas addObject:m.code];
            }else{
                [_selectDatas removeObject:m.code];
            }
            m = nil;
            [myself updateSelectView:_selectDatas];
            [_toolBar updateViewsWithSelectedCount:(int)_selectDatas.count];
        };
        // 提醒
        cell.clickMySelfToRemindBlock = ^(FMEditStocksTableViewCell*myself){
            if ([[FMUserDefault getUserId]floatValue]>0) {
                FMRemindViewController *remind = [[FMRemindViewController alloc] initWithCode:myself.model.code name:myself.title.text];
                [__weakSelf.navigationController pushViewController:remind animated:YES];
                remind = nil;
            }else{
                [fn showMessage:@"提醒功能需要登录" Title:@"温馨提示" timeout:2];
            }
            
        };
    }
    
    [cell setContent:[_datas objectAtIndex:indexPath.row]];
    [cell updateSelectView:_selectDatas];
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

@end
