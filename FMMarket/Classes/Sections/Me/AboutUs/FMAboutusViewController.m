//
//  FMAboutusViewController.m
//  FMMarket
//
//  Created by dangfm on 15/10/2.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMAboutusViewController.h"

@interface FMAboutusViewController ()

@end

@implementation FMAboutusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"关于我们" IsBack:YES ReturnType:1];
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
    
    NSString *string = @"金融魔法师是一款股票行情APP，灵敏的BS信号捕捉能力，能够为您实时提供短期买卖信号。\n\nBS信号体现在K线图行情中，当系统检测到有BS信号出现时，将分别以紫色蓝色点标注在K线的上方和下方，其中紫色点标注在K线上方，表明即将进入下跌行情，蓝色点标注在K线下方，表明即将进入上涨行情，注意此信号表明的是短期涨跌行情，对长期行情发展并不适应，恳请投资者仔细斟酌使用。\n\n";
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
