//
//  FMStockCapitalCell.m
//  FMMarket
//
//  Created by dangfm on 15/10/7.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMStockCapitalCell.h"
#import "FMStockCapital.h"

@implementation FMStockCapitalCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self==[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initViews];
    }
    return self;
}

-(void)initViews{
    self.backgroundColor = [UIColor whiteColor];
    self.title.frame = CGRectMake(kTableViewCellLeftPadding,
                                  (kTableViewCellDefaultHeight-kTableViewCellTitleFontSize)/2, self.bounds.size.width, kTableViewCellTitleFontSize);
    
    self.price.frame = CGRectMake(0,0, UIScreenWidth-self.changeRate.frame.size.width-3*kTableViewCellLeftPadding, kTableViewCellDefaultHeight);
    if (UIScreenWidth<=320) {
        self.price.frame = CGRectMake(0,0, UIScreenWidth-self.changeRate.frame.size.width-2*kTableViewCellLeftPadding, kTableViewCellDefaultHeight);
    }
    self.price.textAlignment = NSTextAlignmentRight;
    [self.changeRate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.price.hidden = NO;
    self.changeRate.hidden = NO;
}
-(void)setContent:(FMStockCapitalModel *)model{
    self.title.text = model.name;
    UIColor *color = FMRedColor;

    self.price.text = [NSString stringWithFormat:@"%.2f万",([model.netamount floatValue]/10000)];
    if ([model.netamount floatValue]>0) {
        self.price.textColor = FMRedColor;
    }else{
        self.price.textColor = FMGreenColor;
    }
    NSString *rate = model.avg_changeratio;
    if (fabsf([rate floatValue])<=0) {
        rate = @"-";
    }
    if ([rate floatValue]>0) {
        rate = [NSString stringWithFormat:@"+ %.2f%%",[rate floatValue]*100];
    }
    if ([rate floatValue]<0) {
        rate = [NSString stringWithFormat:@"- %.2f%%",fabsf([rate floatValue]*100)];
    }
    [self.changeRate setTitle:rate forState:UIControlStateNormal];
    if ([model.avg_changeratio floatValue]>0) {
        [self.changeRate setBackgroundImage:[UIImage imageWithColor:FMRedColor andSize:self.changeRate.frame.size]
                                   forState:UIControlStateNormal];
        color = FMRedColor;
    }
    if ([model.avg_changeratio floatValue]<0) {
        [self.changeRate setBackgroundImage:[UIImage imageWithColor:FMGreenColor andSize:self.changeRate.frame.size]
                                   forState:UIControlStateNormal];
        color = FMGreenColor;
    }
    
    if ([model.avg_changeratio floatValue]==0) {
        [self.changeRate setBackgroundImage:[UIImage imageWithColor:FMGreyColor andSize:self.changeRate.frame.size]
                                   forState:UIControlStateNormal];
        color = FMGreyColor;
    }
    
}
@end
