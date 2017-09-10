//
//  FMStockFinance.m
//  FMMarket
//
//  Created by dangfm on 15/10/6.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMStockFinance.h"
#import "UILabel+stocking.h"

@implementation FMStockFinanceModel

-(instancetype)initWithDic:(NSDictionary *)dic{
    if (self==[super init]) {
        [fn reflectDataFromOtherObject:dic WithTarget:self];
    }
    return self;
}
@end

@implementation FMStockFinance


-(instancetype)initWithFrame:(CGRect)frame{
    if (self==[super initWithFrame:frame]) {
        _model = [[FMStockFinanceModel alloc] init];
        [self initViews];
    }
    return self;
}

-(void)updateWithModel:(FMStockFinanceModel*)model{
    _model = model;
    [self initViews];
}

-(void)initViews{
    for (UIView *item in self.subviews) {
        [item removeFromSuperview];
    }
    CGPoint point = CGPointMake(kFMStockFinancePadding, 20);
    point = [self createLineViewWithTitle:[NSString stringWithFormat:@"利润表(%@)",!_model.updateDate?@"":_model.updateDate] value:@"" isBg:NO point:point];
    point = [self createLineViewWithTitle:@"每股收益：" value:[NSString stringWithFormat:@"%@元",_model.perEarnings] isBg:NO point:point];
    
    point = [self createLineViewWithTitle:@"营业收入增长率：" value:[NSString stringWithFormat:@"%.2f%%",[_model.incomeRate floatValue]] isBg:YES point:point];
    
    point = [self createLineViewWithTitle:@"营业利润增长率：" value:[NSString stringWithFormat:@"%.2f%%",[_model.expenditureRate floatValue]] isBg:NO point:point];
    
    point = [self createLineViewWithTitle:@"净利润增长率：" value:[NSString stringWithFormat:@"%.2f%%",[_model.profitRate floatValue]] isBg:YES point:point];
    
    point = [self createLineViewWithTitle:@"营业收入：" value:[NSString stringWithFormat:@"%@万元",_model.totalIncome] isBg:NO point:point];
    
    point = [self createLineViewWithTitle:@"营业利润：" value:[NSString stringWithFormat:@"%@万元",_model.totalExpenditure] isBg:YES point:point];
    
    point = [self createLineViewWithTitle:@"净利润：" value:[NSString stringWithFormat:@"%@万元",_model.netProfit] isBg:NO point:point];
    
    point = [self createLineViewWithTitle:@"其他综合收益：" value:[NSString stringWithFormat:@"%@万元",_model.otherIncome] isBg:YES point:point];
    
    point = [self createLineViewWithTitle:@"综合收益总和：" value:[NSString stringWithFormat:@"%@万元",_model.totalOtherIncome
                                                            ] isBg:NO point:point];
    
    UIView *lastView = [self.subviews lastObject];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, lastView.frame.size.height+lastView.frame.origin.y+kFMStockFinancePadding);
}

-(CGPoint)createLineViewWithTitle:(NSString*)title value:(NSString*)value isBg:(BOOL)isBg point:(CGPoint)point{
    
    UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(point.x, point.y, UIScreenWidth-2*kFMStockFinancePadding, kFMStockFinanceLineHeight)];
    if (isBg) {
        bg.backgroundColor = FMBgGreyColor;
    }
    UILabel *l = [UILabel createWithTitle:title Frame:CGRectMake(0, 0, bg.frame.size.width,kFMStockFinanceLineHeight)];
    l.text = title;
    if ([value isEqualToString:@""]) {
        l.font = kFontBold(16);
    }
    [bg addSubview:l];
    
    if (!_model.updateDate) {
        value = @"" ;
    }
    UILabel *r = [UILabel createWithTitle:value Frame:CGRectMake(85, 0, bg.frame.size.width-85,kFMStockFinanceLineHeight)];
    r.text = value;
    r.numberOfLines = 0;
    r.textAlignment = NSTextAlignmentRight;
    [r sizeToFit];
    CGFloat y = (kFMStockFinanceLineHeight-r.font.pointSize)/2-1;
    r.frame = CGRectMake(bg.frame.size.width-r.frame.size.width, y , r.frame.size.width, r.frame.size.height);
    [bg addSubview:r];
    point = CGPointMake(point.x, MAX(point.y+kFMStockFinanceLineHeight, r.frame.size.height+y+point.y));
    bg.frame = CGRectMake(bg.frame.origin.x, bg.frame.origin.y, UIScreenWidth-2*kFMStockFinancePadding, MAX(kFMStockFinanceLineHeight, r.frame.size.height+y));
    [self addSubview:bg];
    bg = nil;
    l = nil;
    r = nil;
    return point;
}

@end
