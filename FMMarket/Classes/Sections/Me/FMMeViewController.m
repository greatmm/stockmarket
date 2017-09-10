//
//  FMMeViewController.m
//  FMMarket
//
//  Created by dangfm on 15/9/2.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMMeViewController.h"
#import "FMTableView.h"
#import "FMTableViewCell.h"
#import "FMSectionHeaderView.h"
#import "FMLoginViewController.h"
#import "FMMaskView.h"
#import "QBImagePickerController.h"
#import "VPImageCropperViewController.h"
#import "MyImagePickerViewController.h"
#import "FMWebViewController.h"
//#import "FMTacticsListViewController.h"
//#import "FMCommunityViewController.h"
#import "FMEditMeViewController.h"

#define kFMMeLoginTipTag 10010101
#define kFMMeunLoginTipTag 10010102
#define kFMMeEditNickNameTag 10010103

@interface FMMeViewController ()
<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,VPImageCropperDelegate>
{
    
}
@property (nonatomic,assign) BOOL isRefreshing;
@property (nonatomic,assign) int unReadCount;
@property (nonatomic,retain) NSMutableArray *datas;
@property (nonatomic,retain) FMTableView *tableView;
@property (nonatomic,retain) FMSectionHeaderView *sectionHeaderView;
@end

@implementation FMMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initParams];
    [self createTableView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (_tableView) {
        [self updateUserViews];
        [self getHttpUserUnReadCount];
    }
    // 开启定时任务，检查对方是否发消息过来
    [self runTimer:5];
//    self.donotCloseTimer = YES; // 不要关闭定时器
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Init
-(void)initParams{
    _datas = [NSMutableArray arrayWithArray:(NSArray*)ThemeJson(@"me")];
    [self setTitle:@"我" IsBack:NO ReturnType:0];
    // 注册下载头像完成更新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserViews) name:kUserDefaultUserFaceDownloadNotification object:nil];
}

#pragma mark -
#pragma mark UI Create
-(void)createViews{
    [self createTableView];
}

//  Create TableView
-(void)createTableView{
    if (!_tableView) {
        _tableView = [[FMTableView alloc] initWithFrame:CGRectMake(0, self.point.y, UIScreenWidth, UIScreenHeight-self.point.y-kTabBarNavigationHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = FMBgGreyColor;
        [self.view addSubview:_tableView];
    }
}

-(void)updateUserViews{
    
    if ([[FMUserDefault getUserId] floatValue]>0) {
        NSString *nickName = [FMUserDefault getNickName];
        NSString *info = @"已登陆，点击可修改资料";
        UIImage *userFace = [FMUserDefault getUserFaceImage];
        NSDictionary *first = @{
                                @"title":nickName,
                                @"icon":userFace,
                                @"push":@"",
                                @"intro":info
                                };
        [_datas replaceObjectAtIndex:0 withObject:@[first]];
        
    }else{
        [_datas removeAllObjects];
        _datas = [NSMutableArray arrayWithArray:(NSArray*)ThemeJson(@"me")];
    }
    [_tableView reloadData];
}


#pragma mark -
#pragma mark UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        if (indexPath.row==0) {
            return kFMMeViewUserFaceCellHeight;
        }
    }
    return kTableViewCellHeight;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return 0;
    }
    return kFMTableViewSectionDefaultHeight;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _datas.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_datas[section] count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return nil;
    }
    _sectionHeaderView = [[FMSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, kFMTableViewSectionDefaultHeight)];
    _sectionHeaderView.backgroundColor = [UIColor clearColor];
    _sectionHeaderView.section = section;
    _sectionHeaderView.tableView = tableView;
    [fn drawLineWithSuperView:_sectionHeaderView Color:FMBottomLineColor Location:1];
    return _sectionHeaderView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIndentifier = [NSString stringWithFormat:@"cell_%d_%d",(int)indexPath.row,(int)indexPath.section];
    FMTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[FMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:cellIndentifier];
        cell.intro.textColor = FMGreyColor;
        cell.leftImageWidth = 60;
    }
    
    NSDictionary *dic = (NSDictionary*)_datas[indexPath.section][indexPath.row];
    cell.title.text = [dic objectForKey:@"title"];
    UIImage *icon = [dic objectForKey:@"icon"];
    if (![[icon class] isSubclassOfClass:[UIImage class]]) {
        icon = ThemeImage([dic objectForKey:@"icon"]);
        if (indexPath.section>0) {
            icon = [UIImage imageWithTintColor:FMBlackColor blendMode:kCGBlendModeDestinationIn WithImageObject:icon];
        }
        
    }else{
//        UIImage *img = ThemeImage(@"me/me_icon_userface_normal");
//        icon = [UIImage imageByScalingAndCroppingForSourceImage:icon
//                                                     targetSize:img.size];
    }
