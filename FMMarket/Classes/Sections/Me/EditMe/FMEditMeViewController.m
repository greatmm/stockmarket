//
//  FMEditMeViewController.m
//  FMMarket
//
//  Created by dangfm on 16/1/13.
//  Copyright © 2016年 dangfm. All rights reserved.
//

#import "FMEditMeViewController.h"
#import "FMTableView.h"
#import "FMSectionHeaderView.h"
#import "FMTableViewCell.h"
#import "FMMaskView.h"
#import "QBImagePickerController.h"
#import "VPImageCropperViewController.h"
#import "MyImagePickerViewController.h"
#import "FMJoinMobileViewController.h"

#define kFMMeViewUserFaceCellHeight 100
#define kFMMeunLoginTipTag 10110
#define kFMMeEditNickNameTag 10111

@interface FMEditMeViewController()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,VPImageCropperDelegate>

@property (nonatomic,retain) NSMutableArray *datas;
@property (nonatomic,retain) FMTableView *tableView;
@property (nonatomic,retain) FMSectionHeaderView *sectionHeaderView;

@end

@implementation FMEditMeViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initParams];
    [self createViews];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Init
-(void)initParams{
    _datas = [NSMutableArray new];
    [_datas addObject: @[]];
    [_datas addObject: @[]];
    
    // 注册下载头像完成更新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserViews) name:kUserDefaultUserFaceDownloadNotification object:nil];
    
    [self setTitle:@"个人信息" IsBack:YES ReturnType:1];
}

#pragma mark -
#pragma mark UI Create
-(void)createViews{
    [self createTableView];
    [self updateUserViews];
}

//  Create TableView
-(void)createTableView{
    self.view.backgroundColor = FMBgGreyColor;
    if (!_tableView) {
        _tableView = [[FMTableView alloc] initWithFrame:CGRectMake(0, self.point.y, UIScreenWidth, UIScreenHeight-self.point.y-kNavigationHeight) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = FMBgGreyColor;
        [self.view addSubview:_tableView];
        
        UIButton *logout = [UIButton createButtonWithTitle:@"注 销" Frame:CGRectMake(kTableViewCellLeftPadding, 20, UIScreenWidth-2*kTableViewCellLeftPadding, kUIButtonDefaultHeight)];
        logout.backgroundColor = FMRedColor;
        [logout setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [logout addTarget:self action:@selector(logoutHandle) forControlEvents:UIControlEventTouchUpInside];
        UIView *tbFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, 100)];
        tbFooter.backgroundColor = [UIColor clearColor];
        [tbFooter addSubview:logout];
        _tableView.tableFooterView = tbFooter;
        tbFooter = nil;
    }
}
-(void)updateUserViews{
    
    NSString *nickName = [FMUserDefault getNickName];
    NSString *tel = [FMUserDefault getMobile];
    if ([tel isEqualToString:@""] || !tel) {
        tel = @"请绑定手机号";
    }
    NSString *info = @"已登陆，点击可修改资料";
    UIImage *userFace = [FMUserDefault getUserFaceImage];
    NSDictionary *one = @{
                          @"title":@"头像",
                          @"icon":userFace,
                          @"push":@"",
                          @"intro":info
                          };
    [_datas replaceObjectAtIndex:0 withObject:@[one]];
    
    NSDictionary *two = @{
                          @"title":@"用户名",
                          @"icon":@"",
                          @"push":@"",
                          @"intro":nickName
                          };
    NSDictionary *three = @{
                            @"title":@"手机号",
                            @"icon":@"",
                            @"push":@"FMJoinMobileViewController",
                            @"intro":tel
                            };
    
    [_datas replaceObjectAtIndex:1 withObject:@[two,three]];
    
    [_tableView reloadData];
}

#pragma mark -
#pragma mark UI Action

-(void)returnBack{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)logoutHandle{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"注销提示"message:@"确定要注销登录吗？"delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = kFMMeunLoginTipTag;
    [alert show];
}

