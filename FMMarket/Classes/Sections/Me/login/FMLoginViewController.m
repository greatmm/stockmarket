//
//  FMLoginViewController.m
//  FMMarket
//
//  Created by dangfm on 15/9/3.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMLoginViewController.h"
#import "UITextField+stocking.h"
#import "FMTableView.h"
#import "FMTableViewCell.h"
#import "FMSectionHeaderView.h"
#import "UILabel+stocking.h"
#import "UIButton+stocking.h"
#import "FMRegisterViewController.h"
#import "FMBackgroundRun.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import "FMEditMeViewController.h"
#import "WXApi.h"

#define kFMCheckCodeTimeout 120

@interface FMLoginViewController()
<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,TencentLoginDelegate,TencentSessionDelegate,WXApiDelegate>
{
    
}

@property (nonatomic,retain) NSMutableArray *datas;
@property (nonatomic,retain) FMTableView *tableView;
@property (nonatomic,retain) FMSectionHeaderView *sectionHeaderView;
@property (nonatomic,retain) UIButton *loginBt;
@property (nonatomic,retain) UIButton *findPasswordBt;
@property (nonatomic,retain) UITextField *userNameTf;
@property (nonatomic,retain) UITextField *passwordTf;

@property (nonatomic,retain) UIButton *registerTipBt;
@property (nonatomic,retain) UIButton *loginTipBt;
@property (nonatomic,retain) UIImageView *corner;

@property(nonatomic,retain) UIButton *sendCodeBt;
@property(nonatomic,retain) UITextField *codeTf;
@property(nonatomic,assign) int time;

@property (nonatomic,assign) int rows;
@property (nonatomic,assign) int backType;

// 快捷登录
@property (nonatomic,retain) TencentOAuth *tencentOAuth;
@property (nonatomic,retain) NSArray *permissions;          // 授权列表
@property (nonatomic,retain) NSString *wxState;             // 发送给微信的状态码 随机数

@end

@implementation FMLoginViewController

-(void)dealloc{
    NSLog(@"FMLoginViewController dealloc");
}

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
-(instancetype)initWithBackType:(int)backType finishedLoginBlock:(FinishedLoginBlock)block{
    if (self==[super init]) {
        _backType = backType;
        _finishedLoginBlock = block;
    }
    return self;
}
-(void)initParams{
    _rows = 2;
    _time = kFMCheckCodeTimeout;
    [self setTitle:@"" IsBack:YES ReturnType:_backType];
    self.header.backgroundColor = [UIColor clearColor];
    self.stateView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
    [self.view addGestureRecognizer:tap];
    tap = nil;
    
    // 快捷登录
    _tencentOAuth = [[TencentOAuth alloc] initWithAppId:kShare_QQAppId andDelegate:self];
    _permissions =  @[@"get_user_info", @"get_simple_userinfo", @"add_t"];
    // 微信授权成功通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getWxAccessToken:) name:kWechatDidLoginNotification object:nil];
}

#pragma mark -
#pragma mark UI Create
-(void)createViews{
    
    [self createTableView];
    [self createHeaderView];
    [self createQQWeiXinLoginViews];
    
}

