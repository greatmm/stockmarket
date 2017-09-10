//
//  FMSelfStockTopViews.m
//  FMMarket
//
//  Created by dangfm on 15/8/15.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMSelfStockTopViews.h"
#import "UILabel+stocking.h"
#import "UIImage+stocking.h"

@implementation FMSelfStockTopViews

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self clickSelfAction];
}

-(instancetype)initWithFrame:(CGRect)frame{
    if (self==[super initWithFrame:frame]) {
        [self initViews];
    }
    return self;
}

-(void)initViews{
    self.backgroundColor = [UIColor whiteColor];
    
    //self.alpha = 0.90;
//    if (!_bg) {
//        _bg = [[UIImageView alloc] initWithFrame:self.frame];
//        _bg.image = [UIImage imageWithColor:FMGreyColor andSize:self.frame.size];
//        [self addSubview:_bg];
//    }
    if (!_titler) {
        _titler = [UILabel createWithTitle:@"-"
                                     Frame:CGRectMake(kFMSelfStockTopViewsLeftPadding, 0,
                                                      90,
                                                      kFMSelfStockTopViewsHeight-kFMSelfStockTopViewsBottomViewHeight-30)];
        _titler.font = kFont(kFMSelfStockTopViewBigFontSize);
        _titler.textAlignment = NSTextAlignmentCenter;
        _titler.textColor = FMRedColor;
        _titler.adjustsFontSizeToFitWidth = YES;
        _titler.numberOfLines = 1;
        [self addSubview:_titler];
    }
    if (!_time) {
        _time = [UILabel createWithTitle:@"-" Frame:CGRectMake(kFMSelfStockTopViewsLeftPadding, (kFMSelfStockTopViewsHeight-kFMSelfStockTopViewsBottomViewHeight)/2+kFMSelfStockTopViewBigFontSize/2, _titler.frame.size.width, 12)];
        _time.font = kFontNumber(10);
        _time.textColor = [UIColor whiteColor];
        _time.alpha = 0.8;
        [self addSubview:_time];
    }
    if (!_change) {
        _change = [UILabel createWithTitle:@"-"
                                     Frame:CGRectMake(kFMSelfStockTopViewsLeftPadding, kFMSelfStockTopViewsHeight-kFMSelfStockTopViewsBottomViewHeight-40, _titler.frame.size.width,
                                                      20)];
        _change.font = kFont(kFMSelfStockTopViewSmallFontSize);
        _change.textColor = FMRedColor;
        _change.textAlignment = NSTextAlignmentLeft;
        _change.adjustsFontSizeToFitWidth = YES;
        [self addSubview:_change];
    }
    //    if (!_changeRate) {
    //        _changeRate = [UILabel createWithTitle:@"-"
    //                                     Frame:CGRectMake(kFMSelfStockTopViewsLeftPadding+_titler.frame.size.width/2, _change.frame.origin.y,
    //                                                      _titler.frame.size.width/2,
    //                                                      _change.frame.size.height)];
    //        _changeRate.font = kFontNumber(kFMSelfStockTopViewSmallFontSize);
    //        _changeRate.textColor = [UIColor whiteColor];
    //        _changeRate.textAlignment = NSTextAlignmentRight;
    //        _changeRate.hidden = YES;
    //        [self addSubview:_changeRate];
    //    }
    
    //    if (!_codeName) {
    //        _codeName = [UILabel createWithTitle:@"上证指数" Frame:CGRectMake(0,0,UIScreenWidth-kFMSelfStockTopViewsLeftPadding,kFMSelfStockTopViewsHeight/2)];
    //        _codeName.textAlignment = NSTextAlignmentCenter;
    //        _codeName.textColor = [UIColor whiteColor];
    //        _codeName.backgroundColor = [UIColor clearColor];
    //        _codeName.font = kFont(10);
    //        _codeName.layer.cornerRadius = 1;
    //        _codeName.layer.masksToBounds = YES;
    //        _codeName.layer.borderColor = [UIColor whiteColor].CGColor;
    //        _codeName.layer.borderWidth = 0.5;
    //        [_codeName sizeToFit];
    //        _codeName.hidden = YES;
    //        _codeName.frame = CGRectMake(UIScreenWidth-kFMSelfStockTopViewsLeftPadding-_codeName.frame.size.width-5,(kFMSelfStockTopViewsHeight/2-_codeName.frame.size.height)-7,_codeName.frame.size.width+4,_codeName.frame.size.height+4);
    //        [self addSubview:_codeName];
    //    }
    
    // 开盘收盘最高最低
    float x = (_titler.frame.size.width+2*kFMSelfStockTopViewsLeftPadding);
    float y = 8;
    float w = (UIScreenWidth-x-10) / 4;
    float h = (self.frame.size.height-kFMSelfStockTopViewsBottomViewHeight-2*y-8) / 4;
    UIFont *font = kFont(12);
    UILabel *open = [UILabel createWithTitle:@"今开" Frame:CGRectMake(x, y, w, h)];
    open.textColor = FMBlackColor;
//    open.alpha = 0.8;
    open.font = font;
    open.textAlignment = NSTextAlignmentCenter;
    [self addSubview:open];
    _openPrice = [UILabel createWithTitle:@"-" Frame:CGRectMake(x, y+h, w, h)];
    _openPrice.textColor = FMZeroColor;
    _openPrice.font = font;
    _openPrice.adjustsFontSizeToFitWidth = YES;
    _openPrice.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_openPrice];
    
    UILabel *close = [UILabel createWithTitle:@"昨收" Frame:CGRectMake(x+w, y, w, h)];
    close.textColor = FMBlackColor;
