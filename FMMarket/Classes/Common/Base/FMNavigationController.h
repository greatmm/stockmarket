//
//  FMNavigationController.h
//  FMMarket
//
//  Created by dangfm on 15/8/7.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FMNavigationController : UINavigationController
@property (nonatomic,retain) UIView *line;
-(void)changeLineBackgroundColor:(UIColor*)color;
@end
