//
//  MyImagePickerViewController.m
//  DFMMessage
//
//  Created by 21tech on 14-6-19.
//  Copyright (c) 2014年 dangfm. All rights reserved.
//

#import "MyImagePickerViewController.h"

@interface MyImagePickerViewController ()

@end

@implementation MyImagePickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    self.navigationBar.backgroundColor = FMNavColor;
    self.navigationBar.tintColor = [UIColor whiteColor];
    CGFloat w = self.view.frame.size.width;
    CGFloat h = 44;
    h += 22;
    self.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:FMNavColor andSize:CGSizeMake(w, h)] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.barStyle = UIBarStyleBlack;
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
