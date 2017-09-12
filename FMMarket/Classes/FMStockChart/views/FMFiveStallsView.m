//
//  FMFiveStallsView.m
//  FMStockChart
//
//  Created by dangfm on 15/10/29.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMFiveStallsView.h"
#import "FMStockFiveStallsModel.h"
#import "FMStockModel.h"
#import "HttpManager.h"

#define kFMFiveStallsViewPadding 5
#define kFMFiveStallsViewLoopTime 10

@implementation FMFiveStallsView
-(void)dealloc{
    NSLog(@"FMFiveStallsView dealloc");
}
-(void)clear{
    self.model = nil;
    self.fmScrollView.delegate = nil;
    self.fmScrollView = nil;
    self.delegate = nil;
    self.stockCode = nil;
    self.tabBar = nil;
    self.updateFMStockFiveStallsViewFinished = nil;
    [super clear];
}
-(instancetype)initWithFrame:(CGRect)frame StockCode:(NSString*)code{
    if(self==[super initWithFrame:frame]){
        _stockCode = code;
        [self initParams];
        [self createViews];
    }
    return self;
}

-(void)initParams{
    self.font = [UIFont systemFontOfSize:10];
    self.textFont = [UIFont systemFontOfSize:10];
}

-(void)createViews{
    [self createListWithModel:nil];
    [self getHttpStockNewData];
}

-(void)createListWithModel:(FMStockFiveStallsModel*)model{
    self.stallModel = model;
    NSArray *subViews = self.subviews;
    for (UIView *item in subViews) {
        [item removeFromSuperview];
    }
    
    // 卖出档口
    int five = 5;
    float x = kFMFiveStallsViewPadding;
    float y = kFMFiveStallsViewPadding;
    float w = (self.frame.size.width-5)/5;
    float h = (self.frame.size.height-40)/10;
    UIColor *color = kFMColor(0x666666);
    UIColor *textColor = color;
    // 两个按钮
    _tabBar = [[UIButton alloc] initWithFrame:CGRectMake(x, 0, self.frame.size.width-x, 20)];
    _tabBar.titleLabel.font = self.font;
    [_tabBar setTitle:@"五档" forState:UIControlStateNormal];
    [_tabBar setTitleColor:textColor forState:UIControlStateNormal];
    [_tabBar setBackgroundColor:kFMColor(0xf0f4fa)];
    [self addSubview:_tabBar];
    y += _tabBar.frame.size.height;
    
    for (int i=five; i>0; i--) {
        NSString *price = [model valueForKey:[NSString stringWithFormat:@"sell_%d",i]];
        if ([price floatValue]>[model.closePrice floatValue]) {
            color = kFMColor(0xf33f58);
        }
        if ([price floatValue]<[model.closePrice floatValue]) {
            color = kFMColor(0x18c062);
        }
        
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
        l.font = _textFont;
        l.textColor = textColor;
        l.text = [NSString stringWithFormat:@"卖%d",i];
        [self addSubview:l];
        l = nil;
        UILabel *p = [[UILabel alloc] initWithFrame:CGRectMake(x+w, y, 2*w, h)];
        p.font = _font;
        p.textColor = color;
        p.textAlignment = NSTextAlignmentRight;
        p.text = [NSString stringWithFormat:@"%.2f",[price floatValue]];
        if ([price floatValue]<=0) {
            p.text = @"-";
        }
        [self addSubview:p];
        p = nil;
        UILabel *r = [[UILabel alloc] initWithFrame:CGRectMake(x+3*w, y, 2*w, h)];
        r.font = _font;
        r.textColor = textColor;
        NSString *vol = [model valueForKey:[NSString stringWithFormat:@"sell_%d_s",i]];
        r.text = [NSString stringWithFormat:@"%.f",[vol floatValue]/100];
        if ([price floatValue]<=0) {
            r.text = @"-";
        }
        r.textAlignment = NSTextAlignmentRight;
        [self addSubview:r];
        r = nil;
        
        y += h;
    }
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(kFMFiveStallsViewPadding, y+kFMFiveStallsViewPadding, self.frame.size.width-kFMFiveStallsViewPadding, 0.5)];
    line.backgroundColor = kFMColor(0xf0f4fa);
    [self addSubview:line];
    line = nil;
    y += 2*kFMFiveStallsViewPadding;
    
    // 买入档口
    x = 5;
    for (int i=1; i<=five; i++) {
        NSString *price = [model valueForKey:[NSString stringWithFormat:@"buy_%d",i]];
        if ([price floatValue]>[model.closePrice floatValue]) {
            color = kFMColor(0xf33f58);
        }
        if ([price floatValue]<[model.closePrice floatValue]) {
            color = kFMColor(0x18c062);
        }
        
        UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(x, y, w, h)];
        l.font = _textFont;
        l.textColor = textColor;
        l.text = [NSString stringWithFormat:@"买%d",i];
        [self addSubview:l];
        l = nil;
        UILabel *p = [[UILabel alloc] initWithFrame:CGRectMake(x+w, y, 2*w, h)];
        p.font = _font;
        p.textColor = color;
        p.textAlignment = NSTextAlignmentRight;
        p.text = [NSString stringWithFormat:@"%.2f",[price floatValue]];
        if ([price floatValue]<=0) {
            p.text = @"-";
        }
        [self addSubview:p];
        p = nil;
        UILabel *r = [[UILabel alloc] initWithFrame:CGRectMake(x+3*w, y, 2*w, h)];
        r.font = _font;
        r.textColor = textColor;
        NSString *vol = [model valueForKey:[NSString stringWithFormat:@"buy_%d_s",i]];
        r.text = [NSString stringWithFormat:@"%.f",[vol floatValue]/100];
        if ([price floatValue]<=0) {
            r.text = @"-";
        }
        r.textAlignment = NSTextAlignmentRight;
        [self addSubview:r];
        r = nil;
        
        y += h;
    }
    
    if (model && self.updateFMStockFiveStallsViewFinished) {
        self.updateFMStockFiveStallsViewFinished(model);
    }
}

-(void)getHttpStockNewData{
    if (!self.stockCode || [self.stockCode isEqualToString:@""]) {
        return;
    }
    NSLog(@"请求五档");
    __FMWeakSelf;
    [HttpManager getHttpStockNewDataWithCode:self.stockCode StartBlock:^{
        
    } Success:^(NSDictionary *response,NSInteger statusCode){
        //FMLog(@"%@",response);
        NSArray *list = [response objectForKey:@"data"];
        if (list && ![list isEqual:[NSNull null]]) {
            response = [list firstObject];
            if (![response isEqual:[NSNull null]] && response) {
                FMStockFiveStallsModel *m = [[FMStockFiveStallsModel alloc] initWithDic:response];
                [__weakSelf createListWithModel:m];
                m = nil;
            }
        }
        
        [__weakSelf loopGetStockNewData];
    } Failure:^(NSError*error){
        [__weakSelf loopGetStockNewData];
    }];
}

-(void)loopGetStockNewData{
    if (!self.stockCode) {
        return;
    }
    [self performSelector:@selector(getHttpStockNewData)
               withObject:nil
               afterDelay:kFMFiveStallsViewLoopTime];
}

@end