//    close.alpha = 0.8;
    close.font = font;
    close.textAlignment = NSTextAlignmentCenter;
    [self addSubview:close];
    _closePrice = [UILabel createWithTitle:@"-" Frame:CGRectMake(x+w, y+h, w, h)];
    _closePrice.textColor = FMZeroColor;
    _closePrice.font = font;
    _closePrice.adjustsFontSizeToFitWidth = YES;
    _closePrice.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_closePrice];
    
    UILabel *vl = [UILabel createWithTitle:@"成交量" Frame:CGRectMake(x+2*w, y, w, h)];
    vl.textColor = FMBlackColor;
    //    high.alpha = 0.8;
    vl.font = font;
    vl.textAlignment = NSTextAlignmentCenter;
    [self addSubview:vl];
    _volumn = [UILabel createWithTitle:@"-" Frame:CGRectMake(x+2*w, y+h, w, h)];
    _volumn.textColor = FMZeroColor;
    _volumn.font = font;
    _volumn.adjustsFontSizeToFitWidth = YES;
    _volumn.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_volumn];
    
    UILabel *ratio = [UILabel createWithTitle:@"市盈(动)" Frame:CGRectMake(x+3*w, y, w, h)];
    ratio.textColor = FMBlackColor;
    //    close.alpha = 0.8;
    ratio.font = font;
    ratio.textAlignment = NSTextAlignmentCenter;
    [self addSubview:ratio];
    _peRatio = [UILabel createWithTitle:@"-" Frame:CGRectMake(x+3*w, y+h, w, h)];
    _peRatio.textColor = FMZeroColor;
    _peRatio.font = font;
    _peRatio.adjustsFontSizeToFitWidth = YES;
    _peRatio.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_peRatio];
    
    y = y +8;
    UILabel *high = [UILabel createWithTitle:@"最高" Frame:CGRectMake(x, y+2*h, w, h)];
    high.textColor = FMBlackColor;