//    cell.imageView.image = icon;
    if (indexPath.row == 0 && indexPath.section==0) {
        cell.leftImageWidth = 70;
        cell.isCorner = YES;
        cell.isAutoReSizeImage = YES;
        cell.leftImageView.image = icon;
        cell.arrow.hidden = NO;
    }else{
        cell.leftImageWidth = 60;
        cell.imageView.image = icon;
    }
    
    icon = nil;
    if (indexPath.row==0&&indexPath.section==1) {
        int unCount = _unReadCount;
        cell.unReadLb.text = [NSString stringWithFormat:@"%d",(int)unCount];
        
        if (unCount<=0) {
            cell.unReadLb.hidden = YES;
        }else{
            cell.unReadLb.hidden = NO;
        }
    }
    cell.intro.text = [dic objectForKey:@"intro"];
    
    if (![[dic objectForKey:@"push"] isEqualToString:@""] && indexPath.section>0) {
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
    NSString *controller = [dic objectForKey:@"push"];
    NSString *title = [dic objectForKey:@"title"];
    
    if (controller && ![controller isEqualToString:@""]) {
        
        if ([title isEqualToString:@"模拟交易"] ||
            [title isEqualToString:@"私信消息"] ||
            [title isEqualToString:@"我的关注"] ||
            [title isEqualToString:@"我的粉丝"] ||
            [title isEqualToString:@"我的策略"] ||
            [title isEqualToString:@"我的话题"]) {
            // 如果用户已登陆则弹出登出提示
            if ([[FMUserDefault getUserId] floatValue]<=0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                message:[NSString stringWithFormat:@"%@需要登录才能操作",title]
                                                               delegate:self
                                                      cancelButtonTitle:@"取消"
                                                      otherButtonTitles:@"确定", nil];
                alert.tag = kFMMeLoginTipTag;
                [alert show];
                return;
            }
            
        }
        

        
        if ([title isEqualToString:@"关于我们"]) {
            FMWebViewController *web = [[FMWebViewController alloc] initWithTitle:title url:[NSURL URLWithString:[kAPI_AboutUs stringByAppendingFormat:@"&v=%@",[fn getVersion]]] returnType:1];
            [self.navigationController pushViewController:web animated:YES];
            web = nil;
            return;
        }
        if ([title isEqualToString:@"风险提示"]) {
            FMWebViewController *web = [[FMWebViewController alloc] initWithTitle:title url:[NSURL URLWithString:[kAPI_DangerTip stringByAppendingFormat:@"&v=%@",[fn getVersion]]] returnType:1];
            [self.navigationController pushViewController:web animated:YES];
            web = nil;
            return;
        }
        
        
        Class clazz = NSClassFromString(controller);
        FMBaseViewController * vc = [[clazz alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        vc = nil;
        clazz = nil;
    }
    if (indexPath.row==0 && indexPath.section==0) {
        // 如果用户已登陆则弹出登出提示
        if ([[FMUserDefault getUserId] floatValue]>0) {
            // 点击头像显示上传头像
//            [self showUploadFaceView];
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注销提示"
//                                                            message:@"确定要注销登录吗？"
//                                                           delegate:self
//                                                  cancelButtonTitle:@"取消"
//                                                  otherButtonTitles:@"确定", nil];
//            alert.tag = kFMMeunLoginTipTag;
//            [alert show];
            FMEditMeViewController *edit = [[FMEditMeViewController alloc] init];
            [self.navigationController pushViewController:edit animated:YES];
        }
    }
    
    controller = nil;
}
#pragma mark - UI Action

-(void)timerAction{
    if (_isRefreshing) {
        return;
    }
    
//    [self getHttpUserUnReadCount];
}

#pragma mark -
#pragma mark UIAlertDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==kFMMeunLoginTipTag) {
        if (buttonIndex==alertView.firstOtherButtonIndex) {
            // 确定退出
            [FMUserDefault loginOut];
            [self updateUserViews];
            
        }
    }
    if (alertView.tag==kFMMeLoginTipTag) {
        if (buttonIndex==alertView.firstOtherButtonIndex) {
            // 确定登录按钮
            FMLoginViewController *login = [[FMLoginViewController alloc] init];
            [self.navigationController pushViewController:login animated:YES];
            login = nil;
        }
    }
    
    if (alertView.tag==kFMMeEditNickNameTag) {
        if (buttonIndex==alertView.firstOtherButtonIndex) {
            // 确定修改昵称
            UITextField *nameField = [alertView textFieldAtIndex:0];
            NSString *nickName = nameField.text;
            [self updateHttpNickName:nickName];
        }
    }
}


