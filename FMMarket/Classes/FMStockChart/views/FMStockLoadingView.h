//
//  FMStockLoadingView.h
//  FMStockChart
//
//  Created by dangfm on 15/8/21.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMHeader.h"

#define fmFMStockLoadingViewTag 999999
#define fmFMStockLoadingViewWidth 150
#define fmFMStockLoadingViewHeight 44
#define fmFMStockLoadingViewDefaultTitle @"数据加载中"
#define fmFMStockLoadingViewTimeoutTitle @"暂时无法加载数据"
#define fmFMStockLoadingViewBorderColor kFMColor(0xEEEEEE)
#define fmFMStockLoadingViewFontColor kFMColor(0x999999)
#define fmFMStockLoadingViewFontSize 12
#define fmFMStockLoadingViewBorderWidth 1.0f
#define fmFMStockLoadingViewTimeout fmHttpRequestTimeout+10
#define fmFMStockLoadingViewLoadingColor kFMColor(0x0066ff)

@class FMStockLoadingView;
typedef void (^ClickFMStockLoadingViewBlock)();

@interface FMStockLoadingView : UIView

@property (nonatomic,retain) UIActivityIndicatorView *activity;
@property (nonatomic,retain) UILabel *titler;
@property (nonatomic,copy) ClickFMStockLoadingViewBlock clickFMStockLoadingViewBlock;

/**
 *  显示加载视图
 *
 *  @param superView 父视图
 *
 *  @return 加载视图
 */
+(FMStockLoadingView*)showWithSuperView:(UIView*)superView;
/**
 *  超时显示
 *
 *  @param superView 父视图
 */
+(void)timeoutWithSuperView:(UIView*)superView;
/**
 *  超时后处理
 *
 *  @param block 回调
 */

/**
 *  移除视图
 *
 *  @param superView 父视图
 */
+(void)removeFromSuperView:(UIView*)superView;


-(void)timeoutRunBlock:(void(^)())block;
/**
 *  超时加载视图
 *
 *  @param superView 父视图
 *  @param block     超时执行回调
 */
+(void)timeoutWithSuperView:(UIView*)superView block:(ClickFMStockLoadingViewBlock)block;
@end