//    high.alpha = 0.8;
    high.font = font;
    high.textAlignment = NSTextAlignmentCenter;
    [self addSubview:high];
    _highPrice = [UILabel createWithTitle:@"-" Frame:CGRectMake(x, y+3*h, w, h)];
    _highPrice.textColor = FMZeroColor;
    _highPrice.font = font;
    _highPrice.adjustsFontSizeToFitWidth = YES;
    _highPrice.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_highPrice];
    
    UILabel *low = [UILabel createWithTitle:@"最低" Frame:CGRectMake(x+w, y+2*h, w, h)];
    low.textColor = FMBlackColor;
//    low.alpha = 0.8;
    low.font = font;
    low.textAlignment = NSTextAlignmentCenter;
    [self addSubview:low];
    _lowPrice = [UILabel createWithTitle:@"-" Frame:CGRectMake(x+w, y+3*h, w, h)];
    _lowPrice.textColor = FMZeroColor;
    _lowPrice.font = font;
    _lowPrice.textAlignment = NSTextAlignmentCenter;
    _lowPrice.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_lowPrice];
    
    UILabel *hs = [UILabel createWithTitle:@"换手率" Frame:CGRectMake(x+2*w, y+2*h, w, h)];
    hs.textColor = FMBlackColor;
    //    low.alpha = 0.8;
    hs.font = font;
    hs.textAlignment = NSTextAlignmentCenter;
    [self addSubview:hs];
    _turnoverRate = [UILabel createWithTitle:@"-" Frame:CGRectMake(x+2*w, y+3*h, w, h)];
    _turnoverRate.textColor = FMZeroColor;
    _turnoverRate.font = font;
    _turnoverRate.textAlignment = NSTextAlignmentCenter;
    _turnoverRate.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_turnoverRate];
    
    UILabel *sz = [UILabel createWithTitle:@"流通值" Frame:CGRectMake(x+3*w, y+2*h, w, h)];
    sz.textColor = FMBlackColor;
    //    low.alpha = 0.8;
    sz.font = font;
    sz.textAlignment = NSTextAlignmentCenter;
    [self addSubview:sz];
    _circulationValue = [UILabel createWithTitle:@"-" Frame:CGRectMake(x+3*w, y+3*h, w, h)];
    _circulationValue.textColor = FMZeroColor;
    _circulationValue.font = font;
    _circulationValue.textAlignment = NSTextAlignmentCenter;
    _circulationValue.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_circulationValue];
    
    FMSelfStocksModel *model = [FMUserDefault getDapanDatas];
    if (model) {
        [self updateViewsWithModel:model infoModel:nil];
    }
    
    UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, kFMSelfStockTopViewsHeight-kFMSelfStockTopViewsBottomViewHeight, UIScreenWidth, kFMSelfStockTopViewsBottomViewHeight)];
    bg.backgroundColor = FMBgGreyColor;
    [fn drawLineWithSuperView:bg Color:FMBottomLineColor Location:0];
    [self addSubview:bg];
}

-(void)changeBgBackgroundColor:(UIColor*)color{
//    [UIView animateWithDuration:0.3 animations:^{
//        self.backgroundColor = color;
//        _bg.image = [UIImage imageWithColor:color andSize:self.frame.size];
//    }];
}

