//
//  FMSettingViewController.m
//  FMMarket
//
//  Created by dangfm on 15/8/7.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMSettingViewController.h"
#import "FMTableView.h"
#import "FMTableViewCell.h"
#import "FMSectionHeaderView.h"
#import "UILabel+stocking.h"

@interface FMSettingViewController ()
<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    
}

@property (nonatomic,retain) NSMutableArray *datas;
@property (nonatomic,retain) FMTableView *tableView;
@property (nonatomic,retain) FMSectionHeaderView *sectionHeaderView;
@end



@implementation FMSettingViewController

-(void)dealloc{
    NSLog(@"FMSettingViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initParams];
    [self createTableView];
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
    _datas = [NSMutableArray arrayWithArray:(NSArray*)ThemeJson(@"setting")];
    [self setTitle:@"设置" IsBack:YES ReturnType:1];
}

#pragma mark -
#pragma mark UI Create
-(void)createViews{
    [self createTableView];
}

//  Create TableView
-(void)createTableView{
    self.view.backgroundColor = FMBgGreyColor;
    if (!_tableView) {
        _tableView = [[FMTableView alloc] initWithFrame:CGRectMake(0, self.point.y, UIScreenWidth, UIScreenHeight-self.point.y) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = FMBgGreyColor;
        [self.view addSubview:_tableView];
    }
}

#pragma mark -
#pragma mark UI Action
-(void)clickSwitchButtonAction:(UISwitch*)sbt{
    if (!sbt.on) {
        [sbt setOn:NO animated:YES];
        [FMUserDefault setAPNS:NO];
    }else{
        [sbt setOn:YES animated:YES];
        [FMUserDefault setAPNS:YES];
    }
}

#pragma mark -
#pragma mark UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return kTableViewCellHeight;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{

    return kFMTableViewSectionDefaultHeight;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _datas.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_datas[section] count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    _sectionHeaderView = [[FMSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, kFMTableViewSectionDefaultHeight)];
    _sectionHeaderView.backgroundColor = [UIColor clearColor];
    _sectionHeaderView.section = section;
    _sectionHeaderView.tableView = tableView;
    [fn drawLineWithSuperView:_sectionHeaderView Color:FMBottomLineColor Location:1];
    return _sectionHeaderView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = (NSDictionary*)_datas[indexPath.section][indexPath.row];
    NSString *cellIndentifier = [NSString stringWithFormat:@"cell_%d_%d",(int)indexPath.section,(int)indexPath.row];
    FMTableViewCell *cell = [[FMTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:cellIndentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.intro.textColor = FMBlackColor;
    cell.leftImageWidth = 15;
    if ([dic objectForKey:@"switch"]) {
        // 开关
        UISwitch *sbt = [[UISwitch alloc] init];
        sbt.frame = CGRectMake(UIScreenWidth-sbt.frame.size.width-15, (kTableViewCellHeight-sbt.frame.size.height)/2, sbt.frame.size.width, sbt.frame.size.height);
        sbt.tag = 100;
        [cell.contentView addSubview:sbt];
        [sbt addTarget:self action:@selector(clickSwitchButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [sbt setOn:[FMUserDefault isAPNS]];
        sbt = nil;
    }
    if ([[dic objectForKey:@"title"] isEqualToString:@"清理缓存"]) {
        //float cacheSize = [EGOCache globalCache] ;
        float m = [fn folderSizeAtPath:[fn realPathWithFileName:@"" Path:@"/"]];
        NSLog(@"文件夹大小:%f M",m);
        UILabel *l = [UILabel createWithTitle:[NSString stringWithFormat:@"%.2f M",m] Frame:CGRectMake(0,0, UIScreenWidth-15, kTableViewCellHeight)];
        l.textAlignment = NSTextAlignmentRight;
        [cell.contentView addSubview:l];
        l = nil;
    }
    
    cell.title.text = [dic objectForKey:@"title"];
    if (![[dic objectForKey:@"push"] isEqualToString:@""]) {
        cell.arrow.hidden = NO;
    }
    if (indexPath.row>=([_datas[indexPath.section] count]-1)) {
        cell.isLast = YES;
    }
    UISwitch *sbt = (UISwitch*)[cell.contentView viewWithTag:100];
    [sbt setOn:[FMUserDefault isAPNS]];
    sbt = nil;
    dic = nil;
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *dic = (NSDictionary*)_datas[indexPath.section][indexPath.row];
    NSString *controller = [dic objectForKey:@"push"];
    NSString *title = [dic objectForKey:@"title"];
    if ([title isEqualToString:@"清理缓存"]) {
        [SVProgressHUD showInfoWithStatus:@"正在清理..."];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            [fn deleteFolderAtPath:[fn realPathWithFileName:@"" Path:@"/"]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [SVProgressHUD showSuccessWithStatus:@"缓存清理成功"];
                [_tableView reloadData];
            });
        });
        
        return;
    }
    if ([title isEqualToString:@"AppStore 评分"]) {
        NSString *str = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",kAppStoreID];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
        return;
    }
    if (controller && ![controller isEqualToString:@""]) {
        Class clazz = NSClassFromString(controller);
        FMBaseViewController * vc = [[clazz alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        vc = nil;
        clazz = nil;
    }
    
    controller = nil;
}

#pragma mark -
#pragma mark UIAlertDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==alertView.firstOtherButtonIndex) {
        // 确定退出
        [FMUserDefault loginOut];
    }
}

@end
