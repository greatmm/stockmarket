//
//  FMReviewInput.h
//  FMMarket
//
//  Created by dangfm on 15/12/18.
//  Copyright © 2015年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kFMReviewInputDefaultHeight 44  // 默认高度
#define kFMReviewInputMaxHeight 140     // 编辑模式高度

// 发送完成回调
typedef void (^sendFinishBlock)(BOOL success,NSDictionary*result);
// 发送关闭回调
typedef void (^sendCloseBlock)(void);

@interface FMReviewInput : UIView

@property (nonatomic,retain) NSString *objectId;    // 评论对象ID
@property (nonatomic,retain) NSString *reviewId;    // 回复ID
@property (nonatomic,retain) NSString *userName;    // 回复用户名
@property (nonatomic,retain) UITextView *input;     // 文本框
@property (nonatomic,retain) UILabel *placeHolder;  // 自定义默认显示文本
@property (nonatomic,retain) UIView *titleBox;      // 头部标题区域
@property (nonatomic,retain) UIView *mainView;      // 内容区域
@property (nonatomic,retain) UIView *maskView;      // 蒙板
@property (nonatomic,retain) UIButton *sendBt;      // 发送按钮
@property (nonatomic,retain) UIButton *mindBt;      // 中间按钮
@property (nonatomic,copy) sendFinishBlock sendFinishBlock;
@property (nonatomic,copy) sendCloseBlock sendCloseBlock;

/**
 *  初始化
 *
 *  @param frame    位置大小
 *  @param cid      藏品ID
 *  @param reviewId 回复ID
 *  @param name     回复用户名
 *
 *  @return 回复视图
 */
-(instancetype)initWithFrame:(CGRect)frame objectId:(NSString*)objectId reviewId:(NSString*)reviewId userName:(NSString*)name;

/**
 *  默认状态
 */
-(void)defaultStatus;

/**
 *  编辑状态
 *
 *  @param h 键盘高度
 */
-(void)showEditing:(float)h;

@end
