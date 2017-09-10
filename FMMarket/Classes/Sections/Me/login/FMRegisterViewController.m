//
//  FMRegisterViewController.m
//  FMMarket
//
//  Created by dangfm on 15/9/3.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMRegisterViewController.h"
#import "UITextField+stocking.h"
#import "FMTableView.h"
#import "FMTableViewCell.h"
#import "FMSectionHeaderView.h"
#import "UILabel+stocking.h"
#import "UIButton+stocking.h"
#import "FMRegisterVerifyCodeViewController.h"

@interface FMRegisterViewController ()
<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *_datas;
    FMTableView *_tableView;
    FMSectionHeaderView *_sectionHeaderView;
    UIButton *_loginBt;
    UITextField *_userNameTf;
    UITextField *_passwordTf;
    BOOL _isChangePassword;
}
@end

@implementation FMRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initParams];
    [self createTableView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_userNameTf becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Init

-(instancetype)initWithChangePassword:(BOOL)changePassword{
    if (self==[super init]) {
        _isChangePassword = changePassword;
    }
    return self;
}

-(void)initParams{
    
    if (_isChangePassword) {
        [self setTitle:@"忘记密码" IsBack:YES ReturnType:1];
    }else{
        [self setTitle:@"手机注册" IsBack:YES ReturnType:1];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
    [self.view addGestureRecognizer:tap];
    tap = nil;
}

#pragma mark -
#pragma mark UI Create
-(void)createViews{
    [self createTableView];
    
}

//  Create TableView
-(void)createTableView{
    if (!_tableView) {
        _tableView = [[FMTableView alloc] initWithFrame:CGRectMake(0, self.point.y, UIScreenWidth, UIScreenHeight-self.point.y-kNavigationHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = FMBgGreyColor;
        [self.view addSubview:_tableView];
        // Login Button
        [self createLoginButton];
    }
}

//  Login Button
-(void)createLoginButton{
    if (!_loginBt) {
        _loginBt = [UIButton createButtonWithTitle:@"下一步" Frame:CGRectMake(kTableViewCellLeftPadding, 20, UIScreenWidth-2*kTableViewCellLeftPadding, kUIButtonDefaultHeight)];
        UIView *tbFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, 100)];
        tbFooter.backgroundColor = [UIColor clearColor];
        [tbFooter addSubview:_loginBt];
        [_loginBt addTarget:self action:@selector(nextStepHandle:) forControlEvents:UIControlEventTouchUpInside];
        _tableView.tableFooterView = tbFooter;
        tbFooter = nil;
    }
}

#pragma mark -
#pragma mark UI Action
-(void)tapHandle:(UITapGestureRecognizer*)tap{
    [self.view endEditing:YES];
}
-(void)nextStepHandle:(UIButton*)bt{
    // 验证手机号
    if (_userNameTf.text.length<11) {
        [SVProgressHUD showErrorWithStatus:@"手机号码有误"];
    }else{
        FMRegisterVerifyCodeViewController *reg = [[FMRegisterVerifyCodeViewController alloc] initWithTel:_userNameTf.text changePassword:_isChangePassword];
        [self.navigationController pushViewController:reg animated:YES];
        reg = nil;
    }
}

#pragma mark -
#pragma mark UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kTableViewCellHeight;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return kFMRegisterViewSectionHeight;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (!_sectionHeaderView) {
        _sectionHeaderView = [[FMSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, kFMRegisterViewSectionHeight)];
        _sectionHeaderView.backgroundColor = [UIColor clearColor];
        _sectionHeaderView.section = section;
        _sectionHeaderView.tableView = tableView;
        UILabel *l = [UILabel createWithTitle:@"手机号注册"
                                        Frame:CGRectMake(kTableViewCellLeftPadding   ,kFMRegisterViewSectionHeight-25,UIScreenWidth-kTableViewCellLeftPadding,15)];
        if (_isChangePassword) {
            l.text = @"验证手机号";
        }
        l.font = kFont(12);
        l.textColor = FMGreyColor;
        [_sectionHeaderView addSubview:l];
        l = nil;
    }
    return _sectionHeaderView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIndentifier = @"cell";
    FMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[FMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIndentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.row==0) {
            [fn drawLineWithSuperView:cell.contentView
                                Color:FMBottomLineColor
                                Frame:CGRectMake(0, 0, UIScreenWidth, 0.5)];
            _userNameTf = [UITextField createInputTextWithFrame:CGRectMake(kTableViewCellLeftPadding, 0, UIScreenWidth-kTableViewCellLeftPadding, kTableViewCellHeight) PlaceHolder:@"请输入手机号码"];
            _userNameTf.keyboardType = UIKeyboardTypePhonePad;
            [cell.contentView addSubview:_userNameTf];
            
        }
        
        
    }
    
    
    if (indexPath.row==1) {
        cell.isLast = YES;
    }
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}
@end
