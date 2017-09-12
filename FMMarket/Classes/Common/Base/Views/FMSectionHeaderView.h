//
//  FMSectionHeaderView.h
//  FMMarket
//
//  Created by dangfm on 15/9/3.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kFMTableViewSectionOtherHeight 30
@interface FMSectionHeaderView : UIView

@property NSUInteger section;
@property (nonatomic, weak) UITableView *tableView;

@end