//  Create TableView
-(void)createTableView{
    if (!_tableView) {
        _tableView = [[FMTableView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, UIScreenHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        _tableView.backgroundColor = FMBgGreyColor;
        [self.view addSubview:_tableView];
        // Login Button
        [self createLoginButton];
    }
    [self.view bringSubviewToFront:self.header];
    [self.view bringSubviewToFront:self.stateView];
    self.header.bottomline.hidden = YES;
}

//  Login Button
-(void)createLoginButton{
    if (!_loginBt) {
        _loginBt = [UIButton createButtonWithTitle:@"登 录" Frame:CGRectMake(kTableViewCellLeftPadding, 20, UIScreenWidth-2*kTableViewCellLeftPadding, kUIButtonDefaultHeight)];
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
    UIImage *img = ThemeImage(@"me/me_icon_login_red_normal");
    float x = 0;
    float y = 0;
    float w = UIScreenWidth;
    float h = img.size.height/img.size.width * w;
    UIView *box = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, h)];
    UIImageView *bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, w, h)];
    bg.image = img;
    [box addSubview:bg];
    // 放按钮
    _registerTipBt = [UIButton createWithTitle:@"注册" Frame:CGRectMake(0, h-44, w/3, 44)];
    [_registerTipBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _registerTipBt.titleLabel.font = kFont(16);
    [_registerTipBt addTarget:self action:@selector(clickLoginRegisterTip:) forControlEvents:UIControlEventTouchUpInside];
    [box addSubview:_registerTipBt];
    
    _loginTipBt = [UIButton createWithTitle:@"登录" Frame:CGRectMake(w/3*2, h-44, w/3, 44)];
    [_loginTipBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _loginTipBt.titleLabel.font = kFont(16);
    [_loginTipBt addTarget:self action:@selector(clickLoginRegisterTip:) forControlEvents:UIControlEventTouchUpInside];
    [box addSubview:_loginTipBt];
    
    UIImage *cr = ThemeImage(@"global/icon_down_normal");
    cr = [UIImage imageWithTintColor:[UIColor whiteColor] blendMode:kCGBlendModeDestinationIn WithImageObject:cr];
    _corner = [[UIImageView alloc] initWithFrame:CGRectMake(w/3*2+w/3/2-cr.size.width/2, h-cr.size.height+8, cr.size.width, cr.size.height)];
    _corner.image = cr;
    [box addSubview:_corner];
    
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

// qq微信登录界面
-(void)createQQWeiXinLoginViews{
    
    float h = UIScreenHeight-348;
    if (h>188) {
        h = 188;
    }
    UIView *qqbox = [[UIView alloc] initWithFrame:CGRectMake(0, UIScreenHeight-h, UIScreenWidth, h)];
    [fn drawLineWithSuperView:qqbox Color:FMBottomLineColor Frame:CGRectMake(20, 10, UIScreenWidth-40, 0.5)];
    UILabel *yj = [UILabel createWithTitle:@"一键登录" Frame:CGRectMake((UIScreenWidth-80)/2,3,80,14)];
    yj.backgroundColor = FMBgGreyColor;
    yj.textColor = FMGreyColor;
    yj.textAlignment = NSTextAlignmentCenter;
    [qqbox addSubview:yj];
    UIImage *qqicon = [UIImage imageNamed:@"icon_qq"];
    UIImage *weixinicon = [UIImage imageNamed:@"icon_weixin"];
    float w = 55;
    
    UIButton *qq = [[UIButton alloc] initWithFrame:CGRectMake(UIScreenWidth/2-qqicon.size.width-20, 40, w, w)];
    [qqbox addSubview:qq];
    qq.tag = 0;
    [qq addTarget:self action:@selector(clickQQWEIXINLoginButtons:) forControlEvents:UIControlEventTouchUpInside];
    [qq setImage:qqicon forState:UIControlStateNormal];
    
    
    UIButton *weixin = [[UIButton alloc] initWithFrame:CGRectMake(UIScreenWidth/2+20, 40, w, w)];
    weixin.tag = 1;
    [weixin addTarget:self action:@selector(clickQQWEIXINLoginButtons:) forControlEvents:UIControlEventTouchUpInside];
    [weixin setImage:weixinicon forState:UIControlStateNormal];
    [qqbox addSubview:weixin];
    
    if (![TencentOAuth iphoneQQInstalled]) {
        qq.hidden = YES;
    }
    if (![WXApi isWXAppInstalled]) {
        weixin.hidden = YES;
    }
    if (![TencentOAuth iphoneQQInstalled] && ![WXApi isWXAppInstalled]) {
        qq.hidden = YES;
        weixin.hidden = YES;
        yj.hidden = YES;
    }
    
    qq.hidden = YES;
    weixin.hidden = YES;
    yj.hidden = YES;
    
    // 风险提示
    UILabel *tip = [UILabel createWithTitle:@"平台内容仅代表个人观点，不构成投资建议，\n股市有风险，投资需谨慎" Frame:CGRectMake(0,h-50,UIScreenWidth,40)];
    tip.textColor = FMGreyColor;
    [qqbox addSubview:tip];
    tip.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:qqbox];
    
}

#pragma mark -
#pragma mark UI Action

// 点击注册登录切换
-(void)clickLoginRegisterTip:(UIButton*)bt{
    float w = UIScreenWidth;
    float x = w/3*2+w/3/2-_corner.frame.size.width/2;
    if ([bt isEqual:_registerTipBt]) {
        x = w/3/2-_corner.frame.size.width/2;
    }
    CGRect frame = _corner.frame;
    frame.origin.x = x;
    WEAKSELF
    [UIView animateWithDuration:0.3 animations:^{
        __weakSelf.corner.frame = frame;
    } completion:^(BOOL finished){
    
    }];
    
    if ([bt isEqual:_registerTipBt]) {
        _rows = 3;
        // 按钮变成注册按钮
        [_loginBt setTitle:@"注 册" forState:UIControlStateNormal];
        _findPasswordBt.hidden = YES;
        _userNameTf.placeholder = @"请输入手机号注册";
        _passwordTf.placeholder = @"请输入注册密码";
    }else{
        _rows = 2;
        [_loginBt setTitle:@"登 录" forState:UIControlStateNormal];
        _findPasswordBt.hidden = NO;
        _userNameTf.placeholder = @"手机号登录";
        _passwordTf.placeholder = @"输入密码";
    }
    
    [_tableView reloadData];
}

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
    if (_rows==2) {
        [self sendHttpUserLogin];
    }else{
        if (code.length<4) {
            [SVProgressHUD showErrorWithStatus:@"短信验证码输入有误"];
            return;
        }
        [self sendHttpUserRegister];
    }
}

