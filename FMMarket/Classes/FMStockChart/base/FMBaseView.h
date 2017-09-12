//
//  FMBaseView.h
//  FMStockChart
//
//  Created by dangfm on 15/7/25.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMHeader.h"
#import "FMStockModel.h"
#import "FMStockDaysModel.h"
#import "FMKLineScrollView.h"

@protocol FMBaseViewDelegate;

@interface FMBaseView : UIView

@property (nonatomic,retain) FMStockModel *model;
@property (nonatomic,retain) FMKLineScrollView *fmScrollView;
@property (nonatomic,assign) CGFloat lastScrollX;
@property (nonatomic,retain) UIView *hLine;
@property (nonatomic,retain) UILabel *hTip;
@property (nonatomic,retain) UIView *vLine;
@property (nonatomic,retain) UILabel *vTip;
@property (nonatomic,retain) UIView *topTips;
@property (nonatomic,retain) UIView *bottomTips;
@property (nonatomic,retain) UILabel *dateTips;
@property (nonatomic,retain) UIView *tipViews;
@property (nonatomic,assign) id<FMBaseViewDelegate> delegate;

/**
 *  初始化
 *
 *  @param frame 位置
 *  @param model 模型
 *
 *  @return FMBaseView
 */
-(instancetype)initWithFrame:(CGRect)frame Model:(FMStockModel*)model;

-(void)updateWithModel:(FMStockModel*)model;
-(void)clear;
//  移除十字线
-(void)removeCrossLine;
@end

@protocol FMBaseViewDelegate <NSObject>

@optional

/**
 *  点击
 *
 *  @param baseView 本身
 */
-(void)FMBaseViewSingleClickAction:(FMBaseView*)baseView;

/**
 *  点击幅图
 *
 *  @param baseView 本身
 */
-(void)FMBaseViewSingleClickBottomViewAction:(FMBaseView*)baseView;

/**
 *  按压移动
 *
 *  @param baseView 本身
 *  @param model    当前周期模型
 */
-(void)FMBaseViewMovingFinger:(FMBaseView*)baseView model:(FMStockDaysModel*)model;
/**
 *  按压移动
 *
 *  @param baseView 本身
 *  @param model    当前周期模型
 *  @param isHide   是否要隐藏，就是当手指弹起的时候，返回true
 */
-(void)FMBaseViewMovingFinger:(FMBaseView*)baseView model:(FMStockDaysModel*)model isHide:(BOOL)isHide;
/**
 *  滚动事件
 *
 *  @param baseView 本身
 *  @param model    当前周期模型
 *  @param scrollX  滚动的X轴
 */
-(void)FMBaseViewScrolling:(FMBaseView*)baseView model:(FMStockDaysModel*)model scrollX:(float)scrollX;

/**
 *  图表加载完成
 *
 *  @param baseView 本身
 */
-(void)FMBaseViewDrawFinished:(FMBaseView*)baseView;


@end
