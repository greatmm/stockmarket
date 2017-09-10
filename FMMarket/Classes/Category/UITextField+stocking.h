//
//  UITextField+stocking.h
//  FMMarket
//
//  Created by dangfm on 15/8/13.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kUITextFieldPlaceholderTextColor UIColorFromRGB(0xCCCCCC)

@interface UITextField (stocking)
+(UITextField*)createWithFrame:(CGRect)frame PlaceHolder:(NSString*)placeholder;
/**
 *  自定义文本框
 *
 *  @param frame       位置
 *  @param placeholder 提示文字
 *
 *  @return 文本框
 */
+(UITextField*)createInputTextWithFrame:(CGRect)frame PlaceHolder:(NSString*)placeholder;
@end
