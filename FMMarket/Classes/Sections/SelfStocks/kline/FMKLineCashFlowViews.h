//
//  FMKLineCashFlowViews.h
//  FMMarket
//
//  Created by dangfm on 15/9/1.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kFMKLineCashFlow_Height 260
#define kFMKLineCashFlow_CryRadius 70
#define kFMKLineCashFlow_TextFont kFont(10)
#define kFMKLineCashFlow_TextColor FMBlackColor


@interface FMKLineCashFlowViews : UIView

-(instancetype)initWithFrame:(CGRect)frame withDatas:(NSArray*)datas;
-(void)startWithDatas:(NSArray*)datas;
@end

@interface FMCashFlowModel : NSObject

@property (nonatomic,retain) NSString *title;
@property (nonatomic,assign) CGFloat percent;
@property (nonatomic,retain) NSString *info;
@property (nonatomic,retain) UIColor *color;

@end