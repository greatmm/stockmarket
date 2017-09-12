//
//  TopThreeView.m
//  FMMarket
//
//  Created by dangfm on 15/11/18.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "TopThreeView.h"
#import "ThreeButton.h"
#import "FMStocksModel.h"

@implementation TopThreeView

-(instancetype)initWithFrame:(CGRect)frame{
    if(self==[super initWithFrame:frame]){
        _isTrade = NO;
        [self initViews];
    }
    
    return self;
}

-(instancetype)initTradeViewWithFrame:(CGRect)frame{
    if(self==[super initWithFrame:frame]){
        _isTrade = YES;
        [self initViews];
    }
    
    return self;
}

-(void)dealloc{
    _first = nil;
    _second = nil;
    _three = nil;
}

-(void)initViews{
    
    self.backgroundColor = [UIColor whiteColor];
    _buttons = [NSMutableDictionary new];
    _mainView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.mj_w, self.mj_h)];
    _mainView.pagingEnabled = YES;
    _mainView.scrollEnabled = YES;
    [self addSubview:_mainView];
    
}



#pragma mark 更新视图
-(void)updateViewsWithDatas:(NSArray *)datas{
    
    CGFloat x = 5;
    CGFloat y = 5;
    CGFloat w = (UIScreenWidth-10) / 3;
    CGFloat h = self.mj_h-8;
    
    // 创建多个按钮
    int counts = (int)datas.count;
    for (int i=0; i<counts; i++) {
        ThreeButton *bt = nil;
        NSString *key = [NSString stringWithFormat:@"%d",i];
        if ([_buttons objectForKey:key]) {
            bt = _buttons[key];
        }
        if (!bt) {
            bt = [[ThreeButton alloc] initWithFrame:CGRectMake(x, y, w, h)];
            [_buttons setObject:bt forKey:key];
        }
        [bt setBackgroundColor:[UIColor clearColor]];
        [_mainView addSubview:bt];
        [bt addTarget:self action:@selector(clickButtons:) forControlEvents:UIControlEventTouchUpInside];
        if (i<counts-1) {
            [fn drawLineWithSuperView:bt
                                Color:FMBottomLineColor
                                Frame:CGRectMake(bt.frame.size.width-0.5, 5, 0.5, bt.frame.size.height-10)];
        }
        
        x += w;
        bt = nil;
        key = nil;
    }
    // 重新设置scrollView内容宽度
    _mainView.contentSize = CGSizeMake(x, _mainView.frame.size.height);
    
    int i=0;
    for (NSDictionary *item in datas) {
        NSDictionary *dic = [fn checkNullWithDictionary:item];
        NSString *trade = [dic objectForKey:@"title"];
        NSString *tradeRate = [dic objectForKey:@"rate"];
        NSString *tradeType = [dic objectForKey:@"id"];
        FMSelfStocksModel *m = [[FMSelfStocksModel alloc] initWithDic:dic];
        m.price = [NSString stringWithFormat:@"%.2f",[m.price floatValue]];
        m.change = [NSString stringWithFormat:@"%.2f",[m.change floatValue]];
        m.changeRate = [NSString stringWithFormat:@"%.2f%%",[m.changeRate floatValue]];
        if ([m.price floatValue]<=0) {
            m.price = m.closePrice;
        }
        
        if (fabsf([m.change floatValue])==0) {
            m.change = [NSString stringWithFormat:@"0.00"];
        }
        
        
        
        //m.change = [NSString stringWithFormat:@"%@%.2f",[m.changeRate doubleValue]>=0?@"+":@"-",[m.change floatValue]];
        //m.changeRate = [NSString stringWithFormat:@"%@%@%%",[m.changeRate doubleValue]>=0?@"+":@"",m.changeRate];
        tradeRate = [NSString stringWithFormat:@"%.2f%%",[tradeRate floatValue]];
    
        if ([m.price floatValue]<=0 && !trade) {
            //continue;
        }
        if (i<_buttons.count) {
            NSString *key = [NSString stringWithFormat:@"%d",i];
            ThreeButton *bt = [_buttons objectForKey:key];
            if ([bt isKindOfClass:[ThreeButton class]]) {
                if (!trade) [bt changeBgColorWithOldPrice:m.price];
                bt.titler.text = m.name;
                bt.price.text = m.price;
                bt.change.text = [NSString stringWithFormat:@"%@ %@",m.change,m.changeRate];
                if (fabsf([m.changeRate floatValue])==0 || fabsf([m.changeRate floatValue])>=100) {
                    bt.change.text = [NSString stringWithFormat:@"0.00 0.00%%"];
                }
                
                //_first.changeRate.text = m.changeRate;
                bt.type = m.type;
                bt.code = m.code;
                if (trade) {
                    bt.trade.text = trade;
                    bt.trade.hidden = NO;
                    bt.tradeType = tradeType;
                    bt.price.text = tradeRate;
                    
                }
                [bt updateTextColor];
                bt = nil;
                key = nil;
            }
            
        }
        
        i++;
        dic = nil;
    }
    datas = nil;
}

-(void)clickButtons:(ThreeButton*)button{
    if (self.clickTopThreeButtonBlock) {
        self.clickTopThreeButtonBlock(self,button);
    }
}

@end
