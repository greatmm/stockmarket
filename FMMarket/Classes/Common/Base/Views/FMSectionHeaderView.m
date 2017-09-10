//
//  FMSectionHeaderView.m
//  FMMarket
//
//  Created by dangfm on 15/9/3.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMSectionHeaderView.h"

@implementation FMSectionHeaderView

- (void)setFrame:(CGRect)frame{
    CGRect sectionRect = [self.tableView rectForSection:self.section];
    CGRect newFrame = CGRectMake(CGRectGetMinX(frame),
                                 CGRectGetMinY(sectionRect),
                                 CGRectGetWidth(frame),
                                 CGRectGetHeight(frame));
    [super setFrame:newFrame];
}

@end
