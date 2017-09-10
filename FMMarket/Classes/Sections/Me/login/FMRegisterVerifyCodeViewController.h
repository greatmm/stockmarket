//
//  FMRegisterVerifyCodeViewController.h
//  FMMarket
//
//  Created by dangfm on 15/9/3.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMBaseViewController.h"

#define kFMRegisterVerifyCodeViewSectionHeight 50

@interface FMRegisterVerifyCodeViewController : FMBaseViewController
@property (nonatomic,retain) NSString *tel;

-(instancetype)initWithTel:(NSString *)tel changePassword:(BOOL)changePassword;

@end
