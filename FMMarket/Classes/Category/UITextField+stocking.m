//
//  UITextField+stocking.m
//  FMMarket
//
//  Created by dangfm on 15/8/13.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "UITextField+stocking.h"
#import "UIImage+stocking.h"

@implementation UITextField (stocking)

+(UITextField*)createWithFrame:(CGRect)frame PlaceHolder:(NSString*)placeholder{
    UITextField *t = [[UITextField alloc] initWithFrame:frame];
    t.placeholder = placeholder;
    [t setValue:kUITextFieldPlaceholderTextColor forKeyPath:@"_placeholderLabel.textColor"];
    t.font = kFont(14);
    t.layer.borderColor = UIColorFromRGB(0xCCCCCC).CGColor;
    t.layer.borderWidth = 0.5;
    UIImage *leftIcon = ThemeImage(@"global/search");
    leftIcon = [UIImage imageWithTintColor:kUITextFieldPlaceholderTextColor
                                 blendMode:kCGBlendModeDestinationIn WithImageObject:leftIcon];
    UIButton *leftView = [[UIButton alloc]
                             initWithFrame:CGRectMake(5, 0, leftIcon.size.width+10, leftIcon.size.height)];
    [leftView setImage:leftIcon forState:UIControlStateNormal];
    t.leftView = leftView;
    t.leftViewMode = UITextFieldViewModeAlways;
    t.clearButtonMode = UITextFieldViewModeWhileEditing;
    return t;
}

+(UITextField*)createInputTextWithFrame:(CGRect)frame PlaceHolder:(NSString*)placeholder{
    UITextField *t = [[UITextField alloc] initWithFrame:frame];
    t.placeholder = placeholder;
    [t setValue:kUITextFieldPlaceholderTextColor forKeyPath:@"_placeholderLabel.textColor"];
    [t setValue:kDefaultFont forKeyPath:@"_placeholderLabel.font"];
    t.font = kFont(14);
    t.clearButtonMode = UITextFieldViewModeWhileEditing;
    return t;
}
@end
