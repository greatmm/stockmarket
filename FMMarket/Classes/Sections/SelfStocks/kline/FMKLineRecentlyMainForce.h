//
//  FMKLineRecentlyMainForce.h
//  FMMarket
//
//  Created by dangfm on 15/9/1.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kFMKLineRecentlyMainForce_Height 220
#define kFMKLineRecentlyMainForce_ChartViewsHeight 100
#define kFMKLineRecentlyMainForce_Padding 15

@interface FMKLineRecentlyMainForce : UIView
@property (nonatomic,retain) NSString *titler;
-(instancetype)initWithFrame:(CGRect)frame datas:(NSArray*)datas;
-(void)startWithDatas:(NSArray*)datas title:(NSString*)title;
@end

@interface FMRecentlyModel : NSObject

@property (nonatomic,retain) NSString *title;
@property (nonatomic,assign) double inflow;
@property (nonatomic,assign) double flowOut;

-(instancetype)initWithDic:(NSDictionary*)dic;
@end