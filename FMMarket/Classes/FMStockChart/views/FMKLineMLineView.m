//
//  FMKLineMLineView.m
//  FMStockChart
//
//  Created by dangfm on 17/1/11.
//  Copyright © 2017年 dangfm. All rights reserved.
//

#import "FMKLineMLineView.h"

#import "HttpManager.h"
#import "FMHeader.h"
#import "FMStockLoadingView.h"
#import "FMStockDaysModel.h"
#import "FMStockMaxMinValues.h"
#import "FMStockTransformDatas.h"
#import "FMStockNewDataModel.h"

#define fmFMKLineDaysDataLocalKey @"fmFMKLineDaysDataLocalKey"
#define fmFMKLineDaysDataLoopTime 30

@interface FMKLineMLineView()<UIScrollViewDelegate>{
    
}

@end
@implementation FMKLineMLineView

-(void)dealloc{
    NSLog(@"FMKLineDaysView dealloc");
}
-(void)clear{
    
    self.model = nil;
    self.fmScrollView.delegate = nil;
    self.fmScrollView = nil;
    self.delegate = nil;
    [super clear];
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
        // 代理
        if ([self.delegate respondsToSelector:@selector(FMBaseViewScrolling:model:scrollX:)]) {
            [self.delegate FMBaseViewScrolling:self model:self.model.subPrices.lastObject scrollX:scrollView.contentOffset.x];
        }
    }
    
}

-(int)timeInterval:(FMStockChartType)chartType{
    switch (chartType) {
        case FMStockType_1MinuteChart:
            return 1;
            break;
        case FMStockType_5MinuteChart:
            return 5;
            break;
        case FMStockType_15MinuteChart:
            return 15;
            break;
        case FMStockType_30MinuteChart:
            return 30;
            break;
        case FMStockType_60MinuteChart:
            return 60;
            break;
        default:
            return 1;
            break;
    }
}

