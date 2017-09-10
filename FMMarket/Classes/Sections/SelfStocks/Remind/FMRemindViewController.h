//
//  FMRemindViewController.h
//  FMMarket
//
//  Created by dangfm on 15/11/29.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMBaseViewController.h"

@interface FMRemindViewController : FMBaseViewController
@property (nonatomic,retain) NSString *code;
@property (nonatomic,retain) NSString *name;
-(instancetype)initWithCode:(NSString*)code name:(NSString*)name;
@end
