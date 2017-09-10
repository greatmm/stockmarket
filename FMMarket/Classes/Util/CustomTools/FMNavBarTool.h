//
//  FMNavBarTool.h
//  golden_ipad
//
//  Created by dangfm on 16/8/24.
//  Copyright © 2016年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kFMNavBarTool_Height 35
#define kFMNavBarTool_Font kFont(14)                            // 默认字体
#define kFMNavBarTool_FontBold kFontBold(14)                    // 加粗字体
#define kFMNavBarTool_TextColor FMBlackColor                    // 字体默认颜色
#define kFMNavBarTool_BgColor FMBgGreyColor                     // 默认背景颜色
#define kFMNavBarTool_TriangleWidth 16                          // 三角形宽
#define kFMNavBarTool_TriangleHeight 16                         // 三角形高
#define kFMNavBarTool_LineHeight 3                              // 底部移动线条高度
#define kFMNavBarTool_MoveTime .2f                              // 移动时间
#define kFMNavBarTool_MarginLeft 40                             // 按钮间距


// 底部点击移动的线条的样式
typedef enum {
    FMNavBarToolBottomLineStyle_None,               // 无
    FMNavBarToolBottomLineStyle_Line,               // 直线
    FMNavBarToolBottomLineStyle_Triangle            // 三角形
} FMNavBarToolBottomLineStyle;

/**
 *  点击回调
 *
 *  @param index 按钮索引
 */
typedef void (^clickNavBarToolAction)(NSInteger index);

@interface FMNavBarTool : UIView
@property (nonatomic,retain) UIFont *font;
@property (nonatomic,retain) UIColor *textColor;
@property (nonatomic,retain) UIImageView *line;          // 底部移动线 或者是三角形
@property (nonatomic,assign) BOOL isScrolling;           // 是否自动滚动 超出自动滚动
@property (nonatomic,assign) NSInteger selectTag;        // 当前选择按钮的下标
@property (nonatomic,assign) FMNavBarToolBottomLineStyle bottomLineStyle;   // 底部移动线的样式
@property (nonatomic,copy) clickNavBarToolAction clickNavBarToolAction;     // 点击按钮回调，返回按钮下标

/**
 *  初始化工具栏
 *
 *  @param frame  位置大小
 *  @param titles 标题数组
 *
 *  @return 工具栏视图
 */
-(instancetype)initWithFrame:(CGRect)frame titles:(NSArray*)titles;

/**
 *  初始化工具栏
 *
 *  @param frame  位置大小
 *  @param titles 标题数组
 *  @param bottomLineStyle 底部线条样式
 *
 *  @return 工具栏视图
 */
-(instancetype)initWithFrame:(CGRect)frame titles:(NSArray*)titles bottomLineStyle:(FMNavBarToolBottomLineStyle)bottomLineStyle;

/**
 *  初始化工具栏
 *
 *  @param frame           位置大小
 *  @param titles          标题数组
 *  @param bottomLineStyle 底部线条样式
 *  @param isScrolling     是否滚动
 *
 *  @return 工具栏
 */
-(instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles bottomLineStyle:(FMNavBarToolBottomLineStyle)bottomLineStyle isScrolling:(BOOL)isScrolling;
/**
 *  移动线条到某个按钮下
 *
 *  @param tag 按钮下标
 */
-(void)moveBottomLineToSelectButtonWithTag:(NSInteger)tag;

@end
