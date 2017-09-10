//
//  UIButton+stocking.h
//  FMMarket
//
//  Created by dangfm on 15/8/9.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kUIButtonDefaultHeight 44

@interface UIButton (stocking)
+(UIButton*)createWithTitle:(NSString*)title Frame:(CGRect)frame;
+(UIButton*)createButtonWithTitle:(NSString*)title Frame:(CGRect)frame;
@end