-(void)updateViewsWithModel:(FMSelfStocksModel*)model infoModel:(FMStockInfoModel*)info{
    if (model) {
        self.model = model;
        UIColor *bgcolor = FMGreyColor;
        
        if ([model.price floatValue]<=0) {
            model.price = @"-";
        }else{
            model.price = [NSString stringWithFormat:@"%.2f",[model.price floatValue]];
        }
        NSString *change = [model change];
        if (fabsf([change floatValue])<=0) {
            change = @"0.00";
        }
        if ([change floatValue]>0) {
            change = [NSString stringWithFormat:@"+ %@",change];
            
        }
        if ([change floatValue]<0) {
            change = [NSString stringWithFormat:@"- %.2f",fabsf([change floatValue])];
            
        }
        NSString *rate = [model changeRate];
        if (fabsf([rate floatValue])<=0) {
            rate = @"0.00%";
        }
        if ([rate floatValue]>0) {
            rate = [NSString stringWithFormat:@"+ %@%%",rate];
            bgcolor = FMRedColor;
        }
        if ([rate floatValue]<0) {
            rate = [NSString stringWithFormat:@"- %.2f%%",fabsf([rate floatValue])];
            bgcolor = FMGreenColor;
        }
        _titler.text = model.price;
        _change.text = [NSString stringWithFormat:@"%@ %@",change,rate];
        _change.textColor = bgcolor;
        //        _changeRate.text = rate;
        _time.text = [NSString stringWithFormat:@"%@ %@",model.lastDate,model.lastTime];
        [self changeBgBackgroundColor:bgcolor];
        //        _codeName.hidden = YES;
        //        if ([model.code isEqualToString:kStocksDapanCode]) {
        //            _codeName.hidden = NO;
        //            [FMUserDefault setDapanDatas:model];
        //        }
        if ([_model.openPrice floatValue]>0) {
            _openPrice.text = [NSString stringWithFormat:@"%.2f",[_model.openPrice floatValue]];
        }
        if ([_model.closePrice floatValue]>0) {
            _closePrice.text = [NSString stringWithFormat:@"%.2f",[_model.closePrice floatValue]];
        }
        if ([_model.highPrice floatValue]>0) {
            _highPrice.text = [NSString stringWithFormat:@"%.2f",[_model.highPrice floatValue]];
        }
        if ([_model.lowPrice floatValue]>0) {
            _lowPrice.text = [NSString stringWithFormat:@"%.2f",[_model.lowPrice floatValue]];
        }
        
        float volumn = [model.volumn floatValue]/100;
        if (volumn>0) {
            NSString *volStr = [NSString stringWithFormat:@"%.2f",volumn];
            if (volumn>9999) {
                volStr = [NSString stringWithFormat:@"%.2f 万",volumn/10000];
            }
            if (volumn>99999999) {
                volStr = [NSString stringWithFormat:@"%.2f 亿",volumn/100000000];
            }
            _volumn.text = volStr;
        }
        
        
        if (info) {
            if ([info.peRatio floatValue]>0)
            _peRatio.text = [NSString stringWithFormat:@"%.2f",[info.peRatio floatValue]];
            if ([info.turnoverRate floatValue]>0)
            _turnoverRate.text = [NSString stringWithFormat:@"%.2f%%",[info.turnoverRate floatValue]];
            if ([info.circulationValue floatValue]>0)
            _circulationValue.text = [NSString stringWithFormat:@"%.2f亿",[info.circulationValue floatValue]];
        }
        
        
        
        [self changeColorWithLb:_titler price:[_model.closePrice floatValue]];
        [self changeColorWithLb:_openPrice price:[_model.closePrice floatValue]];
        [self changeColorWithLb:_highPrice price:[_model.closePrice floatValue]];
        [self changeColorWithLb:_lowPrice price:[_model.closePrice floatValue]];
        [self changeColorWithLb:_titler price:[_model.closePrice floatValue]];
        [self changeColorWithLb:_titler price:[_model.closePrice floatValue]];
        [self changeColorWithLb:_titler price:[_model.closePrice floatValue]];
        [self changeColorWithLb:_titler price:[_model.closePrice floatValue]];
        [self changeColorWithLb:_titler price:[_model.closePrice floatValue]];
        
    }
}

-(void)changeColorWithLb:(UILabel*)lb price:(float)price{
    float me = [lb.text floatValue];
    if (me>price) {
        lb.textColor = FMRedColor;
    }
    if (me<price) {
        lb.textColor = FMGreenColor;
    }
    if (me==price) {
        lb.textColor = FMBlackColor;
    }
}

-(void)clickSelfAction{
    if (self.clickStockTopViewBlock) {
        self.clickStockTopViewBlock(self.model);
    }
}

@end
