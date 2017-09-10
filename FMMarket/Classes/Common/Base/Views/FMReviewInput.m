//
//  FMReviewInput.m
//  FMMarket
//
//  Created by dangfm on 15/12/18.
//  Copyright © 2015年 dangfm. All rights reserved.
//

#import "FMReviewInput.h"

@interface FMReviewInput()
<UITextViewDelegate>
{
}

@end

@implementation FMReviewInput

-(instancetype)initWithFrame:(CGRect)frame objectId:(NSString*)objectId reviewId:(NSString *)reviewId userName:(NSString *)name{
    if (self==[super initWithFrame:frame]) {
        _objectId = objectId;
        _reviewId = reviewId;
        _userName = name;
        [self createViews];
    }
    return self;
}

/**
 *  创建视图 编辑模式
 */
-(void)createViews{
    self.backgroundColor = [UIColor clearColor];
    float x = 0;
    float y = 0;
    float w = UIScreenWidth;
    float h = kFMReviewInputMaxHeight;
    // 蒙板
    _maskView = [[UIView alloc] initWithFrame:CGRectMake(x, y, w, UIScreenHeight)];
    _maskView.backgroundColor = [UIColor blackColor];
    _maskView.alpha = 0.5;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickMaskViewAction)];
    [_maskView addGestureRecognizer:tap];
    tap = nil;
    [self addSubview:_maskView];
    // 内容区域
    _mainView = [[UIView alloc] initWithFrame:CGRectMake(x, self.frame.size.height-kFMReviewInputDefaultHeight, w, kFMReviewInputDefaultHeight)];
    _mainView.backgroundColor = FMBottomLineColor;
//    [fn drawLineWithSuperView:_mainView Color:FMBottomLineColor Location:0];
    [self addSubview:_mainView];
    // 头部
    _titleBox = [[UIView alloc] initWithFrame:CGRectMake(x, y, UIScreenWidth, kFMReviewInputDefaultHeight)];
    _titleBox.backgroundColor = FMBgGreyColor;
//    [fn drawLineWithSuperView:_titleBox Color:FMBottomLineColor Location:0];
    // 放三个按钮
    [self createThreeButtonForTitleView];
    [_mainView addSubview:_titleBox];
    
    // 文本框
    _input = [[UITextView alloc] initWithFrame:CGRectMake(10, kFMReviewInputDefaultHeight, w, h-kFMReviewInputDefaultHeight)];
    _input.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    _input.delegate = self;
    _input.layer.cornerRadius = 3;
    // 提示文字
    _placeHolder = [UILabel createWithTitle:@"说点什么..." Frame:CGRectMake(12, 10, w-20, 15)];
    _placeHolder.textColor = FMBlackColor;
    [_input addSubview:_placeHolder];
    [_mainView addSubview:_input];
}

// 显示默认状态
-(void)defaultStatus{
    self.frame = CGRectMake(0, UIScreenHeight-kFMReviewInputDefaultHeight, UIScreenWidth, kFMReviewInputDefaultHeight);
    _maskView.hidden = YES;
    _mainView.frame = CGRectMake(0, 0, UIScreenWidth, kFMReviewInputDefaultHeight);
    
    _titleBox.hidden = YES;
    _input.frame = CGRectMake(15, 5, UIScreenWidth-30, 35);
    _input.textContainerInset = UIEdgeInsetsMake(0, 10, 10, 10);
    _input.text = @"";
    _placeHolder.frame = CGRectMake(12, 0, _input.frame.size.width-20, _input.frame.size.height);
    _placeHolder.text = @"说点什么...";
}

/**
 *  显示编辑状态
 *  @param h 键盘高度
 */
-(void)showEditing:(float)h{
    
    self.frame = CGRectMake(0, 0, UIScreenWidth, UIScreenHeight);
    _maskView.hidden = NO;
    _mainView.frame = CGRectMake(0, self.frame.size.height-kFMReviewInputMaxHeight-h, UIScreenWidth, kFMReviewInputMaxHeight);
    _titleBox.hidden = NO;
    _input.frame = CGRectMake(0, kFMReviewInputDefaultHeight, UIScreenWidth, kFMReviewInputMaxHeight-kFMReviewInputDefaultHeight);
    _input.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
    _placeHolder.frame = CGRectMake(12, 10, UIScreenWidth-20, 15);
    if (_userName &&
        ![_userName isEqualToString:@""] &&
        _reviewId &&
        ![_reviewId isEqualToString:@""])
    {
        _placeHolder.text = [NSString stringWithFormat:@"回复：%@ ",_userName];
        [_mindBt setTitle:@"回复" forState:UIControlStateNormal];
    }else{
        [_mindBt setTitle:@"评论" forState:UIControlStateNormal];
    }
}