#pragma mark -
#pragma mark UIAlertDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==kFMMeunLoginTipTag) {
        if (buttonIndex==alertView.firstOtherButtonIndex) {
            // 确定退出
            [FMUserDefault loginOut];
            [self.navigationController popToRootViewControllerAnimated:YES];
            return;
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
    cell = [[FMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:cellIndentifier];
    //        cell.title.textColor = FMGreyColor;
    cell.title.font = kFont(16);
    
    NSDictionary *dic = (NSDictionary*)_datas[indexPath.section][indexPath.row];
    
    if (indexPath.section==0) {
        cell.leftImageWidth = kFMMeViewUserFaceCellHeight-20;
        UIImage *icon = [dic objectForKey:@"icon"];
        if (![[icon class] isSubclassOfClass:[UIImage class]]) {
            icon = ThemeImage([dic objectForKey:@"icon"]);
            if (indexPath.section>0) {
                icon = [UIImage imageWithTintColor:FMBlackColor blendMode:kCGBlendModeDestinationIn WithImageObject:icon];
            }
            
        }else{
//            icon = [UIImage imageByScalingAndCroppingForSourceImage:icon
//                                                         targetSize:ThemeImage(@"me/me_icon_userface_normal").size];
        }
        cell.leftImageView.image = icon;
        cell.leftImageView.frame = CGRectMake(UIScreenWidth-cell.leftImageWidth-30, kTableViewCellHeight, icon.size.width, icon.size.height);
        icon = nil;
        cell.isCorner = YES;
        
        NSString *title = [dic objectForKey:@"title"];
        UILabel *l = [UILabel createWithTitle:title Frame:CGRectMake(15,0, UIScreenWidth-15, kFMMeViewUserFaceCellHeight)];
        l.font = cell.title.font;
        
        l.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:l];
        l = nil;
    }
    
    
    if (indexPath.section==1) {
        cell.title.text = [dic objectForKey:@"title"];
        cell.leftImageWidth = 15;
        NSString *intro = [dic objectForKey:@"intro"];
        UILabel *l = [UILabel createWithTitle:intro Frame:CGRectMake(0,0, UIScreenWidth-30, kTableViewCellHeight)];
        l.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:l];
        l = nil;
    }
    
    
    cell.arrow.hidden = NO;
    if (indexPath.row>=([_datas[indexPath.section] count]-1)) {
        cell.isLast = YES;
    }
    dic = nil;
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section==0) {
        [self showUploadFaceView];
    }
    if (indexPath.section==1) {
        if (indexPath.row==0) {
            // 弹出修改昵称框框
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改昵称" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = kFMMeEditNickNameTag;
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            UITextField *nameField = [alert textFieldAtIndex:0];
            nameField.placeholder = @"请输入新昵称";
            //[[alert textFieldAtIndex:1] removeFromSuperview];
            [alert show];
        }
        if (indexPath.row == 1) {
            NSDictionary *dic = (NSDictionary*)_datas[indexPath.section][indexPath.row];
            NSString *intro = [dic objectForKey:@"intro"];
            if ([intro isEqualToString:@"请绑定手机号"]) {
                FMJoinMobileViewController *join = [[FMJoinMobileViewController alloc] init];
                [self.navigationController pushViewController:join animated:YES];
            }
            
        }
    }
}



#pragma mark - 0
#pragma mark 选择并上传图片代码块

-(void)showUploadFaceView{
    
    
    CGFloat h = 50;
    CGFloat y = 2*h+10;
    CGFloat w = UIScreenWidth;
    CGFloat x = 0;
    FMMaskView *mask = [[FMMaskView alloc] initWithAlpha:0.5 Height:3*h+10];
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
    NSArray *titles = @[@"拍照",@"从手机相册选择"];
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

    if (sender.tag==1) {
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
    if (sender.tag==0) {
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
            if ([[fileName class] isSubclassOfClass:[NSString class]]) {
                if (![fileName hasPrefix:@"http"]) {
                    fileName = kURL(fileName);
                }
                // 本地修改头像
                [FMUserDefault setUserFace:fileName];
                [FMUserDefault setUserFaceImage:image];
                // 更新一下
                [__weakSelf updateUserViews];
            }
            
            
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

@end
