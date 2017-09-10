//
//  FMSearchStocksTableViewCell.m
//  FMMarket
//
//  Created by dangfm on 15/8/14.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMSearchStocksTableViewCell.h"
#import "UILabel+stocking.h"

@implementation FMSearchStocksTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self==[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initSelfViews];
    }
    return self;
}

-(void)initSelfViews{
    // 隐藏
    self.price.hidden = YES;
    self.changeRate.hidden = YES;
    // 添加按钮
    if (!_addButton) {
        UIImage *addicon = ThemeImage(@"global/search_icon_add_normal");
        _addButton = [[UIButton alloc]
                     initWithFrame:CGRectMake(UIScreenWidth-kTableViewCellLeftPadding-addicon.size.width-20,
                                              0,
                                              addicon.size.width+20,
                                              kTableViewCellHeight)];
        [_addButton setImage:addicon forState:UIControlStateNormal];
        [_addButton setImage:addicon forState:UIControlStateHighlighted];
        [self.contentView addSubview:_addButton];
        _addButton.hidden = YES;
    }
    if (!_addText) {
        _addText = [UILabel createWithTitle:@"已添加"
                                      Frame:CGRectMake(UIScreenWidth-25-100,
                                                       0,100,kTableViewCellHeight)];
        _addText.textAlignment = NSTextAlignmentRight;
        _addText.hidden = YES;
        [self.contentView addSubview:_addText];
    }
}


-(void)setContent:(FMStocksModel *)model{
    if (model.code.length<6) {
        return;
    }
    self.model = model;
    self.title.text = model.name;
    self.code.text = [model.code substringFromIndex:2];
    self.typeIcon.text = [model.code substringToIndex:2].uppercaseString;
    self.typeIcon.backgroundColor = ThemeColor(self.typeIcon.text);
    NSString *where = [NSString stringWithFormat:@"code='%@'",model.code];
    if ([[FMUserDefault getUserId]floatValue]>0) {
        where = [NSString stringWithFormat:@"code='%@' and userId='%@'",model.code,[FMUserDefault getUserId]];
    }
    NSArray *rs = [db select:[FMSelfStocksModel class]
                       Where:where
                       Order:nil Limit:nil];
    if (rs.count>0) {
        // 存在
        _addButton.hidden = YES;
        _addText.hidden = NO;
    }else{
        _addButton.hidden = NO;
        _addText.hidden = YES;
    }
}

@end
