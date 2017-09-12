//
//  FMSearchStocksViewController.m
//  FMMarket
//
//  Created by dangfm on 15/8/12.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMSearchStocksViewController.h"
#import "FMSelfStockTableView.h"
#import "FMSearchStocksTableViewCell.h"
#import "FMSelfStocksModel.h"
#import "UITextField+stocking.h"
#import "FMBackgroundRun.h"
#import "FMKLineChartViewController.h"

@interface FMSearchStocksViewController ()
<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    
}
@property (nonatomic,retain) FMTableView *tableView;
@property (nonatomic,retain) NSMutableArray *datas;
@property (nonatomic,retain) UITextField *searchBar;
@property (nonatomic,assign) NSString *keywords;
@property (nonatomic,assign) BOOL isUpdate;
@property (nonatomic,assign) BOOL isSearching;
@end



@implementation FMSearchStocksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initParams];
    [self createViews];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self.view endEditing:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!_isUpdate) {
        [_searchBar becomeFirstResponder];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

-(void)initParams{
    _datas = [NSMutableArray new];
    //[self loadDatas];
    _isUpdate = NO;
//    // 注册数据库更新通知
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startUpdate) name:kFMStartUpdateSearchDatabaseNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endUpdate) name:kFMEndUpdateSearchDatabaseNotification object:nil];
}

-(void)loadDatas{
    NSArray *rs = [db select:[FMSelfStocksModel class] Where:nil Order:@" OrderValue desc" Limit:nil];
    _datas = [NSMutableArray arrayWithArray:rs];
    rs = nil;
}

#pragma mark -
#pragma mark UI Create
-(void)createViews{
    [self setTitle:@"" IsBack:NO ReturnType:2];
    //self.navigationItem.title = @"";
    self.header.frame = CGRectMake(0, self.header.frame.origin.y, UIScreenWidth, kFMSearchHeaderHeight);
    // 添加搜索框
    if (!_searchBar) {
        CGFloat right = 80;
        _searchBar = [UITextField createWithFrame:CGRectMake(15, 15, UIScreenWidth-right-15, 30) PlaceHolder:@"输入股票代码，拼音简称搜索"];
        _searchBar.keyboardType = UIKeyboardTypeWebSearch;
        _searchBar.delegate = self;
        _searchBar.backgroundColor = [UIColor whiteColor];
        [_searchBar addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        self.header.backgroundColor = FMBgGreyColor;
        self.stateView.backgroundColor = FMBgGreyColor;
        self.header.bottomline.frame = CGRectMake(0, self.header.frame.size.height-0.5,
                                                  UIScreenWidth, 0.5);
        self.header.bottomline.backgroundColor = FMGreyColor;
        [self.header addSubview:_searchBar];
        // 取消
        UIButton *back = [[UIButton alloc]
                          initWithFrame:CGRectMake(UIScreenWidth-right, 0, right, kFMSearchHeaderHeight)];
        back.titleLabel.font = kFont(16);
        [back setTitle:@"取消" forState:UIControlStateNormal];
        [back setTitleColor:FMBlueColor forState:UIControlStateNormal];
        [back addTarget:self action:@selector(returnBack) forControlEvents:UIControlEventTouchUpInside];
        [self.header addSubview:back];
    }
    
    if (!_tableView) {
        CGRect frame = CGRectMake(0, self.header.frame.origin.y+self.header.frame.size.height,UIScreenWidth,UIScreenHeight-(self.header.frame.origin.y+self.header.frame.size.height));
        _tableView = [[FMSelfStockTableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
   
}


#pragma mark -
#pragma mark UI Action
//
-(void)clickEditButtonHandle:(UIButton*)bt{
    
}
//  点击搜索按钮
-(void)clickSearchButtonHandle:(UIBarButtonItem*)bt{
    FMSearchStocksViewController *search = [[FMSearchStocksViewController alloc] init];
    [self.navigationController presentViewController:search animated:YES completion:^{}];
    search = nil;
}
//  点击刷新按钮
-(void)clickRefreshButtonHandle:(UIBarButtonItem*)bt{
    
}
//  点击添加按钮
-(void)clickAddButton:(UIButton*)bt{
    if ([[FMUserDefault getUserId]floatValue]<=0) {
        [fn showMessage:@"需要登录哦" Title:@"温馨提示" timeout:1];
        // 我的私信，未登入用户，提示需要用户登入，并直接跳转的登入页面。登入后返到我的私信页面。
        FMLoginViewController *login = [[FMLoginViewController alloc] initWithBackType:2 finishedLoginBlock:^{}];
        [[FMAppDelegate shareApp].main.currnetNav presentViewController:login animated:YES completion:nil];
        return;
    }
    FMSearchStocksTableViewCell *cell = (FMSearchStocksTableViewCell*)bt.superview.superview;
    if (!IOS8) {
        cell = (FMSearchStocksTableViewCell*)bt.superview.superview.superview;
    }
    NSString *code = [NSString stringWithFormat:@"%@%@",cell.typeIcon.text.lowercaseString, cell.code.text];
    
    if (code) {
        FMStocksModel *m = cell.model;
        FMSelfStocksModel *selfm = [[FMSelfStocksModel alloc] init];
        selfm.name = m.name;
        selfm.code = m.code;
        selfm.type = m.type;
        selfm.isStop = m.isStop;
        selfm.userId = [FMUserDefault getUserId];
        selfm.orderValue = [NSString stringWithFormat:@"%d",(int)[db getSum:selfm Filed:@"orderValue" where:nil]+1];
        selfm.signal = @"-1";
        [db insert:selfm  FinishBlock:^(bool issuccess){
            [_tableView reloadData];
        }];
        
        [[FMBackgroundRun instance] uploadAddSingleOneSelfStockWithCode:code
                                                                  block:^(BOOL issuccess){
        
        }];
        
    }
}

#pragma mark -
#pragma mark Notification Action
//  通知处理
-(void)startUpdate{
    if (!_isUpdate) {
        _isUpdate = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view endEditing:YES];
            [SVProgressHUD showWithStatus:@"正在更新数据库,请耐心等候"];
        });
    }
}

-(void)endUpdate{
    _isUpdate = NO;
    dispatch_async_main_safe(^{
        [SVProgressHUD showSuccessWithStatus:@"更新成功"];
    });
    
}

#pragma mark -
#pragma mark UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kTableViewCellHeight;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _datas.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIndentifier = @"cell";
    FMSearchStocksTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[FMSearchStocksTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:cellIndentifier];
        [cell.addButton addTarget:self
                           action:@selector(clickAddButton:)
                 forControlEvents:UIControlEventTouchUpInside];
        
    }
    if (indexPath.row<_datas.count) {
        FMStocksModel *m = [_datas objectAtIndex:indexPath.row];
        [cell setContent:m];
        m = nil;
    }
    

    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    FMStocksModel *m = [_datas objectAtIndex:indexPath.row];
    FMKLineChartViewController *kline = [[FMKLineChartViewController alloc] initWithStockCode:m.code StockName:m.name Price:nil ClosePrice:nil Type:m.type];
    [self.navigationController pushViewController:kline animated:YES];
    kline = nil;
    m = nil;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.view endEditing:YES];
}

