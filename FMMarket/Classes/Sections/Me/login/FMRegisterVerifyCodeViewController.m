//
//  FMRegisterVerifyCodeViewController.m
//  FMMarket
//
//  Created by dangfm on 15/9/3.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMRegisterVerifyCodeViewController.h"
#import "UITextField+stocking.h"
#import "FMTableView.h"
#import "FMTableViewCell.h"
#import "FMSectionHeaderView.h"
#import "UILabel+stocking.h"
#import "UIButton+stocking.h"

#define kFMCheckCodeTimeout 120

@interface FMRegisterVerifyCodeViewController ()
<UITableViewDataSource,UITableViewDelegate>
{
    
}

@property(nonatomic,retain) NSMutableArray *datas;
@property(nonatomic,retain) FMTableView *tableView;
@property(nonatomic,retain) FMSectionHeaderView *sectionHeaderView;
@property(nonatomic,retain) UIButton *loginBt;
@property(nonatomic,retain) UIButton *sendCodeBt;
@property(nonatomic,retain) UITextField *codeTf;
@property(nonatomic,retain) UITextField *passwordTf;

@property(nonatomic,assign) int time;
@property(nonatomic,assign) BOOL isChangePassword;
@end

@implementation FMRegisterVerifyCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initParams];
    [self createTableView];
    [self sendHttpSMS];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.tabBarController.tabBar.hidden = YES;
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_codeTf becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Init

-(instancetype)initWithTel:(NSString *)tel changePassword:(BOOL)changePassword{
    if (self==[super init]) {
        _isChangePassword = changePassword;
        _tel = tel;
    }
    return self;
}

-(void)initParams{
    //self.navigationItem.title = @"手机注册";
    if (_isChangePassword) {
        [self setTitle:@"忘记密码" IsBack:YES ReturnType:1];
    }else{
        [self setTitle:@"手机注册" IsBack:YES ReturnType:1];
    }
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
    [self.view addGestureRecognizer:tap];
    tap = nil;
    _time = kFMCheckCodeTimeout;
    
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
        // Login Button
        [self createLoginButton];
    }
}

//  Login Button
-(void)createLoginButton{
    if (!_loginBt) {
        _loginBt = [UIButton createButtonWithTitle:@"完 成" Frame:CGRectMake(kTableViewCellLeftPadding, 20, UIScreenWidth-2*kTableViewCellLeftPadding, kUIButtonDefaultHeight)];
        UIView *tbFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, 100)];
        tbFooter.backgroundColor = [UIColor clearColor];
        [tbFooter addSubview:_loginBt];
        [_loginBt addTarget:self action:@selector(nextStepHandle:) forControlEvents:UIControlEventTouchUpInside];
        _tableView.tableFooterView = tbFooter;
        tbFooter = nil;
    }
}

//  Send Code Button
-(void)createSendCodeButtonWithSuperView:(UIView*)superView{
    if (!_sendCodeBt) {
        _sendCodeBt = [UIButton createWithTitle:@"重新发送" Frame:CGRectMake(UIScreenWidth- kTableViewCellLeftPadding-80, 0, 80, kTableViewCellHeight)];
        [_sendCodeBt setTitleColor:FMBlueColor forState:UIControlStateNormal];
        _sendCodeBt.backgroundColor = FMBgGreyColor;
        _sendCodeBt.layer.masksToBounds = YES;
        _sendCodeBt.layer.cornerRadius = 3;
        _sendCodeBt.layer.borderColor = FMBottomLineColor.CGColor;
        _sendCodeBt.layer.borderWidth = 0.5;
        [_sendCodeBt addTarget:self
                        action:@selector(sendCodeAction)
              forControlEvents:UIControlEventTouchUpInside];
        [superView addSubview:_sendCodeBt];
    }
}

