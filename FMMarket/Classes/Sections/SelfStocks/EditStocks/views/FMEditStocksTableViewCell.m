//
//  FMEditStocksTableViewCell.m
//  FMMarket
//
//  Created by dangfm on 15/10/2.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMEditStocksTableViewCell.h"

@implementation FMEditStocksTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self==[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initViews];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    self.contentView.frame = CGRectMake(0, 0, UIScreenWidth, self.frame.size.height);
    if ([[[UIDevice currentDevice]systemVersion]floatValue]>=8.0f) {
        UIView *last = self.subviews.lastObject;
        last.frame = CGRectMake(UIScreenWidth-70, last.frame.origin.y, last.frame.size.width, last.frame.size.height);
        last = nil;
    }
    
    self.moveBt.frame = CGRectMake(_remindBt.frame.size.width+_remindBt.frame.origin.x, 0, _remindBt.frame.size.width, _remindBt.frame.size.height);
    
}

-(void)initViews{

    self.backgroundColor = [UIColor whiteColor];
    
    
    
    self.selectedBt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, kTableViewCellDefaultHeight)];
    [self.selectedBt setImage:ThemeImage(@"stocks/icon_accessory_normal") forState:UIControlStateNormal];
    self.selectedBt.tag = 0;
    [self.contentView addSubview:self.selectedBt];
    [self.selectedBt addTarget:self action:@selector(clickSeletButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.title.frame = CGRectMake(self.selectedBt.frame.size.width,
                                  10, self.bounds.size.width, kTableViewCellTitleFontSize);
    self.typeIcon.frame = CGRectMake(self.title.frame.origin.x,
                                     self.title.frame.origin.y+self.title.font.pointSize+5,
                                     16, kTableViewCellCodeFontSize);
    self.typeIcon.backgroundColor = FMBlueColor;
    self.typeIcon.textColor = [UIColor whiteColor];
    //self.typeIcon.layer.cornerRadius = 1;
    self.typeIcon.layer.masksToBounds = YES;
    self.typeIcon.textAlignment = NSTextAlignmentCenter;
    self.code.frame = CGRectMake(self.title.frame.origin.x+self.typeIcon.frame.size.width+2,
                                 self.title.frame.origin.y+self.title.font.pointSize+5,
                                 self.bounds.size.width,
                                 kTableViewCellCodeFontSize);
    self.code.textColor = ThemeColor(@"UITableViewCell_Code_Color");

    self.typeIcon.hidden = NO;
    self.code.hidden = NO;
    
    UIImage *rbg = ThemeImage(@"search/icon_remind_normal");
    rbg = [UIImage imageWithTintColor:FMGreyColor blendMode:kCGBlendModeDestinationIn WithImageObject:rbg];
    self.remindBt = [[UIButton alloc]initWithFrame:CGRectMake(UIScreenWidth/5*2, 0, UIScreenWidth/5, kTableViewCellDefaultHeight)];
    [self.remindBt setImage:rbg forState:UIControlStateNormal];
    [self.remindBt addTarget:self action:@selector(clickRemindButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.remindBt];
    float x = UIScreenWidth/5*3;
    self.moveBt = [[UIButton alloc] initWithFrame:CGRectMake(x, 0, UIScreenWidth/5, kTableViewCellDefaultHeight)];
    [self.moveBt setImage:ThemeImage(@"stocks/icon_moveup_normal") forState:UIControlStateNormal];
    [self addSubview:self.moveBt];
    [self.moveBt addTarget:self action:@selector(clickMoveUpButtonAction) forControlEvents:UIControlEventTouchUpInside];
}
-(void)setContent:(FMSelfStocksModel *)model{
    if ([model.code isEqualToString:@""]) {
        return;
    }
    self.model = model;
    self.title.text = model.name;
    self.code.text = [model.code substringFromIndex:2];
    self.typeIcon.text = [model.code substringToIndex:2].uppercaseString;
    self.typeIcon.backgroundColor = ThemeColor(self.typeIcon.text);
    
}

-(void)updateSelectView:(NSArray*)selectDatas{
    if ([selectDatas indexOfObject:_model.code] != NSNotFound) {
        [_selectedBt setImage:ThemeImage(@"stocks/icon_accessory_selected")
                     forState:UIControlStateNormal];
    }else{
        [_selectedBt setImage:ThemeImage(@"stocks/icon_accessory_normal")
                     forState:UIControlStateNormal];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touch");
    
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touchend");
    [self clickSeletButtonAction];
}


//  点击置顶
-(void)clickMoveUpButtonAction{
    if (self.clickMoveUpButtonBlock) {
        self.clickMoveUpButtonBlock(self);
    }
}
//  点击选择
-(void)clickSeletButtonAction{

    if (self.clickMySelfToSelectBlock) {
        self.clickMySelfToSelectBlock(self);
    }
}
//  点击提醒
-(void)clickRemindButtonAction{
    
    if (self.clickMySelfToRemindBlock) {
        self.clickMySelfToRemindBlock(self);
    }
}
@end
