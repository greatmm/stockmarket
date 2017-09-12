//
//  FMStockAddButtonViews.m
//  FMMarket
//
//  Created by dangfm on 15/8/16.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMStockAddButtonViews.h"
#import "UIButton+stocking.h"
#import "UILabel+stocking.h"

@implementation FMStockAddButtonViews

-(instancetype)initWithFrame:(CGRect)frame{
    if (self==[super initWithFrame:frame]) {
        [self initViews];
    }
    return self;
}

-(void)initViews{
    self.backgroundColor = [UIColor whiteColor];
    CGFloat btHeight = 100;
    UIButton *addbutton = [UIButton createWithTitle:@"+"
                                              Frame:CGRectMake((UIScreenWidth-btHeight)/2, self.frame.size.height/2 - btHeight, btHeight, btHeight)];
    addbutton.layer.borderColor = FMBlueColor.CGColor;
    addbutton.layer.borderWidth = 1;
    addbutton.layer.cornerRadius = 2;
    addbutton.layer.masksToBounds = YES;
    addbutton.titleLabel.font = kFontNumber(80);
    addbutton.alpha = 0.5;
    [addbutton setTitleColor:FMBlueColor forState:UIControlStateNormal];
    [addbutton setTitleEdgeInsets:UIEdgeInsetsMake(-10, 0, 0, 0)];
    [addbutton addTarget:self action:@selector(clickAddButtonHandle:) forControlEvents:UIControlEventTouchUpInside];
    [addbutton addTarget:self action:@selector(touchDownAddButton:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:addbutton];
    
    UILabel *title = [UILabel createWithTitle:@"搜索股票名称添加自选股"
                                        Frame:CGRectMake(addbutton.frame.origin.x+10,addbutton.frame.origin.y+addbutton.frame.size.height+10,addbutton.frame.size.width-10,addbutton.frame.size.height)];
    title.textColor = FMGreyColor;
    title.textAlignment = NSTextAlignmentCenter;
    [title sizeToFit];
    [self addSubview:title];
}

-(void)clickAddButtonHandle:(UIButton*)bt{
    bt.alpha = 1;
    [UIView animateWithDuration:0.3 animations:^{
        bt.alpha = 0.5;
    }];
    if (self.clickAddStocksButtonBlock) {
        self.clickAddStocksButtonBlock();
    }
}
-(void)touchDownAddButton:(UIButton*)bt{
    bt.alpha = 1;
}


@end