#pragma mark -
#pragma mark 网络请求
//  请求数据
-(void)startGetHttpStockDays{
    [self getHttpStockNewData];
    
    __FMWeakSelf;
    [HttpManager getHttpStockMKlineWithCode:self.model.stockCode minute:[self timeInterval:self.model.type] StartBlock:^{
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

//  循环请求股票的当前行情并缓存在本地
-(void)getHttpStockNewData{
    NSLog(@"请求分钟k");
    __FMWeakSelf;
    [HttpManager getHttpStockNewDataWithCode:self.model.stockCode StartBlock:^{
        
    } Success:^(NSDictionary *response,NSInteger statusCode){
        //FMLog(@"%@",response);
        response = [response objectForKey:@"data"];
        if ([response isEqual:[NSNull null]]) {
            return ;
        }
        // 缓存数据
        NSData *json = [NSJSONSerialization dataWithJSONObject:response
                                                       options:NSJSONWritingPrettyPrinted error:nil];
        NSString *value = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
        [MKUserDefault setSeting:[NSString stringWithFormat:@"%@_%@",fmFMKLineDaysDataLocalKey,__weakSelf.model.stockCode] Value:value];
        json = nil;
        value = nil;
        [__weakSelf loopGetStockNewData];
    } Failure:^(NSError*error){
        [__weakSelf loopGetStockNewData];
    }];
}

-(void)loopGetStockNewData{
    //    [self performSelector:@selector(getHttpStockNewData)
    //               withObject:nil
    //               afterDelay:fmFMKLineDaysDataLoopTime];
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
        NSString *lastClose = @"";
        for (NSInteger i=datas.count-1;i>=0;i--) {
            //            NSMutableDictionary* item = [datas objectAtIndex:i];
            //            FMStockDaysModel *model = [[FMStockDaysModel alloc] initWithDic:item];
            //            [models addObject:model];
            //            model = nil;
            NSArray *rs = datas[i];
            NSString *dateTime = [NSString stringWithFormat:@"%@",rs[0]];
//            NSString *yestodayClosePrice = [NSString stringWithFormat:@"%@",rs[1]];
//            if (i==datas.count-1) {
//                lastClose = yestodayClosePrice;
//            }
//            NSString *closePrice = [NSString stringWithFormat:@"%@",rs[2]];
//            NSString *openPrice = [NSString stringWithFormat:@"%@",rs[1]];
//            NSString *highPrice = [NSString stringWithFormat:@"%@",rs[3]];
//            NSString *lowPrice = [NSString stringWithFormat:@"%@",rs[4]];
//            //NSString *price = [NSString stringWithFormat:@"%@",rs[5]];
//            NSString *volumn = [NSString stringWithFormat:@"%@",rs[5]];
////            NSString *volumnPrice = [NSString stringWithFormat:@"%@",rs[7]];
//            if (__weakSelf.model.type==FMStockType_1MinuteChart) {
//                closePrice = [NSString stringWithFormat:@"%@",rs[5]];
//                openPrice = [NSString stringWithFormat:@"%@",rs[2]];
//                highPrice = [NSString stringWithFormat:@"%@",rs[3]];
//                lowPrice = [NSString stringWithFormat:@"%@",rs[4]];
//                //NSString *price = [NSString stringWithFormat:@"%@",rs[5]];
//                volumn = [NSString stringWithFormat:@"%@",rs[6]];
//            }
            
            NSString *closePrice = [NSString stringWithFormat:@"%@",rs[5]];
            NSString *openPrice = [NSString stringWithFormat:@"%@",rs[2]];
            NSString *highPrice = [NSString stringWithFormat:@"%@",rs[3]];
            NSString *lowPrice = [NSString stringWithFormat:@"%@",rs[4]];
            lastClose = [NSString stringWithFormat:@"%@",rs[1]];
            NSString *volumn = [NSString stringWithFormat:@"%@",rs[6]];
            NSString *volumnPrice = [NSString stringWithFormat:@"%@",rs[7]];
            
            
            FMStockDaysModel *model = [[FMStockDaysModel alloc] init];
            model.openPrice = openPrice;
            model.datetime = dateTime;
            model.closePrice = closePrice;
            model.heightPrice = highPrice;
            model.lowPrice = lowPrice;
            model.volumn = volumn;
            model.volPrice = volumnPrice;
            model.yestodayClosePrice = lastClose;
            lastClose = closePrice;
            [models addObject:model];
            model = nil;
            rs = nil;
            dateTime = nil;
            closePrice = nil;
            openPrice = nil;
            highPrice = nil;
            lowPrice = nil;
            //price = nil;
//            volumnPrice = nil;
            volumn = nil;
        }
        // 在前面添加最新的行情数据 如果缓存有的话
//        NSString *localData = [FMUserDefaults getSeting:[NSString stringWithFormat:@"%@_%@",fmFMKLineDaysDataLocalKey,self.model.stockCode]];
//        if (localData) {
//            FMStockDaysModel *last = [models lastObject];
//            NSData *data = [localData dataUsingEncoding:NSUTF8StringEncoding];
//            NSArray *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
//            FMStockNewDataModel *newData = [[FMStockNewDataModel alloc] initWithDic:[json firstObject]];
//            NSString *datetime = [newData.lastDate stringByReplacingOccurrencesOfString:@"-" withString:@""];
//            if ([datetime isEqualToString:last.datetime]) {
//                [models removeObject:last];
//                last = [models lastObject];
//            }
//            if (![datetime isEqualToString:last.datetime]) {
//                FMStockDaysModel *m = [[FMStockDaysModel alloc] init];
//                // 如果后复权，则要换算下数据
//                if (__weakSelf.model.fuquanType==FMMarketFuquan_Back) {
//                    float bili = [newData.closePrice floatValue] / [last.closePrice floatValue];
//                    newData.price = [NSString stringWithFormat:@"%.2f",[newData.price floatValue]/bili];
//                    newData.openPrice = [NSString stringWithFormat:@"%.2f",[newData.openPrice floatValue]/bili];
//                    newData.highPrice = [NSString stringWithFormat:@"%.2f",[newData.highPrice floatValue]/bili];
//                    newData.lowPrice = [NSString stringWithFormat:@"%.2f",[newData.lowPrice floatValue]/bili];
//                    newData.closePrice = [NSString stringWithFormat:@"%.2f",[newData.closePrice floatValue]/bili];
//                }
//                
//                m.closePrice = newData.price;
//                m.openPrice = newData.openPrice;
//                m.heightPrice = newData.highPrice;
//                m.lowPrice = newData.lowPrice;
//                m.volumn = [NSString stringWithFormat:@"%@0000",newData.volumn];
//                m.volPrice = newData.volumnPrice;
//                m.yestodayClosePrice = newData.closePrice;
//                m.datetime = datetime;
//                m.code = newData.code;
//                if ([m.closePrice floatValue]>0 && [m.openPrice floatValue]>0) {
//                    [models addObject:m];
//                }
//                
//                m = nil;
//            }
//            
//            
//            newData = nil;
//            data = nil;
//            json = nil;
//        }
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
            [FMStockLoadingView removeFromSuperView:__weakSelf];
            // 拿到数据 初始化界面
            [__weakSelf initBaseViews];
            // 滚动到最后
            [__weakSelf.fmScrollView setNeedsDisplayWithModel:__weakSelf.model];
            // 更新成交量显示
            [super updateWithModel:__weakSelf.model];
            
            CGFloat scrollx = __weakSelf.fmScrollView.contentSize.width-__weakSelf.fmScrollView.frame.size.width;
            [__weakSelf.fmScrollView setContentOffset:CGPointMake(scrollx, 0)];
            
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
