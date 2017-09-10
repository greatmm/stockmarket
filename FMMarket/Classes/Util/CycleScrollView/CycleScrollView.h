//
//  CycleScrollView.h
//  PagedScrollView
//
//  Created by 陈政 on 14-1-23.
//  Copyright (c) 2014年 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CycleScrollView : UIView

@property (nonatomic , readonly) UIScrollView *scrollView;
@property (nonatomic , strong) UIPageControl *pageControl;
@property(nonatomic,retain)NSMutableArray *dataArray;
@property(nonatomic,retain)NSMutableArray *imageViews;
@property (nonatomic , retain) UILabel *flashTitlebackColor;
@property (nonatomic , retain) UILabel *flashTitle;
/**
 *  初始化
 *
 *  @param frame             frame
 *  @param animationDuration 自动滚动的间隔时长。如果<=0，不自动滚动。
 *  @param dataArray         传进来的数据源
 *
 *  @return instance
 */
- (id)initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration;
- (id)initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration andDataArray:(NSMutableArray *)dataArray;
/**
 数据源：获取总的page个数
 **/
@property (nonatomic , copy) NSInteger (^totalPagesCount)(void);
/**
 数据源：获取第pageIndex个位置的contentView
 **/
@property (nonatomic , copy) UIView *(^fetchContentViewAtIndex)(NSInteger pageIndex);
/**
 当点击的时候，执行的block
 **/
@property (nonatomic , copy) void (^TapActionBlock)(NSInteger pageIndex);

-(void)clear;

@end