#pragma mark -
#pragma mark UI Action
-(void)tapHandle:(UITapGestureRecognizer*)tap{
    [self.view endEditing:YES];
}
//  点击完成
-(void)nextStepHandle:(UIButton*)bt{
    NSString *password = _passwordTf.text;
    NSString *code = _codeTf.text;
    if (password.length<6 || password.length>20) {
        [SVProgressHUD showErrorWithStatus:@"密码长度不符合要求"];
        return;
    }
    if (code.length<=0) {
        [SVProgressHUD showErrorWithStatus:@"短信验证码不能为空"];
        return;
    }
    if (_tel.length<11|| _tel.length>15) {
        [SVProgressHUD showErrorWithStatus:@"手机号码有误"];
        return;
    }
    if (_isChangePassword) {
        // 忘记密码
        [self sendHttpChangePassword];
    }else{
        // 注册
        [self sendHttpUserRegister];
    }
}
//  点击重新发送
-(void)sendCodeAction{
    if ([_sendCodeBt.titleLabel.text isEqualToString:@"重新发送"]) {
        _sendCodeBt.enabled = NO;
        [self sendHttpSMS];
    }
}
-(void)returnBack{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

// 倒计时
-(void)loopTime{
    _time --;
    [_sendCodeBt setTitle:[NSString stringWithFormat:@"%d秒",_time] forState:UIControlStateNormal];
    if (_time>0) {
        [self performSelector:@selector(loopTime) withObject:nil afterDelay:1];
    }else{
        _time = kFMCheckCodeTimeout;
        [_sendCodeBt setTitle:@"重新发送" forState:UIControlStateNormal];
    }
    
}

#pragma mark -
#pragma mark UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kTableViewCellHeight;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return kFMRegisterVerifyCodeViewSectionHeight;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (!_sectionHeaderView) {
        _sectionHeaderView = [[FMSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, kFMRegisterVerifyCodeViewSectionHeight)];
        _sectionHeaderView.backgroundColor = [UIColor clearColor];
        _sectionHeaderView.section = section;
        _sectionHeaderView.tableView = tableView;
        UILabel *l = [UILabel createWithTitle:@"已发送验证码到您的手机"
                                        Frame:CGRectMake(kTableViewCellLeftPadding   ,kFMRegisterVerifyCodeViewSectionHeight-25,UIScreenWidth-kTableViewCellLeftPadding,15)];
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
            _codeTf = [UITextField createInputTextWithFrame:CGRectMake(kTableViewCellLeftPadding, 0, UIScreenWidth-2*kTableViewCellLeftPadding-180, kTableViewCellHeight) PlaceHolder:@"输入验证码"];
            _codeTf.keyboardType = UIKeyboardTypePhonePad;
            [cell.contentView addSubview:_codeTf];
            [self createSendCodeButtonWithSuperView:cell.contentView];
            
        }
        if (indexPath.row==1) {
            _passwordTf = [UITextField createInputTextWithFrame:CGRectMake(kTableViewCellLeftPadding, 0, UIScreenWidth-kTableViewCellLeftPadding, kTableViewCellHeight) PlaceHolder:@"输入密码(6-20位，请使用字母或者数字)"];
            [_passwordTf setSecureTextEntry:YES];
            [cell.contentView addSubview:_passwordTf];
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

#pragma mark -
#pragma mark Http Request

//  发送短信验证码
-(void)sendHttpSMS{
    WEAKSELF
    [http sendSMSWithTel:_tel start:^{
        [SVProgressHUD show];
    } failure:^{
        [SVProgressHUD showErrorWithStatus:@"网络不给力"];
        __weakSelf.sendCodeBt.enabled = YES;
    } success:^(NSDictionary* dic){
        __weakSelf.sendCodeBt.enabled = YES;
        if (dic) {
            BOOL success = [[dic objectForKey:@"success"] boolValue];
            if (success) {
                // 验证码发送成功
                [SVProgressHUD showSuccessWithStatus:@"验证码已发送"];
                // 开始倒计时
                [__weakSelf loopTime];
            }else{
                NSString *msg = [dic objectForKey:@"msg"];
                [SVProgressHUD showErrorWithStatus:msg];
            }
        }
        
    }];
}

//  发送注册
-(void)sendHttpUserRegister{
    NSString *password = _passwordTf.text;
    NSString *code = _codeTf.text;
    [http sendUserRegisterWithTel:_tel password:password code:code start:^{
        [SVProgressHUD show];
    } failure:^{
        [SVProgressHUD showErrorWithStatus:@"网络不给力"];
    } success:^(NSDictionary*dic){
        //[SVProgressHUD dismiss];
        BOOL success = [[dic objectForKey:@"success"] boolValue];
        if (success) {
            [FMUserDefault setUserWithDic:[dic objectForKey:@"data"]];
            [SVProgressHUD showSuccessWithStatus:@"注册成功"];
            [self performSelector:@selector(returnBack) withObject:nil afterDelay:1];
        }else{
            NSString *msg = [dic objectForKey:@"msg"];
            [SVProgressHUD showErrorWithStatus:msg];
        }
    }];
}

//  忘记密码
-(void)sendHttpChangePassword{
    NSString *password = _passwordTf.text;
    NSString *code = _codeTf.text;
    [http sendChangePasswordWithTel:_tel password:password code:code start:^{
        [SVProgressHUD show];
    } failure:^{
        [SVProgressHUD showErrorWithStatus:@"网络不给力"];
    } success:^(NSDictionary*dic){
        //[SVProgressHUD dismiss];
        BOOL success = [[dic objectForKey:@"success"] boolValue];
        if (success) {
            [SVProgressHUD showSuccessWithStatus:@"密码修改成功"];
            [self performSelector:@selector(returnBack) withObject:nil afterDelay:1];
        }else{
            NSString *msg = [dic objectForKey:@"msg"];
            [SVProgressHUD showErrorWithStatus:msg];
        }
    }];
}
@end
