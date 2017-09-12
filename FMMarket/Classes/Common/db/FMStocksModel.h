//
//  FMStocksModel.h
//  FMMarket
//
//  Created by dangfm on 15/8/15.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMStocksModel : NSObject

@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *code;
@property (nonatomic,retain) NSString *type;
@property (nonatomic,retain) NSString *isStop;
@property (nonatomic,retain) NSString *pinyin;
@property (nonatomic,retain) NSString *timestamp;

-(instancetype)initWithDic:(NSDictionary*)dic;

@end
