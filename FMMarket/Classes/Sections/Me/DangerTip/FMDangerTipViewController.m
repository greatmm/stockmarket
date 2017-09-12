//
//  FMDangerTipViewController.m
//  FMMarket
//
//  Created by dangfm on 15/10/2.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMDangerTipViewController.h"

@interface FMDangerTipViewController ()

@end

@implementation FMDangerTipViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"风险提示" IsBack:YES ReturnType:1];
    [self createViews];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)createViews{
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(15,kNavigationHeight + kStatusBarHeight + 15, UIScreenWidth-30,UIScreenHeight-kNavigationHeight-kStatusBarHeight-15)];
    [self.view addSubview:l];
    
    NSString *string = @"金融魔法师提醒您正确全面了解手机炒股业务的风险，如果您继续使用，即表明您已经完全了解可能存在的风险，并同意承担业务存在的全部风险。\n\n股市有风险，投资需谨慎。\n\n金融魔法师仅在于为股民朋友提供股票信息查询业务以及仅提供股票投资参考，并不构成股票投资决策，恳请投资者对股市行情做详细认真的分析后再进行投资，谢谢支持！";
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName:kFont(16),NSForegroundColorAttributeName:[UIColor blackColor]}];
    NSMutableParagraphStyle *paragraphStyle = [[ NSMutableParagraphStyle alloc ] init ];
    paragraphStyle. alignment = NSTextAlignmentJustified ;
    //paragraphStyle. maximumLineHeight = 20 ;  //最大的行高
    paragraphStyle. lineSpacing = 5 ;  //行自定义行高度
    //[paragraphStyle setFirstLineHeadIndent:34]; //首行缩进
    [str addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange (0,string.length)];
    l.attributedText = str;
    l.numberOfLines = 0;
    [l sizeToFit];
    l.frame = CGRectMake(15,kNavigationHeight + kStatusBarHeight + 15, UIScreenWidth-30,l.frame.size.height);
                                                           
                                                          
}

@end
