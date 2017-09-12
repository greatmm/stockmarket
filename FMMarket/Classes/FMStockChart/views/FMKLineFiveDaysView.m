//
//  FMKLineFiveDaysView.m
//  FMStockChart
//
//  Created by dangfm on 15/8/19.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMKLineFiveDaysView.h"
#import "HttpManager.h"
#import "FMHeader.h"
#import "FMStockLoadingView.h"
#import "FMStockMinuteModel.h"
#import "FMStockMaxMinValues.h"
#import "FMStockTransformDatas.h"

@interface FMKLineFiveDaysView(){
    BOOL _isLoop;
    
}

@property (nonatomic,retain) NSMutableArray *oneDatas;
@property (nonatomic,retain) NSMutableArray *allPrices;
//@property (nonatomic,retain) NSMutableArray *allModels;
@property (nonatomic,retain) FMKLineScrollView *scroll_1;
@property (nonatomic,retain) FMKLineScrollView *scroll_2;
@property (nonatomic,retain) FMKLineScrollView *scroll_3;
@property (nonatomic,retain) FMKLineScrollView *scroll_4;

@end
@implementation FMKLineFiveDaysView
-(void)dealloc{
    NSLog(@"FMKLineFiveDaysView dealloc");
}
-(void)clear{
    self.model = nil;
    self.fmScrollView.delegate = nil;
    self.fmScrollView = nil;
    self.delegate = nil;
    [self.oneDatas removeAllObjects];
    self.oneDatas = nil;
    self.scroll_1.delegate = nil;
    self.scroll_2.delegate = nil;
    self.scroll_3.delegate = nil;
    self.scroll_4.delegate = nil;
    self.scroll_1 = nil;
    self.scroll_2 = nil;
    self.scroll_3 = nil;
    self.scroll_4 = nil;
    [self.allPrices removeAllObjects];
    self.allPrices = nil;
    [super clear];
}

-(instancetype)initWithFrame:(CGRect)frame Model:(FMStockModel*)model{
    if (self==[super initWithFrame:frame Model:model]) {
        model.klineWidth = 1.0f;
        _allPrices = [NSMutableArray new];
        if (self.model.realtimeData) {
            if (self.model.realtimeData.length>2) {
                self.model.realtimeData = [self.model.realtimeData substringFromIndex:2];
                self.model.realtimeData = [self.model.realtimeData stringByReplacingOccurrencesOfString:@"-" withString:@""];
            }
        }
        [self startGetHttpStockMinute];
    }
    return self;
}

-(void)initBaseViews{
    self.model.stage.width = self.frame.size.width;
    self.model.stage.height = self.frame.size.height;
    
    if (self.model.stockChartDirectionStyle==FMStockDirection_Horizontal) {
        self.layer.borderColor = self.model.stage.lineColor.CGColor;
        self.layer.borderWidth = self.model.stage.lineWidth;
        self.model.stage.topHeight = self.frame.size.height/4*3;
        self.model.stage.bottomHeight = self.frame.size.height/4-self.model.stage.padding.middle;
    }else{
        self.model.stage.topHeight = self.frame.size.height/4*3;
        self.model.stage.bottomHeight = self.frame.size.height/4-self.model.stage.padding.middle;
        // 上下
        [FMCommon drawLineWithSuperView:self Color:self.model.stage.lineColor Location:0];
        [FMCommon drawLineWithSuperView:self Color:self.model.stage.lineColor Location:1];
    }
    // 分割线
    [FMCommon drawLineWithSuperView:self
                              Color:self.model.stage.lineColor
                              Frame:CGRectMake(0, self.model.stage.topHeight, self.model.stage.width, self.model.stage.lineWidth)];
    // 中线
    [FMCommon drawLineWithSuperView:self
                              Color:self.model.stage.middleLineColor
                              Frame:CGRectMake(0, self.model.stage.topHeight/2, self.model.stage.width, self.model.stage.lineWidth)];
    
    [self createScrollView];
}