#pragma mark - 0
#pragma mark 选择并上传图片代码块

-(void)showUploadFaceView{
    
    
    CGFloat h = 50;
    CGFloat y = 4*h+10;
    CGFloat w = UIScreenWidth;
    CGFloat x = 0;
    FMMaskView *mask = [[FMMaskView alloc] initWithAlpha:0.5 Height:5*h+10];
    mask.sportView.backgroundColor = FMBottomLineColor;
    // 取消按钮
    UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
    bt.backgroundColor = [UIColor clearColor];
    [bt setTitle:@"取消" forState:UIControlStateNormal];
    [bt setTitleColor:FMBlackColor forState:UIControlStateNormal];
    [bt setTitleColor:FMBlackColor forState:UIControlStateHighlighted];
    [bt setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor] andSize:CGSizeMake(w, h)] forState:UIControlStateNormal];
    [bt setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor] andSize:CGSizeMake(w, h)] forState:UIControlStateHighlighted];
    
    [bt addTarget:mask action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
    [mask.sportView addSubview:bt];
    bt = nil;
    //两个按钮
    NSArray *titles = @[@"修改昵称",@"拍照",@"从手机相册选择",@"注销登录"];
    y = 0;
    
    for (int i=0; i<titles.count; i++) {
        UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
        b.tag = i;
        [b setTitle:[titles objectAtIndex:i] forState:UIControlStateNormal];
        [b setTitleColor:FMBlackColor forState:UIControlStateNormal];
        [b setTitleColor:FMBlackColor forState:UIControlStateHighlighted];
        [b setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor] andSize:CGSizeMake(w, h)] forState:UIControlStateHighlighted];
        [b setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor] andSize:CGSizeMake(w, h)] forState:UIControlStateNormal];
        [b addTarget:self action:@selector(clickUploadButtonWithIndex:) forControlEvents:UIControlEventTouchUpInside];
        [mask.sportView addSubview:b];
        b = nil;
        y += h + 1;
    }
    [mask show:nil];
    mask.hideFinishBlock = ^{
        
    };
    mask = nil;
    titles = nil;
}

