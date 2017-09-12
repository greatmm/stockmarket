//
//  FMEditStocksToolBar.m
//  FMMarket
//
//  Created by dangfm on 15/10/2.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMEditStocksToolBar.h"

@implementation FMEditStocksToolBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

-(void)initViews{
    self.backgroundColor = [UIColor whiteColor];
    _selectButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 80, kFMEditStocksToolBarHeight)];
    [_selectButton setImage:ThemeImage(@"stocks/icon_accessory_normal") forState:UIControlStateNormal];
    [_selectButton setTitle:@" 全选" forState:UIControlStateNormal];
    [_selectButton setTitleColor:FMBlackColor forState:UIControlStateNormal];
    _selectButton.titleLabel.font = kFont(14);
    _selectButton.tag = 0;
    [_selectButton addTarget:self
                      action:@selector(clickSelectButtonAction)
            forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_selectButton];
    
    _deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(UIScreenWidth-80, 0, 80, kFMEditStocksToolBarHeight)];
    [_deleteButton setTitle:@"删除(0)" forState:UIControlStateNormal];
    [_deleteButton setTitleColor:FMBlackColor forState:UIControlStateNormal];
    _deleteButton.titleLabel.font = kFont(14);
    [_deleteButton addTarget:self
                      action:@selector(clickDeleteButtonAction)
            forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_deleteButton];
    
    [fn drawLineWithSuperView:self
                        Color:FMBottomLineColor
                        Frame:CGRectMake(_deleteButton.frame.origin.x, 5, 0.5, kFMEditStocksToolBarHeight-10)];
    [fn drawLineWithSuperView:self Color:FMBottomLineColor Location:0];
    
}


-(void)updateViewsWithSelectedCount:(int)count{
    if (count>0) {
        [_deleteButton setTitle:[NSString stringWithFormat:@"删除(%d)",count]
                       forState:UIControlStateNormal];
        [_deleteButton setTitleColor:FMBlueColor forState:UIControlStateNormal];
    }else{
        [_deleteButton setTitle:@"删除(0)" forState:UIControlStateNormal];
        [_deleteButton setTitleColor:FMBlackColor forState:UIControlStateNormal];
    }
}

-(void)clickSelectButtonAction{
    if (_selectButton.tag==0) {
        // 全选
        [_selectButton setImage:ThemeImage(@"stocks/icon_accessory_selected")
                       forState:UIControlStateNormal];
        _selectButton.tag = 1;
    }else{
        [_selectButton setImage:ThemeImage(@"stocks/icon_accessory_normal")
                       forState:UIControlStateNormal];
        _selectButton.tag = 0;
    }
    if (self.clickSelectButtonBlock) {
        self.clickSelectButtonBlock((int)_selectButton.tag);
    }
}

-(void)clickDeleteButtonAction{
    if (self.clickDeleteButtonBlock) {
        self.clickDeleteButtonBlock();
    }
}
@end
