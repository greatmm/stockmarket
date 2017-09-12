//
//  UIImage+stocking.h
//  FMMarket
//
//  Created by dangfm on 15/8/12.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (stocking)

/**
*  画纯色图片，指定颜色生成图片
*
*  @param color 图片颜色
*  @param size  图片大小
*
*  @return 图片
*/
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;


/**
 *  图片前景色变换
 *
 *  @param tintColor 需要变换的颜色
 *  @param blendMode 填充模式 一般用 kCGBlendModeDestinationIn
 *  @param image     被填充的图片
 *
 *  @return 填充后的图片
 */
+(UIImage *)imageWithTintColor:(UIColor *)tintColor
                     blendMode:(CGBlendMode)blendMode
               WithImageObject:(UIImage*)image;

/**
 *  裁减图片
 *
 *  @param sourceImage 原图
 *  @param targetSize  目标大小
 *
 *  @return 图片
 */
+ (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize;

/**
 *  生成无图
 *
 *  @param color      颜色
 *  @param titleColor 标题颜色
 *  @param size       大小
 *
 *  @return 无图
 */
+ (UIImage *)noPhoto:(UIColor *)color titleColor:(UIColor*)titleColor size:(CGSize)size;
@end