-(void)createScrollView{
    if (!self.fmScrollView) {
        self.fmScrollView = [self createSVWithIndex:0];
        
        [FMCommon drawLineWithSuperView:self.fmScrollView
                                  Color:self.model.stage.middleLineColor
                                  Frame:CGRectMake(self.fmScrollView.frame.size.width-self.model.stage.lineWidth, 0, self.model.stage.lineWidth, self.model.stage.height)];
    }
    if (!_scroll_1) {
        _scroll_1 = [self createSVWithIndex:1];
        [FMCommon drawLineWithSuperView:_scroll_1
                                  Color:self.model.stage.middleLineColor
                                  Frame:CGRectMake(_scroll_1.frame.size.width-self.model.stage.lineWidth, 0, self.model.stage.lineWidth, self.model.stage.height)];
    }
    if (!_scroll_2) {
        _scroll_2 = [self createSVWithIndex:2];
        [FMCommon drawLineWithSuperView:_scroll_2
                                  Color:self.model.stage.middleLineColor
                                  Frame:CGRectMake(_scroll_2.frame.size.width-self.model.stage.lineWidth, 0, self.model.stage.lineWidth, self.model.stage.height)];
    }
    if (!_scroll_3) {
        _scroll_3 = [self createSVWithIndex:3];
        [FMCommon drawLineWithSuperView:_scroll_3
                                  Color:self.model.stage.middleLineColor
                                  Frame:CGRectMake(_scroll_3.frame.size.width-self.model.stage.lineWidth, 0, self.model.stage.lineWidth, self.model.stage.height)];
    }
    if (!_scroll_4) {
        _scroll_4 = [self createSVWithIndex:4];
    }
}

-(FMKLineScrollView*)createSVWithIndex:(NSInteger)index{
    CGFloat w = self.bounds.size.width/5;
    FMKLineScrollView *sv = [[FMKLineScrollView alloc] initWithFrame:CGRectMake(index*w, 0, w, self.bounds.size.height)];
    sv.backgroundColor = [UIColor clearColor];
    sv.layer.masksToBounds = YES;
    sv.maximumZoomScale = 2.0;
    sv.minimumZoomScale = 1.0;
    sv.scrollEnabled = NO;
    sv.showsHorizontalScrollIndicator = NO;
    sv.showsVerticalScrollIndicator = NO;
    sv.contentSize = CGSizeMake(self.frame.size.width+0.5, 0);
    [self addSubview:sv];
    if (index<self.model.times.count) {
        NSString *dateStr = [self.model.times objectAtIndex:index];
        [self createDateTextWithSuperView:sv date:dateStr];
    }

    return sv;
}
-(void)createDateTextWithSuperView:(UIView*)superView date:(NSString*)dateStr{
    if ([dateStr rangeOfString:@"-"].location==NSNotFound && dateStr.length>=6) {
        dateStr = [NSString stringWithFormat:@"%@-%@",[dateStr substringWithRange:NSMakeRange(2, 2)],[dateStr substringWithRange:NSMakeRange(4, 2)]];
    }
    UILabel *l = [[UILabel alloc] init];
    l.font = self.model.stage.font;
    l.textColor = self.model.stage.fontColor;
    l.text = dateStr;
    l.textAlignment = NSTextAlignmentCenter;
    l.frame = CGRectMake(0, self.model.stage.topHeight, superView.frame.size.width, l.font.pointSize+4);
    [superView addSubview:l];
    l = nil;
}


#pragma mark -
#pragma mark 网络请求

//  请求分时图数据
-(void)startGetHttpStockMinute{
    // 验证昨日收盘价
    if (self.model.yestodayClosePrice <=0) {
        
        return;
    }
    NSLog(@"请求分时图");
    __FMWeakSelf;
    [HttpManager getHttpStockMinuteWithCode:self.model.stockCode StartBlock:^{
        if (!_isLoop) {
            [FMStockLoadingView showWithSuperView:__weakSelf];
        }
    } Success:^(NSDictionary *response,NSInteger statusCode){
        //FMLog(@"%@",response);
        
        // 准备数据
        [__weakSelf modelReadyWithResponseForMinute:response];
        
        
    } Failure:^(NSError*error){
        [FMStockLoadingView timeoutWithSuperView:__weakSelf block:^{
            [__weakSelf startGetHttpStockMinute];
        }];
        // 循环刷新
        [__weakSelf loopRefrehMinute];
    }];
}