-(void)registerHandle:(UIButton*)bt{
    FMRegisterViewController *reg = [[FMRegisterViewController alloc] initWithChangePassword:NO];
    [self.navigationController pushViewController:reg animated:YES];
    reg = nil;
}

-(void)findPasswordHandle:(UIButton*)bt{
    FMRegisterViewController *reg = [[FMRegisterViewController alloc] initWithChangePassword:YES];
    [self.navigationController pushViewController:reg animated:YES];
    reg = nil;
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
    [super returnBack];
    if (self.finishedLoginBlock) {
        if ([[FMUserDefault getUserId] intValue]>0) {
            self.finishedLoginBlock();
        }
        
    }
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

#pragma mark - QQ WEXIN LOGIN
-(void)clickQQWEIXINLoginButtons:(UIButton*)bt{
    [SVProgressHUD showWithStatus:@"正在登录..."];
    if (bt.tag==0) {
        if ([TencentOAuth iphoneQQInstalled]) {
            [_tencentOAuth authorize:_permissions inSafari:NO];
        }else{
            [SVProgressHUD showErrorWithStatus:@"未安装QQ"];
        }
        
    }
    if (bt.tag==1) {
        if ([WXApi isWXAppInstalled]) {
            [self sendAuthRequest];
        }else{
            [SVProgressHUD showErrorWithStatus:@"未安装微信"];
        }
    }
    
    // 超时
    [self performSelector:@selector(timeoutLogin) withObject:nil afterDelay:40];
    
}

-(void)timeoutLogin{
    
    [SVProgressHUD dismiss];
}

#pragma mark - TencentLoginDelegate
-(void)tencentDidLogin
{
    
    
    if (_tencentOAuth.accessToken && 0 != [_tencentOAuth.accessToken length])
    {
        //  记录登录用户的OpenID、Token以及过期时间
        [FMUserDefault setQQOpenId:_tencentOAuth.openId];
        [FMUserDefault setQQAccessToken:_tencentOAuth.accessToken];
        [_tencentOAuth getUserInfo];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"一键登录失败,重新试试看"];
    }
}

-(void)tencentDidNotLogin:(BOOL)cancelled
{
    if (cancelled)
    {
        [SVProgressHUD showErrorWithStatus:@"用户取消登录"];
    }
    else
    {
        [SVProgressHUD showErrorWithStatus:@"登录失败"];
    }
} 
-(void)tencentDidNotNetWork
{
    [SVProgressHUD showErrorWithStatus:@"无网络连接，请设置网络"];
}

