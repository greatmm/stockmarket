//
//  FMEditStocksViewController.h
//  FMMarket
//
//  Created by dangfm on 15/10/2.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMBaseViewController.h"

@interface FMEditStocksViewController : FMBaseViewController

@property (nonatomic,retain) NSMutableArray *datas;

-(instancetype)initWithDatas:(NSMutableArray*)datas;

@end