// 选择图片按钮
-(void)clickUploadButtonWithIndex:(UIButton *)sender{
    WEAKSELF
    // 选择相册
    FMMaskView *mask = (FMMaskView*)[[sender superview] superview];
    // 修改昵称
    if (sender.tag==0) {
        // 弹出修改昵称框框
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改昵称" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = kFMMeEditNickNameTag;
        [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
        UITextField *nameField = [alert textFieldAtIndex:0];
        nameField.placeholder = @"请输入新昵称";
        //[[alert textFieldAtIndex:1] removeFromSuperview];
        [alert show];
        [mask hide];
    }
    if (sender.tag==2) {
        if (![QBImagePickerController isAccessible]) {
            NSLog(@"Error: Source is not accessible.");
        }else{
            mask.hideFinishBlock = ^{
                // 系统相册
                [__weakSelf initUIImagePickerController];
            };
            [mask hide];
        }
    }
    // 选择相机
    if (sender.tag==1) {
        mask.hideFinishBlock = ^{
            if ([__weakSelf isCameraAvailable] && [__weakSelf doesCameraSupportTakingPhotos]) {
                UIImagePickerController *controller = [[UIImagePickerController alloc] init];
                controller.sourceType = UIImagePickerControllerSourceTypeCamera;
                if ([__weakSelf isFrontCameraAvailable]) {
                    controller.cameraDevice = UIImagePickerControllerCameraDeviceFront;
                }
                NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
                [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
                controller.mediaTypes = mediaTypes;
                controller.delegate = __weakSelf;
                [__weakSelf presentViewController:controller
                                   animated:YES
                                 completion:^(void){
                                     NSLog(@"Picker View Controller is presented");
                                 }];
            }
        };
        [mask hide];
    }
    // 注销登录
    if (sender.tag==3) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注销提示"message:@"确定要注销登录吗？"delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = kFMMeunLoginTipTag;
        [alert show];
        [mask hide];
    }
}

// 判断相机相册是否可用等
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

//- (BOOL) isRearCameraAvailable{
//    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
//}

- (BOOL) isFrontCameraAvailable {
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

- (BOOL) doesCameraSupportTakingPhotos {
    return [self cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypeCamera];
}

- (BOOL) isPhotoLibraryAvailable{
    return [UIImagePickerController isSourceTypeAvailable:
            UIImagePickerControllerSourceTypePhotoLibrary];
}
//- (BOOL) canUserPickVideosFromPhotoLibrary{
//    return [self
//            cameraSupportsMedia:(__bridge NSString *)kUTTypeMovie sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
//}
//- (BOOL) canUserPickPhotosFromPhotoLibrary{
//    return [self
//            cameraSupportsMedia:(__bridge NSString *)kUTTypeImage sourceType:UIImagePickerControllerSourceTypePhotoLibrary];
//}

- (BOOL) cameraSupportsMedia:(NSString *)paramMediaType sourceType:(UIImagePickerControllerSourceType)paramSourceType{
    __block BOOL result = NO;
    if ([paramMediaType length] == 0) {
        return NO;
    }
    NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:paramSourceType];
    [availableMediaTypes enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *mediaType = (NSString *)obj;
        if ([mediaType isEqualToString:paramMediaType]){
            result = YES;
            *stop= YES;
        }
    }];
    return result;
}

// 初始化一个图片选择控制器
-(void)initUIImagePickerController{
    if ([self isPhotoLibraryAvailable]) {
        MyImagePickerViewController *controller = [[MyImagePickerViewController alloc] init];
        controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        NSMutableArray *mediaTypes = [[NSMutableArray alloc] init];
        [mediaTypes addObject:(__bridge NSString *)kUTTypeImage];
        controller.mediaTypes = mediaTypes;
        controller.delegate = self;
        [self presentViewController:controller
                           animated:YES
                         completion:^(void){
                             NSLog(@"Picker View Controller is presented");
                         }];
    }
}

#pragma mark - 2
#pragma mark VPImageCropperDelegate
// 裁减后得到图片
- (void)imageCropper:(VPImageCropperViewController *)cropperViewController didFinished:(UIImage *)editedImage {
    // 拿到裁剪后的图片 editedImage;
    WEAKSELF
    //editedImage = [UIImage imageByScalingToMaxSize:editedImage];
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        // 上传图片
        [__weakSelf uploadUserFace:editedImage];
    }];
}

