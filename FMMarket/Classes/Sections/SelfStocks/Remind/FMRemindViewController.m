//
//  FMRemindViewController.m
//  FMMarket
//
//  Created by dangfm on 15/11/29.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMRemindViewController.h"
#import "FMTableView.h"
#import "FMTableViewCell.h"


@interface FMRemindViewController ()
<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UITextFieldDelegate>
{
    NSArray *_datas;
    FMTableView *_tableView;
    UITextField *_upToPrice;
    UITextField *_downToPrice;
    UITextField *_upRateToValue;
    UITextField *_downRateToValue;
}
@end


@implementation FMRemindViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initParams];
    [self createViews];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    
    if (_tableView) {
        [self updateUserViews];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Init
-(void)initParams{
    _datas = @[@"股价涨到",@"股价跌倒",@"日涨幅超",@"日跌幅超"];
    [self setTitle:@"提醒设置" IsBack:YES ReturnType:1];
}

-(instancetype)initWithCode:(NSString *)code name:(NSString *)name{
    if (self==[super init]) {
        _code = code;
        _name = name;
    }
    return self;
}

#pragma mark -
#pragma mark UI Create
-(void)createViews{
    [self createFinishButtonView];
    [self createTableView];
    [self loadRemindValue];
}

-(void)createFinishButtonView{
    //self.header.backButton.hidden = YES;
    UIButton *finish = [[UIButton alloc] initWithFrame:CGRectMake(UIScreenWidth-80, 0, 80, kNavigationHeight)];
    [finish setTitle:@"完成" forState:UIControlStateNormal];
    [finish setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    finish.titleLabel.font = kFont(16);
    [self.header addSubview:finish];
    [finish addTarget:self
               action:@selector(saveAllDatas)
     forControlEvents:UIControlEventTouchUpInside];
    finish = nil;
}
//  Create TableView
-(void)createTableView{
    if (!_tableView) {
        _tableView = [[FMTableView alloc] initWithFrame:CGRectMake(0, self.point.y, UIScreenWidth, UIScreenHeight-self.point.y) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = FMBgGreyColor;
        [self.view addSubview:_tableView];
        [self createHeaderView];
    }
}

-(void)createHeaderView{
    
    NSArray*rs = [db select:[FMSelfStocksModel class] Where:[NSString stringWithFormat:@"code like '%%%@'",_code] Order:nil Limit:nil];
    if (rs.count>0) {
        FMSelfStocksModel *m = rs.firstObject;
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, kNavigationHeight)];
        v.backgroundColor = FMBgGreyColor;
        _tableView.tableHeaderView = v;
        UILabel *l = [UILabel createWithTitle:_name Frame:CGRectMake(15, 0, UIScreenWidth-30, kNavigationHeight)];
        l.font = kFont(16);
        l.textColor = FMZeroColor;
        [l sizeToFit];
        l.frame = CGRectMake(15, 0, l.frame.size.width, kNavigationHeight);
        [v addSubview:l];
        NSString *str = [NSString stringWithFormat:@"最新价 %@  涨跌幅 %@",m.price,m.changeRate];
        UILabel *p = [UILabel createWithTitle:str Frame:CGRectMake(l.frame.size.width+l.frame.origin.x+20, 0, UIScreenWidth-(l.frame.size.width+l.frame.origin.x+20), l.frame.size.height)];
        p.font = l.font;
        p.textColor = FMGreyColor;
        [v addSubview:p];
        m = nil;
    }
    rs = nil;
}

-(void)updateUserViews{
    [_tableView reloadData];
}

#pragma mark -
#pragma mark UI Action
-(void)saveAllDatas{
    
    NSString *upToPrice = _upToPrice.text;
    NSString *downToPrice = _downToPrice.text;
    NSString *upRateToValue = _upRateToValue.text;
    NSString *downRateToValue = _downRateToValue.text;
    if ([upToPrice floatValue]<=0 &&
        [downToPrice floatValue]<=0 &&
        [upRateToValue floatValue]<=0 &&
        [downRateToValue floatValue]<=0) {
        [self returnBack];
        return;
    }
    // 存数据库
    FMStockRemindModel *m = [[FMStockRemindModel alloc] init];
    m.upToPrice = upToPrice;
    m.downToPrice = downToPrice;
    m.upRateToValue = upRateToValue;
    m.downRateToValue = downRateToValue;
    m.code = _code;
    m.userId = [FMUserDefault getUserId];
    NSString *where = [NSString stringWithFormat:@"userId='%@' and code='%@'",m.userId,m.code];
    NSArray *rs = [db select:m Where:where Order:nil Limit:nil];
    if (rs.count>0) {
        // 更新
        [db update:m Where:where FinishBlock:nil];
    }else{
        [db insert:m FinishBlock:nil];
    }
    m = nil;
    WEAKSELF
    [http sendSelfStockRmindWithCode:_code upToPrice:upToPrice downToPrice:downToPrice upRateToValue:upRateToValue downRateToValue:downRateToValue Start:^{
        [SVProgressHUD show];
    } failure:^{
        [SVProgressHUD showErrorWithStatus:@"网络不给力"];
        NSLog(@"提醒添加超时");
    } success:^(NSDictionary*dic){
        
        BOOL success = [[dic objectForKey:@"success"]boolValue];
        if (success) {
            NSLog(@"提醒添加成功");
            [SVProgressHUD showSuccessWithStatus:@"添加成功"];
            [fn sleepSeconds:1 finishBlock:^{
                [__weakSelf returnBack];
            }];
            
        }else{
            NSLog(@"提醒添加失败:%@",[dic objectForKey:@"msg"]);
            [SVProgressHUD showErrorWithStatus:[dic objectForKey:@"msg"]];
            
        }
        
        
    }];
}

-(void)loadRemindValue{
    [http getSelfStockRemindInfoWithCode:_code Start:^{
        
    } failure:^{
        [SVProgressHUD showErrorWithStatus:@"网络不给力"];
    } success:^(NSDictionary*dic){
        if (dic) {
            dic  = [dic objectForKey:@"data"];
            FMStockRemindModel *m = [[FMStockRemindModel alloc] initWithDic:dic];
            if (m) {
                _upToPrice.text = m.upToPrice;
                _downToPrice.text = m.downToPrice;
                _upRateToValue.text = m.upRateToValue;
                _downRateToValue.text = m.downRateToValue;
            }
            m = nil;
        }
    }];
}

-(void)clickSwithAction:(UISwitch*)sender{
    NSLog(@"%d",sender.on);
    if (!sender.on) {
        NSInteger tag = sender.tag;
        switch (tag) {
            case 0:
                _upToPrice.text = @"";
                break;
            case 1:
                _downToPrice.text = @"";
                break;
            case 2:
                _upRateToValue.text = @"";
                break;
            case 3:
                _downRateToValue.text = @"";
                break;
                
            default:
                break;
        }
    }
}

#pragma mark -
#pragma mark UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return kTableViewCellHeight;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIndentifier = [NSString stringWithFormat:@"cell_%d",(int)indexPath.row];
    FMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[FMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIndentifier];
        cell.leftImageWidth = 15;
        UILabel *left = [UILabel createWithTitle:@"" Frame:CGRectMake(0, 0, 10, kTableViewCellDefaultHeight-14)];
        if (indexPath.row==2) {
            left.text = @"+";
            left.textColor = FMRedColor;
        }
        if (indexPath.row==3) {
            left.text = @"-";
            left.textColor = FMGreenColor;
        }
        left.textAlignment = NSTextAlignmentCenter;
        
        UITextField *t = [UITextField createInputTextWithFrame:CGRectMake(UIScreenWidth/3, 7, UIScreenWidth/3-20, kTableViewCellDefaultHeight-14) PlaceHolder:@""];
        t.layer.borderColor = FMBottomLineColor.CGColor;
        t.layer.borderWidth = 0.5;
        t.layer.masksToBounds = YES;
        t.layer.cornerRadius = 3;
        t.keyboardType = UIKeyboardTypeDecimalPad;
        t.leftView = left;
        switch (indexPath.row) {
            case 0:
                _upToPrice = t;
                break;
            case 1:
                _downToPrice = t;
                break;
            case 2:
                _upRateToValue = t;
                break;
            case 3:
                _downRateToValue = t;
                break;
                
            default:
                break;
        }
        t.delegate = self;
        t.leftViewMode = UITextFieldViewModeAlways;
        [cell.contentView addSubview:t];
        UILabel *l = [UILabel createWithTitle:@"元" Frame:CGRectMake(t.frame.origin.x+t.frame.size.width + 5, 0, 20, kTableViewCellDefaultHeight)];
        if (indexPath.row==2) {
            l.text = @"%";
            l.textColor = FMRedColor;
        }
        if (indexPath.row==3) {
            l.text = @"%";
            l.textColor = FMGreenColor;
        }
        [cell.contentView addSubview:l];
        l = nil;
        t = nil;
        UISwitch *s = [[UISwitch alloc] init];
        s.frame = CGRectMake(UIScreenWidth-kTableViewCellLeftPadding-s.frame.size.width, (kTableViewCellDefaultHeight-s.frame.size.height)/2, s.frame.size.width, s.frame.size.height);
        s.onTintColor = FMBlueColor;
        s.tag = indexPath.row;
        [s addTarget:self action:@selector(clickSwithAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:s];
        s = nil;
    }
  
    cell.title.text = [_datas objectAtIndex:indexPath.row];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}




@end
