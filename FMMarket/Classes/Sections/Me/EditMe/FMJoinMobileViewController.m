//
//  FMJoinMobileViewController.m
//  FMMarket
//
//  Created by dangfm on 16/12/21.
//  Copyright © 2016年 dangfm. All rights reserved.
//

#import "FMJoinMobileViewController.h"
#import "UITextField+stocking.h"
#import "FMTableView.h"
#import "FMTableViewCell.h"
#import "FMSectionHeaderView.h"
#import "UILabel+stocking.h"
#import "UIButton+stocking.h"

#define kFMCheckCodeTimeout 120

@interface FMJoinMobileViewController ()
<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    
}

@property (nonatomic,retain) NSMutableArray *datas;
@property (nonatomic,retain) FMTableView *tableView;
@property (nonatomic,retain) FMSectionHeaderView *sectionHeaderView;
@property (nonatomic,retain) UIButton *loginBt;
@property (nonatomic,retain) UITextField *userNameTf;
@property (nonatomic,retain) UITextField *passwordTf;
@property (nonatomic,retain) UIButton *loginTipBt;
@property (nonatomic,retain) UIImageView *corner;

@property(nonatomic,retain) UIButton *sendCodeBt;
@property(nonatomic,retain) UITextField *codeTf;
@property(nonatomic,assign) int time;

@property (nonatomic,assign) int rows;

@end

@implementation FMJoinMobileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initParams];
    [self createViews];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //    [_userNameTf becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Init
-(void)initParams{
    _rows = 3;
    _time = kFMCheckCodeTimeout;
    [self setTitle:@"绑定手机号" IsBack:YES ReturnType:1];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
    [self.view addGestureRecognizer:tap];
    tap = nil;
    
}

#pragma mark -
#pragma mark UI Create
-(void)createViews{
    
    [self createTableView];
    [self createHeaderView];
}

//  Create TableView
-(void)createTableView{
    if (!_tableView) {
        _tableView = [[FMTableView alloc] initWithFrame:CGRectMake(0, self.point.y, UIScreenWidth, UIScreenHeight-self.point.y) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        _tableView.backgroundColor = FMBgGreyColor;
        [self.view addSubview:_tableView];
        // Login Button
        [self createLoginButton];
    }

}

//  Login Button
-(void)createLoginButton{
    if (!_loginBt) {
        _loginBt = [UIButton createButtonWithTitle:@"绑定手机号" Frame:CGRectMake(kTableViewCellLeftPadding, 20, UIScreenWidth-2*kTableViewCellLeftPadding, kUIButtonDefaultHeight)];
        _loginBt.backgroundColor = FMRedColor;
        [_loginBt setTitleColor:FMGreyColor forState:UIControlStateNormal];
        [_loginBt addTarget:self action:@selector(loginHandle:) forControlEvents:UIControlEventTouchUpInside];
        UIView *tbFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, 100)];
        tbFooter.backgroundColor = [UIColor clearColor];
        [tbFooter addSubview:_loginBt];
        // 注册
        //        UIButton *reg = [UIButton createWithTitle:@"注 册" Frame:CGRectMake(_loginBt.frame.origin.x+_loginBt.frame.size.width, _loginBt.frame.origin.y, 100, _loginBt.frame.size.height)];
        //        [reg setTitleColor:FMBlueColor forState:UIControlStateNormal] ;
        //        [reg addTarget:self action:@selector(registerHandle:) forControlEvents:UIControlEventTouchUpInside];
        //        [tbFooter addSubview:reg];
        //        reg = nil;
        _tableView.tableFooterView = tbFooter;
        tbFooter = nil;
    }
}

// 创建头部
-(void)createHeaderView{
    float x = 0;
    float y = 0;
    float w = UIScreenWidth;
    float h = 80;
    UIView *box = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    UILabel *l = [UILabel createWithTitle:@"为了保证您的帐号安全及提供给您更优质的服务，请您绑定手机号" Frame:CGRectMake(15,0,UIScreenWidth-30,h)];
    l.font = kFont(16);
    l.textColor = FMGreyColor;
    [box addSubview:l];
    
    _tableView.tableHeaderView = box;
}