// 登录成功获取用户资料
-(void)getUserInfoResponse:(APIResponse *)response{
    WEAKSELF
    
    NSDictionary *userInfo = response.jsonResponse;
    if (userInfo) {
        NSLog(@"%@",userInfo);
        // 提取第三方登录后返回的用户资料
        NSString *nickName = userInfo[@"nickname"];
        NSString *userFace = userInfo[@"figureurl_qq_2"];
        // 保存
        [FMUserDefault setUserFace:userFace];
        [FMUserDefault setNickName:nickName];
        
        NSString *qq_open_id = [FMUserDefault getQQOpenId];
        NSString *qq_access_token = [FMUserDefault getQQAccessToken];
        
        // 请求第三方登录
        [http sendOtherLoginWithQQOpenId:qq_open_id QQAccessToken:qq_access_token WeiXinOpenId:nil WeiXinAccessToken:nil start:^{
        
        } failure:^{
            [SVProgressHUD showErrorWithStatus:@"第三方登录失败"];
        } success:^(NSDictionary*dic){
            BOOL success = [[dic objectForKey:@"success"] boolValue];
            if (success) {
                NSDictionary *user = [dic objectForKey:@"data"];
                if ([[user class] isSubclassOfClass:[NSDictionary class]]) {
                    [FMUserDefault setUserWithDic:user];
                    [SVProgressHUD showSuccessWithStatus:@"登陆成功"];
                    // 启动下载用户自选数据
                    [[FMBackgroundRun instance] firstDownloadMySelfStocksWithBlock:nil];
                    
                    NSString *tel = [FMUserDefault getMobile];
                    if (!tel || [tel isEqualToString:@""]) {
                        if (__weakSelf.finishedLoginBlock) {
                            [__weakSelf performSelector:@selector(returnBack) withObject:nil afterDelay:1];
                            return ;
                        }
                        // 判断是否绑定手机号，如果没有绑定手机号就跳到绑定手机号界面，如果一绑定就跳回我界面显示已经登录状态
                        FMEditMeViewController *edit = [[FMEditMeViewController alloc] init];
                        [__weakSelf.navigationController pushViewController:edit animated:YES];
                    }else{
                        [__weakSelf performSelector:@selector(returnBack) withObject:nil afterDelay:1];
                    }
                }else{
                    [SVProgressHUD showErrorWithStatus:@"服务器有误"];
                }
            }else{
                NSString *msg = [dic objectForKey:@"msg"];
                [SVProgressHUD showErrorWithStatus:msg];
            }
        }];
        
        
        
    }else{
        [SVProgressHUD showErrorWithStatus:@"获取用户信息失败"];
    }
}


#pragma mark - TencentSessionDelegate

- (void)tencentDidLogout
{
    
}

- (void)responseDidReceived:(APIResponse*)response forMessage:(NSString *)message
{
    
}

#pragma mark - WXApiDelegate

// 第一步 发送信息获取code 授权临时票据
-(void)sendAuthRequest
{
    _wxState = [NSString stringWithFormat:@"%@_%d",kAPI_Key,rand()];
    //构造SendAuthReq结构体
    SendAuthReq* req = [[SendAuthReq alloc ] init];
    req.scope = @"snsapi_userinfo" ;
    req.state = _wxState ;
    //第三方向微信终端发送一个SendAuthReq消息结构
    if ([WXApi sendReq:req]){
        
    }
}

// AppDelegate 中实现了
//-(void)onResp:(BaseResp *)resp{
//    /*
//     ErrCode ERR_OK = 0(用户同意)
//     ERR_AUTH_DENIED = -4（用户拒绝授权）
//     ERR_USER_CANCEL = -2（用户取消）
//     code    用户换取access_token的code，仅在ErrCode为0时有效
//     state   第三方程序发送时用来标识其请求的唯一性的标志，由第三方程序调用sendReq时传入，由微信终端回传，state字符串长度不能超过1K
//     lang    微信客户端当前语言
//     country 微信用户当前国家信息
//     */
//    int errorCode = resp.errCode;
//    if (errorCode==0) {
//        SendAuthResp *r = (SendAuthResp*)resp;
//        NSString *code = r.code;
//        NSString *state = r.state;
//        if ([state isEqualToString:_wxState]) {
//            [self getWxAccessToken:kShare_WeixinAppKey secret:kShare_WeixinAppSecret code:code grant_type:@"authorization_code"];
//        }else{
//            [SVProgressHUD showErrorWithStatus:@"本地状态码不对应"];
//        }
//    }else{
//        [SVProgressHUD showErrorWithStatus:resp.errStr];
//    }
//    
//}

