//
//  FMLoginViewController.h
//  FMMarket
//
//  Created by dangfm on 15/9/3.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMBaseViewController.h"

#define kFMLoginViewSectionHeight 50

typedef void (^FinishedLoginBlock)(void);

@interface FMLoginViewController : FMBaseViewController
@property (nonatomic,copy) FinishedLoginBlock finishedLoginBlock;
-(instancetype)initWithBackType:(int)backType finishedLoginBlock:(FinishedLoginBlock)block;
@end