//  Send Code Button
-(void)createSendCodeButtonWithSuperView:(UIView*)superView{
    if (!_sendCodeBt) {
        _sendCodeBt = [UIButton createWithTitle:@"发送验证码" Frame:CGRectMake(UIScreenWidth- kTableViewCellLeftPadding-90, 5, 90, kTableViewCellHeight-10)];
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

-(void)loginHandle:(UIButton*)bt{
    NSString *password = _passwordTf.text;
    NSString *tel = _userNameTf.text;
    NSString *code = _codeTf.text;
    if (password.length<6 || password.length>20) {
        [SVProgressHUD showErrorWithStatus:@"密码长度不符合要求"];
        return;
    }
    if (tel.length<11 || tel.length>15) {
        [SVProgressHUD showErrorWithStatus:@"手机号码有误"];
        return;
    }
    if (code.length<4) {
        [SVProgressHUD showErrorWithStatus:@"短信验证码输入有误"];
        return;
    }
    [self sendHttpJoinMobile];
}



-(void)changeLoginButtonTextColor{
    if (_userNameTf.text.length>0 && _passwordTf.text.length>0) {
        [_loginBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        [_loginBt setTitleColor:FMGreyColor forState:UIControlStateNormal];
    }
}

//  点击重新发送
-(void)sendCodeAction{
    if ([_sendCodeBt.titleLabel.text isEqualToString:@"重新发送"] ||
        [_sendCodeBt.titleLabel.text isEqualToString:@"发送验证码"]) {
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
    
    return 0;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _rows;
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
            _userNameTf = [UITextField createInputTextWithFrame:CGRectMake(kTableViewCellLeftPadding, 0, UIScreenWidth-kTableViewCellLeftPadding, kTableViewCellHeight) PlaceHolder:@"需绑定的手机号"];
            _userNameTf.keyboardType = UIKeyboardTypePhonePad;
            _userNameTf.delegate = self;
            UIImage *icon = ThemeImage(@"me/me_icon_login_account_normal");
            icon = [UIImage imageWithTintColor:FMGreyColor blendMode:kCGBlendModeDestinationIn WithImageObject:icon];
            UIButton *left = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, kTableViewCellDefaultHeight)];
            [left setImage:icon forState:UIControlStateNormal];
            _userNameTf.leftView = left;
            _userNameTf.leftViewMode = UITextFieldViewModeAlways;
            [cell.contentView addSubview:_userNameTf];
            
        }
        if (indexPath.row==1) {
            _passwordTf = [UITextField createInputTextWithFrame:CGRectMake(kTableViewCellLeftPadding, 0, UIScreenWidth-kTableViewCellLeftPadding-80, kTableViewCellHeight) PlaceHolder:@"输入密码"];
            [_passwordTf setSecureTextEntry:YES];
            [cell.contentView addSubview:_passwordTf];
            
            UIImage *icon = ThemeImage(@"me/me_login_password_normal");
            icon = [UIImage imageWithTintColor:FMGreyColor blendMode:kCGBlendModeDestinationIn WithImageObject:icon];
            UIButton *left = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, kTableViewCellDefaultHeight)];
            [left setImage:icon forState:UIControlStateNormal];
            _passwordTf.leftView = left;
            _passwordTf.leftViewMode = UITextFieldViewModeAlways;
            
            _passwordTf.delegate = self;
            
        }
        
        if (indexPath.row==2) {
            
            _codeTf = [UITextField createInputTextWithFrame:CGRectMake(kTableViewCellLeftPadding, 0, UIScreenWidth-2*kTableViewCellLeftPadding-80, kTableViewCellHeight) PlaceHolder:@"请输入验证码"];
            _codeTf.keyboardType = UIKeyboardTypePhonePad;
            UIImage *icon = ThemeImage(@"me/me_login_code_normal");
            icon = [UIImage imageWithTintColor:FMGreyColor blendMode:kCGBlendModeDestinationIn WithImageObject:icon];
            UIButton *left = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, kTableViewCellDefaultHeight)];
            [left setImage:icon forState:UIControlStateNormal];
            _codeTf.leftView = left;
            _codeTf.leftViewMode = UITextFieldViewModeAlways;
            _codeTf.rightViewMode = UITextFieldViewModeNever;
            [cell.contentView addSubview:_codeTf];
            [self createSendCodeButtonWithSuperView:cell.contentView];
            
        }
        
    }
    
    
    if (indexPath.row==2) {
        cell.isLast = YES;
    }
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

#pragma mark -
#pragma mark UITextFiled Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    //if (textField==_passwordTf) _findPasswordBt.hidden = YES;
    return YES;
}
-(BOOL)textFieldShouldClear:(UITextField *)textField{
    textField.text = @"";
    [self changeLoginButtonTextColor];
    return YES;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    [self changeLoginButtonTextColor];
    
    return YES;
}

#pragma mark -
#pragma mark Http Request

//  登陆
-(void)sendHttpJoinMobile{
    NSString *password = _passwordTf.text;
    NSString *tel = _userNameTf.text;
    NSString *code = _codeTf.text;
    if ([FMUserDefault getUserId]<=0) {
        [SVProgressHUD showErrorWithStatus:@"请先登录"];
    }
    
    [http sendJoinMobileWithTel:tel password:password code:code Start:^{
        [SVProgressHUD show];
    } failure:^{
        [SVProgressHUD showErrorWithStatus:@"网络不给力"];
    } success:^(NSDictionary*dic){
        //[SVProgressHUD dismiss];
        BOOL success = [[dic objectForKey:@"success"] boolValue];
        if (success) {
            [SVProgressHUD showSuccessWithStatus:@"手机号码绑定成功"];
            [FMUserDefault setUserWithDic:[dic objectForKey:@"data"]];
            [self performSelector:@selector(returnBack) withObject:nil afterDelay:1];
            
        }else{
            NSString *msg = [dic objectForKey:@"msg"];
            [SVProgressHUD showErrorWithStatus:msg];
        }
    }];
}

//  发送短信验证码
-(void)sendHttpSMS{
    WEAKSELF
    NSString *_tel = _userNameTf.text;
    
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


@end
