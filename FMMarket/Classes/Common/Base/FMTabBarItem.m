//
//  FMTabBarItem.m
//  FMMarket
//
//  Created by dangfm on 15/8/7.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMTabBarItem.h"

@implementation FMTabBarItem

-(instancetype)initWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage{
    if ([super initWithTitle:title image:image selectedImage:selectedImage]) {
        // 调整下文字距离
        //[self setTitlePositionAdjustment:UIOffsetMake(0, -2)];
    }
    return self;
}
@end
