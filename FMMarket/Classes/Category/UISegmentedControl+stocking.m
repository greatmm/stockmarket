//
//  UISegmentedControl+stocking.m
//  FMMarket
//
//  Created by dangfm on 15/11/23.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "UISegmentedControl+stocking.h"

@implementation UISegmentedControl (stocking)

+(UISegmentedControl*)createWithTitles:(NSArray*)titles{
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:titles];
    segmentedControl.backgroundColor = FMRedColor;
    //默认选择
    segmentedControl.selectedSegmentIndex=0;
    //设置背景色
    segmentedControl.tintColor = [UIColor whiteColor];
    return segmentedControl;
}
@end
