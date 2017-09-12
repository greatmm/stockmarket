//
//  UIImage+stocking.m
//  FMMarket
//
//  Created by dangfm on 15/8/12.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "UIImage+stocking.h"

@implementation UIImage (stocking)

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


+ (UIImage *) imageWithTintColor:(UIColor *)tintColor blendMode:(CGBlendMode)blendMode WithImageObject:(UIImage*)image
{
    //We want to keep alpha, set opaque to NO; Use 0.0f for scale to use the scale factor of the device’s main screen.
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    UIRectFill(bounds);
    
    //Draw the tinted image in context
    [image drawInRect:bounds blendMode:blendMode alpha:1.0f];
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}

+ (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize {
//    UIGraphicsBeginImageContextWithOptions(targetSize, NO, [UIScreen mainScreen].scale);
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = [UIScreen mainScreen].scale;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}


+ (UIImage *)noPhoto:(UIColor *)color titleColor:(UIColor *)titleColor size:(CGSize)size
{
    // 取缓存
    NSString *key = [NSString stringWithFormat:@"UserDefault_Placeholder_W%f_H%f",size.width,size.height];
    NSString *imgFilePath = [fn realPathWithFileName:key Path:@"nophoto"];
    NSData *imgData = [NSData dataWithContentsOfFile:imgFilePath];
    UIImage *image = [UIImage imageWithData:imgData scale:[UIScreen mainScreen].scale];
    if (!image) {
        CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
        UIGraphicsBeginImageContext(rect.size);
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, FMNoPhotoBgColor.CGColor);
        CGContextFillRect(context, rect);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        CGContextSetStrokeColorSpace(context, colorSpace);
    
        NSString *imgName = [NSString stringWithFormat:@"nophoto_logo"];
        UIImage *logo = ThemeImage(imgName);
        // LOGO为画布的1/2
        float w = size.height/3*2;
        float h = w;
        logo = [self imageByScalingAndCroppingForSourceImage:logo targetSize:CGSizeMake(w, h)];
        CGContextDrawImage(context,CGRectMake((size.width-logo.size.width)/2,
                                              (size.height-logo.size.height)/2,
                                              logo.size.width,
                                              logo.size.height),logo.CGImage);
        [logo drawAtPoint:CGPointMake((size.width-logo.size.width)/2,
                                      (size.height-logo.size.height)/2)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        // 保存图片
        imgData = UIImagePNGRepresentation(image);
        [imgData writeToFile:imgFilePath atomically:YES];
        
    }
    imgData = nil;
    return image;
}
@end