// 第二部，获取token,授权登录后会发送一个通知调用此方法
-(void)getWxAccessToken:(NSNotification*)notification{
    WEAKSELF
    NSString *code = notification.userInfo[@"code"];
    NSString *url = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",kShare_WeixinAppKey,kShare_WeixinAppSecret,code];
    AFHTTPSessionManager *manager = [http requestManager];
    // 开始请求
    [manager GET:url
      parameters:nil
        progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSDictionary *dic = (NSDictionary*)responseObj;
             
             NSString *accessToken = dic[@"access_token"];
             NSString *openId = dic[@"openid"];
             // 提取第三方登录后返回的用户资料
             if (accessToken && openId) {
                 [FMUserDefault setWXOpenId:openId];
                 [FMUserDefault setWXAccessToken:accessToken];
                 // 获取完授权，第一次登录即为注册，所以要提取用户资料
                 [__weakSelf getWxUserInfo];
             
             }else{
                 [SVProgressHUD showErrorWithStatus:@"微信获取授权失败"];
             }
             
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             [SVProgressHUD showErrorWithStatus:@"获取微信令牌出现网络问题"];
         }];
    
}
// 获取微信用户资料
-(void)getWxUserInfo{
    WEAKSELF
    NSString *accessToken = [FMUserDefault getWXAccessToken];
    NSString *openID = [FMUserDefault getWXOpenId];
    NSString *url = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@", accessToken, openID];
    AFHTTPSessionManager *manager = [http requestManager];
    // 开始请求
    [manager GET:url
      parameters:nil
        progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSDictionary *dic = (NSDictionary*)responseObj;
             // 提取第三方登录后返回的用户资料
             NSString *nickName = dic[@"nickname"];
             NSString *userFace = dic[@"headimgurl"];
             // 取132尺寸
             if (userFace && nickName) {
//                 userFace = [userFace replaceAll:@"/0" target:@"/132"];
                 // 保存
                 [FMUserDefault setUserFace:userFace];
                 [FMUserDefault setNickName:nickName];
                 // 获取完用户资料，注册并登录
                 [__weakSelf weixinLoginMyService];
                 
             }else{
                 [SVProgressHUD showErrorWithStatus:@"获取微信资料失败"];
             }
             
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             [SVProgressHUD showErrorWithStatus:@"获取微信令牌出现网络问题"];
         }];
}

