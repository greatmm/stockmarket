//
//  UILabel+stocking.m
//  FMMarket
//
//  Created by dangfm on 15/8/8.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "UILabel+stocking.h"


@implementation UILabel (stocking)
+(UILabel*)createWithTitle:(NSString*)title Frame:(CGRect)frame{
    //CGSize fontSize = [title sizeWithFont:kDefaultFont constrainedToSize:frame.size];
    UILabel *l = [[UILabel alloc] initWithFrame:frame];
    l.font = kDefaultFont;
    l.backgroundColor = [UIColor clearColor];
    l.text = title;
    l.numberOfLines = 0;
    return l;
}
@end
