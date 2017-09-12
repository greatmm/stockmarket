//
//  FMMaskView.h
//  FMMarket
//
//  Created by dangfm on 16/1/13.
//  Copyright © 2016年 dangfm. All rights reserved.
//

#import "FMStockChart.h"

typedef void(^hiddenFinishedRunBlock)(void);

@interface FMMaskView : FMBaseView{
    CGFloat _alpha;
    CGFloat _h;
}

@property (nonatomic,retain) UIView *mainBody;
@property (nonatomic,retain) UIView *sportView;
@property (nonatomic,copy) hiddenFinishedRunBlock hideFinishBlock;
- (id)initWithAlpha:(CGFloat)alpha Height:(int)height;
- (void)show:(void (^)(void))animations;
- (void)hide;
+(void)hide;
@end
