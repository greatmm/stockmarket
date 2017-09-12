//
//  FMUpDownListViewController.h
//  FMMarket
//
//  Created by dangfm on 15/11/20.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMBaseViewController.h"

@interface FMUpDownListViewController : FMBaseViewController
@property (nonatomic,retain) NSString* typeCode;
@property (nonatomic,retain) NSString* typeName;
-(instancetype)initWithTypeCode:(NSString*)typeCode typeName:(NSString*)typeName;
@end