// 微信登录完成，获取到用户资料后，登录一次我们自己的服务器
-(void)weixinLoginMyService{
    WEAKSELF
    NSString *openId = [FMUserDefault getWXOpenId];
    NSString *accessToken = [FMUserDefault getWXAccessToken];
    // 登录自己的服务器，如果服务器已经注册那么就不管了
    [http sendOtherLoginWithQQOpenId:nil QQAccessToken:nil WeiXinOpenId:openId WeiXinAccessToken:accessToken start:^{
        
    } failure:^{
        [SVProgressHUD showErrorWithStatus:@"登录服务器时网络不给力"];
    } success:^(NSDictionary*dic){
        BOOL success = [[dic objectForKey:@"success"] boolValue];
        if (success) {
            NSDictionary *user = [dic objectForKey:@"data"];
            if ([[user class] isSubclassOfClass:[NSDictionary class]]) {
                [FMUserDefault setUserWithDic:user];
                [SVProgressHUD showSuccessWithStatus:@"登陆成功"];
                // 启动下载用户自选数据
                [[FMBackgroundRun instance] firstDownloadMySelfStocksWithBlock:nil];
                
                NSString *tel = [FMUserDefault getMobile];
                if (!tel || [tel isEqualToString:@""]) {
                    if (__weakSelf.finishedLoginBlock) {
                        [__weakSelf performSelector:@selector(returnBack) withObject:nil afterDelay:1];
                        return ;
                    }
                    // 判断是否绑定手机号，如果没有绑定手机号就跳到绑定手机号界面，如果一绑定就跳回我界面显示已经登录状态
                    FMEditMeViewController *edit = [[FMEditMeViewController alloc] init];
                    [__weakSelf.navigationController pushViewController:edit animated:YES];
                }else{
                    [__weakSelf performSelector:@selector(returnBack) withObject:nil afterDelay:1];
                }
            }else{
                [SVProgressHUD showErrorWithStatus:@"服务器有误"];
            }
        }else{
            NSString *msg = [dic objectForKey:@"msg"];
            [SVProgressHUD showErrorWithStatus:msg];
        }
        
    }];
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

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    if (!_sectionHeaderView) {
        _sectionHeaderView = [[FMSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, kFMLoginViewSectionHeight)];
        _sectionHeaderView.backgroundColor = [UIColor clearColor];
        _sectionHeaderView.section = section;
        _sectionHeaderView.tableView = tableView;
        UILabel *l = [UILabel createWithTitle:[NSString stringWithFormat:@"%@通行证登陆",[fn getAppName]]
                                        Frame:CGRectMake(kTableViewCellLeftPadding   ,kFMLoginViewSectionHeight-25,UIScreenWidth-kTableViewCellLeftPadding,15)];
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
            _userNameTf = [UITextField createInputTextWithFrame:CGRectMake(kTableViewCellLeftPadding, 0, UIScreenWidth-kTableViewCellLeftPadding, kTableViewCellHeight) PlaceHolder:@"手机号登录"];
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
            _findPasswordBt = [UIButton createWithTitle:@"忘记密码？" Frame:CGRectMake(UIScreenWidth- kTableViewCellLeftPadding-80, 0, 80, kTableViewCellDefaultHeight)];
            [_findPasswordBt setTitleColor:FMBlueColor forState:UIControlStateNormal];
            UIImage *icon = ThemeImage(@"me/me_login_password_normal");
            icon = [UIImage imageWithTintColor:FMGreyColor blendMode:kCGBlendModeDestinationIn WithImageObject:icon];
            UIButton *left = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, kTableViewCellDefaultHeight)];
            [left setImage:icon forState:UIControlStateNormal];
            _passwordTf.leftView = left;
            _passwordTf.leftViewMode = UITextFieldViewModeAlways;
            [cell.contentView addSubview:_findPasswordBt];
            _passwordTf.delegate = self;
            [_findPasswordBt addTarget:self action:@selector(findPasswordHandle:) forControlEvents:UIControlEventTouchUpInside];
       
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
    if (textField==_passwordTf) _findPasswordBt.hidden = NO;
    textField.text = @"";
    [self changeLoginButtonTextColor];
    return YES;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField==_passwordTf) {
        if (textField.text.length==1 && [string isEqualToString:@""]) {
            _findPasswordBt.hidden = NO;
        }else{
            _findPasswordBt.hidden = YES;
        }
    }
    
    [self changeLoginButtonTextColor];
    
    return YES;
}

#pragma mark -
#pragma mark Http Request

//  登陆
-(void)sendHttpUserLogin{
    NSString *password = _passwordTf.text;
    NSString *tel = _userNameTf.text;
    [http sendUserLoginWithTel:tel password:password start:^{
        [SVProgressHUD show];
    } failure:^{
        [SVProgressHUD showErrorWithStatus:@"网络不给力"];
    } success:^(NSDictionary*dic){
        //[SVProgressHUD dismiss];
        BOOL success = [[dic objectForKey:@"success"] boolValue];
        if (success) {
            [FMUserDefault setUserWithDic:[dic objectForKey:@"data"]];
            [SVProgressHUD showSuccessWithStatus:@"登陆成功"];
            // 启动下载用户自选数据
            [[FMBackgroundRun instance] firstDownloadMySelfStocksWithBlock:nil];
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

//  发送注册
-(void)sendHttpUserRegister{
    NSString *_tel = _userNameTf.text;
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

@end
