//
//  FMTableView.m
//  FMMarket
//
//  Created by dangfm on 15/8/8.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMTableView.h"

@implementation FMTableView

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    if (self==[super initWithFrame:frame style:style]) {
        [self initViews];
    }
    return self;
}

-(void)initViews{
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}


@end