#pragma mark -
#pragma mark UITextFiledDelegate


// 值改变就调用
-(void)textFieldChanged:(UITextField *)textField{
    if (![textField.text isEqualToString:@""]) {
        [self searchStocksWithKey:textField.text];
    }
}

-(BOOL)textFieldShouldClear:(UITextField *)textField{
    _keywords = @"";
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    _keywords = textField.text;
    [self searchStocksWithKey:_keywords];
    return YES;
}

#pragma mark -
#pragma mark 搜索本地股票
//  检查是否更新搜索数据
-(void)searchStocksWithKey:(NSString*)keywords{
    
    keywords = [keywords lowercaseString];
    [_datas removeAllObjects];
//    NSArray *rs = [db select:[FMStocksModel class]
//                            Where:[NSString stringWithFormat:@"name like '%%%@%%' or code like '%%%@%%' or pinyin like '%%%@%%'",keywords,keywords,keywords]
//                            Order:@"name asc" Limit:nil];
    //*代表通配符,Like也接受[cd].
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF CONTAINS %@",keywords];
//    NSArray *stocks = [FMAppDelegate shareApp].stocks;
//    NSArray *rs = [stocks filteredArrayUsingPredicate:predicate];
//    _datas = [NSMutableArray arrayWithArray:rs];
//    [_tableView reloadData];
//    rs = nil;
//    predicate = nil;
    
    [http getSearchStocksListWithKey:keywords start:^{
        //[SVProgressHUD show];
    } failure:^{
        [SVProgressHUD dismiss];
        
    } success:^(NSDictionary*dic){
        [_datas removeAllObjects];
        [SVProgressHUD dismiss];
        NSString *data = dic[@"data"];
        if ([[data class]isSubclassOfClass:[NSString class]]) {
            NSArray *list = [data componentsSeparatedByString:@"\n"];
            for (NSString *item in list) {
                NSString *s = [item stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                NSArray *ss = [s componentsSeparatedByString:@"|"];
                if (ss.count>3) {
                    FMStocksModel *m = [[FMStocksModel alloc] init];
                    m.name = ss[2];
                    m.pinyin = ss[1];
                    m.code = ss[0];
                    m.type = ss[3];
                    [_datas addObject:m];
                    m = nil;
                }
            }
            list = nil;
            [_tableView reloadData];
        }
    }];
}

@end