//  整理数据
-(void)modelReadyWithResponseForMinute:(NSDictionary*)response{
    __FMWeakSelf;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableArray *datas = [response objectForKey:@"data"];
        if ([datas isEqual:[NSNull null]]) {
            return;
        }
        if (__weakSelf.oneDatas) {
            [__weakSelf.oneDatas removeAllObjects];
            __weakSelf.oneDatas = nil;
        }
        
        
        NSMutableArray *models = [NSMutableArray new];
        for (NSMutableDictionary* item in datas) {
            FMStockMinuteModel *model = [[FMStockMinuteModel alloc] initWithDic:item];
            model.yestodayClosePrice = [NSString stringWithFormat:@"%.2f",__weakSelf.model.yestodayClosePrice];
            model.volumn = [NSString stringWithFormat:@"%.f",[model.volumn floatValue]*10];
            [models addObject:model];
    
            model = nil;
        }
        
        __weakSelf.oneDatas = models;
        models = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            [__weakSelf startGetHttpStockFiveDays];
        });
        
    });
}



//  请求数据
-(void)startGetHttpStockFiveDays{
    // 验证昨日收盘价
    if (self.model.yestodayClosePrice <=0) {
        
        return;
    }
    

    
    
    __FMWeakSelf;
    [HttpManager getHttpStockFiveDaysWithCode:self.model.stockCode StartBlock:^{
        if (!_isLoop) {
            [FMStockLoadingView showWithSuperView:__weakSelf];
        }
    } Success:^(NSDictionary *response,NSInteger statusCode){
        //FMLog(@"%@",response);
        
        // 准备数据
        [__weakSelf modelReadyWithResponse:response];
        
        
    } Failure:^(NSError*error){
        [FMStockLoadingView timeoutWithSuperView:__weakSelf block:^{
            [__weakSelf startGetHttpStockMinute];
        }];
        // 循环刷新
        [__weakSelf loopRefrehMinute];
    }];
}

