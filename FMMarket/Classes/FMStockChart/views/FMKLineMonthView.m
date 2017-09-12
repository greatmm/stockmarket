//
//  FMKLineMonthView.m
//  FMStockChart
//
//  Created by dangfm on 15/8/19.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMKLineMonthView.h"
#import "HttpManager.h"
#import "FMHeader.h"
#import "FMStockLoadingView.h"
#import "FMStockDaysModel.h"
#import "FMStockMaxMinValues.h"
#import "FMStockTransformDatas.h"

@interface FMKLineMonthView()<UIScrollViewDelegate>{
    
}

@end

@implementation FMKLineMonthView
-(void)dealloc{
    NSLog(@"FMKLineMonthView dealloc");
}
-(instancetype)initWithFrame:(CGRect)frame Model:(FMStockModel*)model{
    if (self==[super initWithFrame:frame Model:model]) {
        [self startGetHttpStockDays];
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
    
    [FMCommon drawLineWithSuperView:self
                              Color:self.model.stage.lineColor
                              Frame:CGRectMake(0, 0, self.model.stage.lineWidth, self.model.stage.topHeight)];
    
    [FMCommon drawLineWithSuperView:self
                              Color:self.model.stage.lineColor
                              Frame:CGRectMake(self.model.stage.width-self.model.stage.lineWidth, 0, self.model.stage.lineWidth, self.model.stage.topHeight)];
    
    [self createScrollView];
}

-(void)createScrollView{
    if (!self.fmScrollView) {
        self.fmScrollView = [[FMKLineScrollView alloc] initWithFrame:self.bounds];
        self.fmScrollView.backgroundColor = [UIColor clearColor];
        self.fmScrollView.layer.masksToBounds = YES;
        self.fmScrollView.maximumZoomScale = 2.0;
        self.fmScrollView.minimumZoomScale = 1.0;
        self.fmScrollView.scrollEnabled = YES;
        self.fmScrollView.showsHorizontalScrollIndicator = NO;
        self.fmScrollView.showsVerticalScrollIndicator = NO;
        self.fmScrollView.delegate = self;
        self.fmScrollView.contentSize = CGSizeMake(self.frame.size.width+0.5, self.frame.size.height);
        [self addSubview:self.fmScrollView];
        
    }
    //    _lastScrollX = 0;
    //    [_fmScrollView setNeedsDisplayWithModel:self.model];
}

#pragma mark -
#pragma mark UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(FMKLineScrollView *)scrollView{
    self.model.isScrolling = NO;
}

-(void)scrollViewDidScroll:(FMKLineScrollView *)scrollView{
    //FMLog(@"scrolling-x=%f",scrollView.contentOffset.x);
    self.model.isScrolling = YES;
    [super removeCrossLine];
    if (fabsl(scrollView.contentOffset.x-self.lastScrollX)>=(self.model.klineWidth+self.model.klinePadding) || scrollView.contentOffset.x<=0) {
        self.lastScrollX = scrollView.contentOffset.x;
        [scrollView setNeedsDisplayWithModel:self.model];
    }
    
}

-(NSString*)fuquanType:(FMMarketFuquan_Type)fuquan{
    switch (fuquan) {
        case FMMarketFuquan_None:
            return @"";
            break;
        case FMMarketFuquan_Before:
            return @"before";
            break;
        case FMMarketFuquan_Back:
            return @"back";
            break;
            
        default:
            break;
    }
}

#pragma mark -
#pragma mark 网络请求
//  请求数据
-(void)startGetHttpStockDays{
    __FMWeakSelf;
    [HttpManager getHttpStockMonthsWithCode:self.model.stockCode  fuquanType:[self fuquanType:self.model.fuquanType] StartBlock:^{
        [FMStockLoadingView showWithSuperView:__weakSelf];
    } Success:^(NSDictionary *response,NSInteger statusCode){
        //FMLog(@"%@",response);
        
        // 准备数据
        [__weakSelf modelReadyWithResponse:response];
        
        
    } Failure:^(NSError*error){
        [FMStockLoadingView timeoutWithSuperView:__weakSelf block:^{
            [__weakSelf startGetHttpStockDays];
        }];
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
        for (NSInteger i=datas.count-1;i>=0;i--) {
//            NSMutableDictionary* item = [datas objectAtIndex:i];
//            FMStockDaysModel *model = [[FMStockDaysModel alloc] initWithDic:item];
//            [models addObject:model];
//            model = nil;
//            item = nil;
            NSArray *rs = datas[i];
            NSString *dateTime = [NSString stringWithFormat:@"%@",rs[0]];
            NSString *yestodayClosePrice = [NSString stringWithFormat:@"%@",rs[1]];
            NSString *closePrice = [NSString stringWithFormat:@"%@",rs[5]];
            NSString *openPrice = [NSString stringWithFormat:@"%@",rs[2]];
            NSString *highPrice = [NSString stringWithFormat:@"%@",rs[3]];
            NSString *lowPrice = [NSString stringWithFormat:@"%@",rs[4]];
            //NSString *price = [NSString stringWithFormat:@"%@",rs[5]];
            NSString *volumn = [NSString stringWithFormat:@"%.2f",[rs[6] floatValue]/100];
            NSString *volumnPrice = [NSString stringWithFormat:@"%@",rs[7]];
            
            FMStockDaysModel *model = [[FMStockDaysModel alloc] init];
            model.openPrice = openPrice;
            model.datetime = dateTime;
            model.closePrice = closePrice;
            model.heightPrice = highPrice;
            model.lowPrice = lowPrice;
            model.volumn = volumn;
            model.volPrice = volumnPrice;
            model.yestodayClosePrice = yestodayClosePrice;
            [models addObject:model];
            model = nil;
            rs = nil;
            dateTime = nil;
            closePrice = nil;
            openPrice = nil;
            highPrice = nil;
            lowPrice = nil;
            //price = nil;
            volumnPrice = nil;
            volumn = nil;
            
        }
        __weakSelf.model.prices = models;
        __weakSelf.model.counts = (int)__weakSelf.model.prices.count;
        __weakSelf.model.isReset = NO;
        // 计算指标
        [FMStockTransformDatas createWithModel:__weakSelf.model];
        // 偏移
        [FMStockMaxMinValues setOffsetWithModel:__weakSelf.model];
        // 计算最大最小值
        [FMStockMaxMinValues createWithModel:__weakSelf.model];
        datas = nil;
        models = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            // 拿到数据 初始化界面
            [__weakSelf initBaseViews];
            // 滚动到最后
            [__weakSelf.fmScrollView setNeedsDisplayWithModel:__weakSelf.model];
            // 更新成交量显示
            [super updateWithModel:__weakSelf.model];
            CGFloat scrollx = __weakSelf.fmScrollView.contentSize.width-__weakSelf.fmScrollView.frame.size.width;
            [__weakSelf.fmScrollView setContentOffset:CGPointMake(scrollx, 0)];
            
            [FMStockLoadingView removeFromSuperView:__weakSelf];
            
            if ([__weakSelf.delegate respondsToSelector:@selector(FMBaseViewDrawFinished:)]) {
                [__weakSelf.delegate FMBaseViewDrawFinished:__weakSelf];
            }
        });
    });
    
    
}

-(void)updateWithModel:(FMStockModel *)model{
    self.model = model;
    [self.fmScrollView setNeedsDisplayWithModel:self.model];
}

@end
