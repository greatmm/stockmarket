//
//  FMKLineMinuteView.m
//  FMStockChart
//
//  Created by dangfm on 15/8/19.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMKLineMinuteView.h"
#import "HttpManager.h"
#import "FMHeader.h"
#import "FMStockLoadingView.h"
#import "FMStockMinuteModel.h"
#import "FMStockMaxMinValues.h"
#import "FMStockTransformDatas.h"


@interface FMKLineMinuteView(){
    BOOL _isLoop;
}

@end
@implementation FMKLineMinuteView

-(void)dealloc{
    NSLog(@"FMKLineMinuteView dealloc");
}
-(void)clear{
    self.model = nil;
    self.fmScrollView.delegate = nil;
    self.fmScrollView = nil;
    self.delegate = nil;
    [self.stallsView clear];
    [super clear];
}
-(instancetype)initWithFrame:(CGRect)frame Model:(FMStockModel*)model{
    if (self==[super initWithFrame:frame Model:model]) {
        model.klineWidth = 1.0f;
        [self initParams];
        [self createStallsView];
        [self startGetHttpStockDays];
    }
    return self;
}

-(void)initParams{
    if ([self.model.stockType intValue]==1) {
        self.model.stage.width = self.frame.size.width;
        self.model.stage.height = self.frame.size.height;
    }else{
        self.model.stage.width = self.frame.size.width-kFMFiveStallsViewDefaultWidth;
        self.model.stage.height = self.frame.size.height;
    }
    
    
}

-(void)initBaseViews{
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
    // 分4份
    double subFourHeight = self.model.stage.topHeight / 4;
    // 分割线
    [FMCommon drawLineWithSuperView:self
                              Color:self.model.stage.lineColor
                              Frame:CGRectMake(0, self.model.stage.topHeight, self.model.stage.width, self.model.stage.lineWidth)];
    
    [FMCommon drawLineWithSuperView:self
                              Color:self.model.stage.lineColor
                              Frame:CGRectMake(0, self.model.stage.topHeight-subFourHeight, self.model.stage.width, self.model.stage.lineWidth)];
    
    // 中线
    //    [FMCommon drawLineWithSuperView:self
    //                              Color:self.model.stage.middleLineColor
    //                              Frame:CGRectMake(0, self.model.stage.topHeight/2, self.model.stage.width, self.model.stage.lineWidth)];
    
    [FMCommon drawLineWithSuperView:self
                              Color:self.model.stage.lineColor
                              Frame:CGRectMake(0, self.model.stage.topHeight-3*subFourHeight, self.model.stage.width, self.model.stage.lineWidth)];
    
    //
    
    // 竖线分5份
    double subFourWidth = self.model.stage.width/4;
    float x = 0;
    float y = 0;
    float w = self.model.stage.lineWidth;
    float h = self.model.stage.topHeight;
    
    for (int i=0;i<5; i++) {
        [FMCommon drawLineWithSuperView:self
                                  Color:self.model.stage.lineColor
                                  Frame:CGRectMake(x, y, w, h)];
        x += subFourWidth;
    }

    [self createScrollView];
    
}

-(void)createScrollView{
    if (!self.fmScrollView) {
        self.fmScrollView = [[FMKLineScrollView alloc] initWithFrame:CGRectMake(0, 0, self.model.stage.width, self.model.stage.height)];
        self.fmScrollView.backgroundColor = [UIColor clearColor];
        self.fmScrollView.layer.masksToBounds = YES;
        self.fmScrollView.maximumZoomScale = 2.0;
        self.fmScrollView.minimumZoomScale = 1.0;
        self.fmScrollView.scrollEnabled = YES;
        self.fmScrollView.showsHorizontalScrollIndicator = NO;
        self.fmScrollView.showsVerticalScrollIndicator = NO;
        self.fmScrollView.contentSize = CGSizeMake(self.frame.size.width+0.5, 0);
        [self addSubview:self.fmScrollView];
        
        _stallsView.hidden = NO;
    }
    //    _lastScrollX = 0;
    //    [_fmScrollView setNeedsDisplayWithModel:self.model];
}

-(void)createStallsView{
    if ([self.model.stockType intValue]==1) {
        return;
    }
    if (!self.stallsView) {
        _stallsView = [[FMFiveStallsView alloc] initWithFrame:CGRectMake(self.model.stage.width+5, 0, kFMFiveStallsViewDefaultWidth, self.model.stage.height) StockCode:self.model.stockCode];
        _stallsView.font = self.model.stage.font;
        _stallsView.textFont = _stallsView.font;
        _stallsView.hidden = YES;
        [self addSubview:_stallsView];
    }
}

#pragma mark -
#pragma mark 网络请求
//  请求数据
-(void)startGetHttpStockDays{
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
        [__weakSelf modelReadyWithResponse:response];
        
        
    } Failure:^(NSError*error){
        [FMStockLoadingView timeoutWithSuperView:__weakSelf block:^{
            [__weakSelf startGetHttpStockDays];
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
        
        NSMutableArray *models = [NSMutableArray new];
        for (NSMutableDictionary* item in datas) {
            FMStockMinuteModel *model = [[FMStockMinuteModel alloc] initWithDic:item];
            model.yestodayClosePrice = [NSString stringWithFormat:@"%.2f",__weakSelf.model.yestodayClosePrice];
            [models addObject:model];
            model = nil;
        }
        __weakSelf.model.prices = models;
        __weakSelf.model.counts = (int)__weakSelf.model.prices.count;
        __weakSelf.model.isReset = NO;
        // 处理数据
        [FMStockTransformDatas createMinuteWithModel:__weakSelf.model];
        // 计算最大最小值
        [FMStockMaxMinValues createMinuteWithModel:__weakSelf.model];
        datas = nil;
        models = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            // 拿到数据 初始化界面
            [__weakSelf initBaseViews];
            // 画图
            [__weakSelf.fmScrollView setNeedsDisplayWithModel:__weakSelf.model];
            // 更新成交量显示
            [super updateWithModel:__weakSelf.model];
            
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
    [self performSelector:@selector(startGetHttpStockDays) withObject:nil afterDelay:self.model.minuteRefreshTime];
}

-(void)updateWithModel:(FMStockModel *)model{
    self.model = model;
    [self.fmScrollView setNeedsDisplayWithModel:self.model];
}
@end
