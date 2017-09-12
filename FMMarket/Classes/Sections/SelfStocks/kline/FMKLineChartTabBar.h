//
//  FMKLineChartTabBar.h
//  FMMarket
//
//  Created by dangfm on 15/8/18.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMStockChart.h"

//#define kFMKLineChartTabBarTitles @[@"分时",@"5日",@"日K",@"周k",@"月k",@"1分",@"5分",@"15分",@"30分",@"60分"]
#define kFMKLineChartTabBarTitles @[@"分时",@"5日",@"日K",@"周k",@"月k"]
#define kFMKLineChartTabBarHeight 35
#define kFMKLineChartTabBarLineHeight 2

@protocol FMKLineChartTabBarDelegate <NSObject>
@optional
/**
 *  按钮点击代理
 *
 *  @param stockChartType 图表类型
 */
-(void)FMKLineChartTabBarClickButton:(FMStockChartType)stockChartType;

@end

typedef void (^clickChartTabBarButtonHandle)(NSInteger tag);

@interface FMKLineChartTabBar : UIView

@property (nonatomic,retain) UIView *line;
@property (nonatomic,retain) NSArray *titles;
@property (nonatomic,retain) UIScrollView *box;
@property (nonatomic,weak) id <FMKLineChartTabBarDelegate> delegate;
@property (nonatomic,copy) clickChartTabBarButtonHandle clickChartTabBarButtonHandle;
@property (nonatomic,assign) BOOL isMove;
@property (nonatomic,assign) int showCounts;    // 默认竖屏显示多少个 默认是6个
@property (nonatomic,retain) UIView *moreViews;
@property (nonatomic,retain) UIView *superView;
@property (nonatomic,assign) int lastSelectIndex;

-(instancetype)initWithFrame:(CGRect)frame Titles:(NSArray*)titles;
-(instancetype)initWithFrame:(CGRect)frame Titles:(NSArray*)titles superView:(UIView*)superView;
-(instancetype)initWithFrame:(CGRect)frame Titles:(NSArray*)titles IsMove:(BOOL)isMove;
-(instancetype)initWithFrame:(CGRect)frame Titles:(NSArray*)titles IsMove:(BOOL)isMove showCounts:(int)showCounts;
-(void)updateHighlightsTitleWithIndex:(NSInteger)index;
-(void)reloadViews;
-(void)free;
@end


