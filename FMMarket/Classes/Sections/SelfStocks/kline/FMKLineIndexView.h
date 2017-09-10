//
//  FMKLineIndexView.h
//  FMMarket
//
//  Created by dangfm on 15/9/18.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kFMKLineIndexViewWidth 50

typedef void (^clickKLineHorizontalNavButtonBlock)(NSString* code,int index);

@interface FMKLineIndexView : UIView

-(instancetype)initWithFrame:(CGRect)frame type:(NSString*)type;

@property(nonatomic,copy) clickKLineHorizontalNavButtonBlock clickKLineHorizontalNavButtonBlock;
-(void)highlightsWithIndex:(int)index;
@end
