//
//  FMFeedbackViewController.m
//  FMMarket
//
//  Created by dangfm on 15/10/2.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMFeedbackViewController.h"

@interface FMFeedbackViewController ()
<UITextViewDelegate,UITextFieldDelegate>
{
    UITextView *_content;
    UITextField *_email;
    UILabel *_placeholder;
}
@end

@implementation FMFeedbackViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self createViews];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.tabBarController.tabBar.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_content) {
        [_content becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark -
#pragma mark UI Create

-(void)createViews{
    [self setTitle:@"意见反馈" IsBack:YES ReturnType:1];
    [self createFinishButtonViews];
    [self createContentView];
    [self createEmailViews];
}

-(void)createFinishButtonViews{
    UIButton *finish = [[UIButton alloc] initWithFrame:CGRectMake(UIScreenWidth-80, 0, 80, kNavigationHeight)];
    [finish setTitle:@"发送" forState:UIControlStateNormal];
    [finish setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    finish.titleLabel.font = kFont(16);
    [self.header addSubview:finish];
    [finish addTarget:self
               action:@selector(sendMyFeedbackAction)
     forControlEvents:UIControlEventTouchUpInside];
    finish = nil;
}

-(void)createContentView{
    _content = [[UITextView alloc] initWithFrame:CGRectMake(15, kNavigationHeight+kStatusBarHeight+15, UIScreenWidth-30, (UIScreenWidth-30)*3/5)];
    _content.layer.borderColor = FMBottomLineColor.CGColor;
    _content.layer.borderWidth = 0.5;
    _content.layer.cornerRadius = 3;
    _content.delegate = self;
    _content.font = kDefaultFont;
    _content.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_content];
    
    _placeholder = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, _content.frame.size.width, 16)];
    _placeholder.text = @"期待您的意见噢～";
    _placeholder.textColor = FMBottomLineColor;
    _placeholder.font = _content.font;
    [_content addSubview:_placeholder];
}

-(void)createEmailViews{
    // 邮箱
    _email = [[UITextField alloc] initWithFrame:CGRectMake(15, _content.frame.size.height+_content.frame.origin.y+15, _content.frame.size.width, 35)];
    _email.font = kDefaultFont;
    _email.placeholder = @"您的邮箱：选填，以便我们给你回复";
    _email.leftViewMode = UITextFieldViewModeAlways;
    _email.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, _email.frame.size.height)];
    _email.delegate = self;
    _email.layer.borderColor = FMBottomLineColor.CGColor;
    _email.layer.borderWidth = 0.5;
    _email.layer.cornerRadius = 3;
    [self.view addSubview:_email];
}

#pragma mark -
#pragma mark UI Action
//  点击发送按钮
-(void)sendMyFeedbackAction{
    NSString *content = _content.text;
    NSString *email = _email.text;
    if (content.length<2) {
        [SVProgressHUD showErrorWithStatus:@"意见反馈太短哦～"];
        return;
    }
    if (content.length>200) {
        [SVProgressHUD showErrorWithStatus:@"意见反馈请限制200字符以内"];
        return;
    }
    [http sendFeedbackWithEmail:email content:content start:^{
        [SVProgressHUD show];
    } failure:^{
        [SVProgressHUD showSuccessWithStatus:@"网络不给力"];
    } success:^(NSDictionary *dic){
        BOOL success = [[dic objectForKey:@"success"] boolValue];
        NSString *msg = [dic objectForKey:@"msg"];
        
        if (success) {
            [SVProgressHUD showSuccessWithStatus:@"已发送"];
            [self performSelector:@selector(returnBack) withObject:nil afterDelay:1];
        }else{
            [SVProgressHUD showSuccessWithStatus:msg];
        }
    }];
}

#pragma mark -
#pragma mark UITextViewDelegate

-(void)textViewDidChange:(UITextView *)textView{
    if (textView.text.length<=0) {
        _placeholder.text = @"期待您的意见噢～";
    }else{
        _placeholder.text = @"";
    }
}
@end
