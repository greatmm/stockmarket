//
//  FMSelfStockTableViewCell.m
//  FMMarket
//
//  Created by dangfm on 15/8/8.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMSelfStockTableViewCell.h"

@implementation FMSelfStockTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self==[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initViews];
    }
    return self;
}

-(void)initViews{
    self.backgroundColor = [UIColor whiteColor];
    self.title.frame = CGRectMake(kTableViewCellLeftPadding,
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
    [self.changeRate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.price.frame = CGRectMake(0,0, UIScreenWidth-self.changeRate.frame.size.width-3*kTableViewCellLeftPadding, kTableViewCellHeight);
//    self.price.font = kFont(18);
    self.price.textAlignment = NSTextAlignmentRight;
    self.typeIcon.hidden = NO;
    self.code.hidden = NO;
    self.price.hidden = NO;
    self.changeRate.hidden = NO;
    self.signal.hidden = NO;
    // 闪动图
    
}
-(void)setContent:(FMSelfStocksModel *)model{
    if ([model.code isEqualToString:@""]) {
        return;
    }
    self.title.text = model.name;
    self.code.text = [model.code substringFromIndex:2];
    self.typeIcon.text = [model.code substringToIndex:2].uppercaseString;
    self.typeIcon.backgroundColor = ThemeColor(self.typeIcon.text);
    if ([model.price floatValue]<=0) {
        model.price = @"-";
    }else{
        model.price = [NSString stringWithFormat:@"%.2f",[model.price floatValue]];
    }
    self.price.text = model.price;
    NSString *rate = [model changeRate];
    if (fabsf([rate floatValue])<=0) {
        rate = @"-";
        if ([model.price floatValue]>0 && [model.closePrice floatValue]>0) {
           float changeRate = ([model.price floatValue] - [model.closePrice floatValue]) / [model.closePrice floatValue] * 100;
            rate = [NSString stringWithFormat:@"%.2f",changeRate];
        }
    }
    if ([rate floatValue]>0) {
        rate = [NSString stringWithFormat:@"+ %.2f%%",[rate floatValue]];
    }
    if ([rate floatValue]<0) {
        rate = [NSString stringWithFormat:@"- %.2f%%",fabsf([rate floatValue])];
    }
    [self.changeRate setTitle:rate forState:UIControlStateNormal];
    if ([[model changeRate] floatValue]>0) {
        [self.changeRate setBackgroundImage:[UIImage imageWithColor:FMRedColor andSize:self.changeRate.frame.size]
                         forState:UIControlStateNormal];
    }
    if ([[model changeRate] floatValue]<0) {
        [self.changeRate setBackgroundImage:[UIImage imageWithColor:FMGreenColor andSize:self.changeRate.frame.size]
                         forState:UIControlStateNormal];
    }
    
    if ([[model changeRate] floatValue]==0) {
        [self.changeRate setBackgroundImage:[UIImage imageWithColor:FMGreyColor andSize:self.changeRate.frame.size]
                                   forState:UIControlStateNormal];
    }
    NSString *signal = model.signal;
    
    float tw = [self.title.text sizeWithAttributes:@{NSFontAttributeName:self.title.font}].width;
    self.signal.frame = CGRectMake(tw+self.title.frame.origin.x+10, self.title.frame.origin.y+(self.title.frame.size.height-self.signal.frame.size.height)/2, self.signal.frame.size.width, self.signal.frame.size.height);
    
    if ([[FMUserDefault getUserId]floatValue]>0) {
        if(![signal isEqualToString:@""]){
            if ([signal floatValue]==0) {
                self.signal.text = @"B";
                self.signal.hidden = NO;
                self.signal.backgroundColor = FMRedColor;
            }
            if ([signal floatValue]==1) {
                self.signal.text = @"S";
                self.signal.hidden = NO;
                self.signal.backgroundColor = FMGreenColor;
            }
            if ([signal floatValue]==-1) {
                self.signal.text = @"";
                self.signal.hidden = YES;
            }
        }else{
            self.signal.text = @"";
            self.signal.hidden = YES;
        }
    }else{
        self.signal.text = @"";
        self.signal.hidden = YES;
    }
    
    //NSLog(@"%@=%.2f",self.title.text,[[model changeRate] floatValue]);
    [self.changeRate setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if ([model.isStop intValue]>0) {
        [self.changeRate setTitle:@"停牌" forState:UIControlStateNormal];
        [self.changeRate setTitleColor:FMBlackColor forState:UIControlStateNormal];
        if ([model.closePrice floatValue]>0 && [model.openPrice floatValue]<=0) {
            model.price = [NSString stringWithFormat:@"%.2f",[model.closePrice floatValue]];
            self.price.text = model.price;
        }
        
    }
    
}
@end