//  整理数据
-(void)modelReadyWithResponse:(NSDictionary*)response{
    
    __FMWeakSelf;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableArray *datas = [response objectForKey:@"data"];
        if ([datas isEqual:[NSNull null]]) {
            return;
        }
        [__weakSelf.allPrices removeAllObjects];
        [__weakSelf.model.times removeAllObjects];
    
        NSMutableArray *allModels = [NSMutableArray new];
        // 这里要坐下五日的最新行情处理
        int start = 0;
        if (datas.count>=5) {
            start = (int)datas.count - 1;
            NSMutableDictionary *item = datas[0];
//            NSString *dt = item[@"data"];
//            NSArray *list = [dt componentsSeparatedByString:@"^"];
            NSString *date = item[@"date"];
//            NSString *prec = item[@"prec"];
            
            // 如果最新一天的时间跟实时行情不一致
            if ([date intValue] < [__weakSelf.model.realtimeData intValue]) {
                start = (int)datas.count - 2;
            }
        }
        
        for (int i=(int)start;i>=0;i--) {
            NSMutableDictionary *item = datas[i];
            NSString *dt = item[@"data"];
            NSArray *list = [dt componentsSeparatedByString:@"^"];
            NSString *date = item[@"date"];
            NSString *prec = item[@"prec"];
            
            if (i==start) {
                __weakSelf.model.yestodayClosePrice = [prec doubleValue];
            }
            
            [__weakSelf.model.times addObject:date];
            NSMutableArray *models = [NSMutableArray new];
            double preVolumn = 0;
            double preVolumnPrice = 0;
            double lastPrice = __weakSelf.model.yestodayClosePrice;
            for (NSString *values in list) {
                
                // 时间 ～ 当前价格 ～ 成交量 ～ 成交额
                NSArray *vs = [values componentsSeparatedByString:@"~"];
                
                if (vs.count>=4) {
                    FMStockMinuteModel *model = [[FMStockMinuteModel alloc] init];
                    model.yestodayClosePrice = [NSString stringWithFormat:@"%.2f",__weakSelf.model.yestodayClosePrice];
                    model.datetime = vs[0];
                    model.price = vs[1];
                    model.volumn = vs[2];
                    model.volumnPrice = vs[3];
                    model.averagePrice = [NSString stringWithFormat:@"%.2f",([model.volumnPrice doubleValue]/[model.volumn doubleValue]/100)];
                    model.volumn = [NSString stringWithFormat:@"%.2f",([model.volumn doubleValue]*100 - preVolumn)];
                    model.volumn = [NSString stringWithFormat:@"%.2f",([model.volumnPrice doubleValue] - preVolumnPrice)];
                    preVolumnPrice = [vs[3] doubleValue];
                    preVolumn = [vs[2] doubleValue];
                    if ([model.price doubleValue]>lastPrice) {
                        model.color = @"1";
                    }else{
                        model.color = @"0";
                    }
                    lastPrice = [model.price doubleValue];
//                    if ([model.datetime intValue] % 3==0) {
//                        [models addObject:model];
//                    }
                    [models addObject:model];
                    [allModels addObject:model];
                    model = nil;
                }
                
                vs = nil;
            }
            [__weakSelf.allPrices addObject:models];
            models = nil;
            item = nil;
            dt = nil;
            list = nil;
            date = nil;
            prec = nil;
        }
        
        if (start==datas.count-2) {
             [__weakSelf.model.times addObject:__weakSelf.model.realtimeData];
            // 把分时图加在最后面
            for (FMStockDaysModel *m in __weakSelf.oneDatas) {
                [allModels addObject:m];
            }
            [__weakSelf.allPrices addObject:__weakSelf.oneDatas];
        }
        
        datas = nil;
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // 拿到数据 初始化界面
            [__weakSelf initBaseViews];
        });
        __block int i = 0;
        
        // 最大值最小值
        // 计算最大最小值
        __weakSelf.model.prices = allModels;
        [FMStockMaxMinValues createMinuteWithModel:__weakSelf.model];
        allModels = nil;
        for (NSMutableArray *ms in __weakSelf.allPrices) {
            FMStockModel *m = [[FMStockModel alloc] init];
            m.type = __weakSelf.model.type;
            m.stage = __weakSelf.model.stage;
            m.stage.width = __weakSelf.bounds.size.width/(int)__weakSelf.allPrices.count;
            m.yestodayClosePrice = __weakSelf.model.yestodayClosePrice;
            m.stockCode = __weakSelf.model.stockCode;
            m.isOpenSignal = NO;
            m.prices = ms;
            m.counts = (int)ms.count;
            m.isReset = NO;
            m.klineWidth = __weakSelf.model.klineWidth;
            m.klinePadding = __weakSelf.model.klinePadding;
            // 处理数据
            //[FMStockTransformDatas createMinuteWithModel:m];
            [FMStockMaxMinValues createMinuteWithModel:m];
            m.maxPrice = __weakSelf.model.maxPrice;
            m.minPrice = __weakSelf.model.minPrice;
            m.bottomMaxPrice = __weakSelf.model.bottomMaxPrice;
            m.bottomMinPrice = __weakSelf.model.bottomMinPrice;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (i>0) {
                    m.isShowRightText = NO;
                    m.isShowLeftText = NO;
                }
                if (i==0) {
                    m.isShowRightText = NO;
                }
                if (i==4) {
                    m.isShowRightText = YES;
                }
                
                // 画图
                switch (i) {
                    case 0:
                        [__weakSelf.fmScrollView setNeedsDisplayWithModel:m];
                        break;
                    case 1:
                        [__weakSelf.scroll_1 setNeedsDisplayWithModel:m];
                        break;
                    case 2:
                        [__weakSelf.scroll_2 setNeedsDisplayWithModel:m];
                        break;
                    case 3:
                        [__weakSelf.scroll_3 setNeedsDisplayWithModel:m];
                        break;
                    case 4:
                        [__weakSelf.scroll_4 setNeedsDisplayWithModel:m];
                        break;
                    default:
                        break;
                }
                i++;
            });
            m = nil;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [FMStockLoadingView removeFromSuperView:__weakSelf];
            if ([__weakSelf.delegate respondsToSelector:@selector(FMBaseViewDrawFinished:)]) {
                [__weakSelf.delegate FMBaseViewDrawFinished:__weakSelf];
            }
            // 循环刷新
            [__weakSelf loopRefrehMinute];
        });
        
    });
}

-(void)loopRefrehMinute{
    _isLoop = YES;
    [self performSelector:@selector(startGetHttpStockMinute) withObject:nil afterDelay:self.model.minuteRefreshTime];
}

-(void)updateWithModel:(FMStockModel *)model{
    self.model = model;
    [self.fmScrollView setNeedsDisplayWithModel:self.model];
}

@end
