//
//  FMPlateUpDownListViewController.h
//  FMMarket
//
//  Created by dangfm on 16/5/10.
//  Copyright © 2016年 dangfm. All rights reserved.
//

#import "FMBaseViewController.h"

@interface FMPlateUpDownListViewController : FMBaseViewController
@property (nonatomic,retain) NSString* typeCode;
@property (nonatomic,retain) NSString* typeName;
-(instancetype)initWithTypeCode:(NSString*)typeCode typeName:(NSString*)typeName;
@end