- (void)imageCropperDidCancel:(VPImageCropperViewController *)cropperViewController {
    [cropperViewController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - 1
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //[picker dismissViewControllerAnimated:YES completion:^() {
    UIImage *portraitImg = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    // 相册拿到图片则调用裁剪控件
    VPImageCropperViewController *imgCropperVC = [[VPImageCropperViewController alloc] initWithImage:portraitImg cropFrame:CGRectMake(0, 100.0f, self.view.frame.size.width, self.view.frame.size.width) limitScaleRatio:3.0];
    imgCropperVC.delegate = self;
    [picker pushViewController:imgCropperVC animated:YES];
    //}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^(){
        
        
    }];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // bug fixes: UIIMagePickerController使用中偷换StatusBar颜色的问题
    if ([navigationController isKindOfClass:[UIImagePickerController class]] &&
        ((UIImagePickerController *)navigationController).sourceType ==     UIImagePickerControllerSourceTypePhotoLibrary) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    }
}

#pragma mark - 3
#pragma mark 上传头像

-(void)uploadUserFace:(UIImage*)image{
    WEAKSELF
    [http uploadUserFaceWithImage:image start:^{
        [SVProgressHUD showWithStatus:@"正在上传..."];
    } failure:^{
        [SVProgressHUD showErrorWithStatus:@"网络不给力"];
    } success:^(NSDictionary*dic){
        BOOL success = [dic[@"success"]boolValue];
        if (success) {
            [SVProgressHUD showSuccessWithStatus:@"上传成功"];
            NSString *fileName = dic[@"data"];
            fileName = kURL(fileName);
            // 本地修改头像
            [FMUserDefault setUserFace:fileName];
            [FMUserDefault setUserFaceImage:image];
            // 更新一下
            [__weakSelf updateUserViews];
        }else{
            NSString *msg = dic[@"msg"];
            [SVProgressHUD showErrorWithStatus:msg];
        }
    }];
}

/**
 *  修改昵称
 *
 *  @param nickName 新昵称
 */
-(void)updateHttpNickName:(NSString*)nickName{
    nickName = [nickName trim];
    if ([nickName isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"昵称不能为空"];
        return;
    }
    WEAKSELF
//    nickName = [[nickName dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    [http updateNickName:nickName start:^{
        [SVProgressHUD showWithStatus:@"正在发送..."];
    } failure:^{
        [SVProgressHUD showErrorWithStatus:@"网络不给力"];
    } success:^(NSDictionary*dic){
        BOOL success = [dic[@"success"]boolValue];
        if (success) {
            [SVProgressHUD showSuccessWithStatus:@"修改成功"];
            // 本地修改昵称
            [FMUserDefault setSeting:kUserDefault_NickName Value:nickName];
            // 更新一下
            [__weakSelf updateUserViews];
        }else{
            NSString *msg = dic[@"msg"];
            [SVProgressHUD showErrorWithStatus:msg];
        }
    }];
}

#pragma mark - Http
-(void)getHttpUserUnReadCount{
    if ([[FMUserDefault getUserId]intValue]<=0) {
        return;
    }
    _isRefreshing = YES;
    WEAKSELF
    [http getUsersUnReadCountWithFromUserId:nil Start:^{
        NSLog(@"me请求未读消息数");
    } failure:^{
        __weakSelf.isRefreshing = NO;
    } success:^(NSDictionary*dic){
        NSString *count = [NSString stringWithFormat:@"%@",dic[@"data"]];
        __weakSelf.unReadCount = [count intValue];
        [__weakSelf updateUserViews];
        __weakSelf.isRefreshing = NO;
        NSLog(@"me未读消息数%@",count);
        // 更新tabBar圆点
        [FMAppDelegate shareApp].main.systemUnreadCount = [count intValue];
        [[FMAppDelegate shareApp].main refreshSettingBadge];
        
    }];
}

@end
