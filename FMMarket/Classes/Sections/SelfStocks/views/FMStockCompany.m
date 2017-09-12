//
//  FMStockCompany.m
//  FMMarket
//
//  Created by dangfm on 15/10/5.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMStockCompany.h"
#import "UILabel+stocking.h"

@implementation FMStockCompanyModel

-(instancetype)initWithDic:(NSDictionary *)dic{
    if (self==[super init]) {
        [fn reflectDataFromOtherObject:dic WithTarget:self];
    }
    return self;
}
@end

@implementation FMStockCompany

-(instancetype)initWithFrame:(CGRect)frame{
    if (self==[super initWithFrame:frame]) {
        _model = [[FMStockCompanyModel alloc] init];
        [self initViews];
    }
    return self;
}

-(void)updateWithModel:(FMStockCompanyModel*)model{
    _model = model;
    [self initViews];
}

-(void)initViews{
    for (UIView *item in self.subviews) {
        [item removeFromSuperview];
    }
    CGPoint point = CGPointMake(kFMStockCompanyPadding, 20);
    point = [self createLineViewWithTitle:@"公司简介" value:@"" isBg:NO point:point];
    point = [self createLineViewWithTitle:@"公司名称：" value:_model.companyName isBg:NO point:point];
    
    point = [self createLineViewWithTitle:@"上市日期：" value:_model.marketDate isBg:YES point:point];
    
    point = [self createLineViewWithTitle:@"注册资本：" value:([_model.registMoney floatValue]>0?[NSString stringWithFormat:@"%@万元",_model.registMoney]:nil) isBg:NO point:point];
    
    point = [self createLineViewWithTitle:@"所属行业：" value:_model.plateName isBg:YES point:point];
    
    point = [self createLineViewWithTitle:@"公司概况：" value:_model.mainBusiness isBg:NO point:point];
    
    
    UIView *lastView = [self.subviews lastObject];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, lastView.frame.size.height+lastView.frame.origin.y+kFMStockCompanyPadding);
}

-(CGPoint)createLineViewWithTitle:(NSString*)title value:(NSString*)value isBg:(BOOL)isBg point:(CGPoint)point{
    UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(point.x, point.y, UIScreenWidth-2*kFMStockCompanyPadding, kFMStockCompanyLineHeight)];
    if (isBg) {
        bg.backgroundColor = FMBgGreyColor;
    }
    UILabel *l = [UILabel createWithTitle:title Frame:CGRectMake(0, 0, bg.frame.size.width,kFMStockCompanyLineHeight)];
    l.text = title;
    if ([value isEqualToString:@""]) {
        l.font = kFontBold(16);
    }
    [bg addSubview:l];
    
    UILabel *r = [UILabel createWithTitle:title Frame:CGRectMake(85, 0, bg.frame.size.width-85,kFMStockCompanyLineHeight)];
    r.text = value;
    r.numberOfLines = 0;
    [r sizeToFit];
    CGFloat y = (kFMStockCompanyLineHeight-r.font.pointSize)/2-1;
    r.frame = CGRectMake(r.frame.origin.x, y , r.frame.size.width, r.frame.size.height);
    [bg addSubview:r];
    point = CGPointMake(point.x, MAX(point.y+kFMStockCompanyLineHeight, r.frame.size.height+y+point.y));
    bg.frame = CGRectMake(bg.frame.origin.x, bg.frame.origin.y, UIScreenWidth-2*kFMStockCompanyPadding, MAX(kFMStockCompanyLineHeight, r.frame.size.height+y));
    [self addSubview:bg];
    bg = nil;
    l = nil;
    r = nil;
    return point;
}
@end