/**
 *  头部搞三个按钮
 */
-(void)createThreeButtonForTitleView{
    NSArray *titles = @[@"关闭",@"评论",@"发送"];
    float x = 0;
    float y = 0;
    float w = UIScreenWidth/titles.count;
    float h = kFMReviewInputDefaultHeight;
    for (int i=0; i<titles.count; i++) {
        UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w , h)];
        bt.backgroundColor = [UIColor clearColor];
        [bt setTitle:titles[i] forState:UIControlStateNormal];
        bt.titleLabel.font = kFont(14);
        [bt setTitleColor:FMZeroColor forState:UIControlStateNormal];
        if (i==0) {
            [bt setTitleColor:FMYellowColor forState:UIControlStateNormal];
            [bt addTarget:self action:@selector(clickCloseButtonAction) forControlEvents:UIControlEventTouchUpInside];
            bt.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            bt.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        }
        if (i==2) {
            [bt setTitleColor:FMBlackColor forState:UIControlStateNormal];
            bt.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
            // 发送按钮
            _sendBt = bt;
            [bt addTarget:self action:@selector(clickSendButtonAction) forControlEvents:UIControlEventTouchUpInside];
            bt.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 15);
        }
        if (i==1){
            // 中间的按钮
            _mindBt = bt;
        }
        x += w;
        [_titleBox addSubview:bt];
        bt = nil;
    }
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([textView.text isEqualToString:@""]) {
        [_sendBt setTitleColor:FMBlackColor forState:UIControlStateNormal];
        
    }else{
        [_sendBt setTitleColor:FMBlueColor forState:UIControlStateNormal];
        _placeHolder.text = @"";
    }
    
    
    return YES;
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    _placeHolder.text = @"";
    
    return YES;
}

/**
 *  点击蒙板自动关闭
 */
-(void)clickMaskViewAction{
    [self clickCloseButtonAction];
}

/**
 *  点击关闭按钮
 */
-(void)clickCloseButtonAction{
    if (self.sendCloseBlock) {
        self.sendCloseBlock();
    }
}

/**
 *  点击发送按钮
 */
-(void)clickSendButtonAction{
    if ([[FMUserDefault getUserId]floatValue]<=0) {
        [fn showMessage:@"需要登录哦" Title:@"温馨提示" timeout:1];
        // 我的私信，未登入用户，提示需要用户登入，并直接跳转的登入页面。登入后返到我的私信页面。
        FMLoginViewController *login = [[FMLoginViewController alloc] initWithBackType:2 finishedLoginBlock:^{}];
        [[FMAppDelegate shareApp].main.currnetNav presentViewController:login animated:YES completion:nil];
        return;
    }
    NSString *content = _input.text;
    content = [content stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"回复：%@ ",_userName] withString:@""];
    if (content.length<2) {
        [SVProgressHUD showErrorWithStatus:@"内容太少哦"];
        return;
    }
    WEAKSELF
    [http sendCommunityPostsWithObjectId:_objectId content:_input.text postId:_reviewId Start:^{
        [SVProgressHUD show];
    } failure:^{
        [SVProgressHUD showErrorWithStatus:@"网络不给力"];
    } success:^(NSDictionary*dic){
        dic = [fn checkNullWithDictionary:dic];
        BOOL success = [dic[@"success"] boolValue];
        if (success) {
            [SVProgressHUD showSuccessWithStatus:@"发布成功"];
            // 完成回调
            if (__weakSelf.sendFinishBlock) {
                __weakSelf.sendFinishBlock(success,dic);
            }
        }else{
            NSString *msg = dic[@"msg"];
            if ([msg isEqualToString:@""]) {
                msg = @"发布失败";
            }
            [SVProgressHUD showErrorWithStatus:msg];
        }
        
    }];
}

@end
