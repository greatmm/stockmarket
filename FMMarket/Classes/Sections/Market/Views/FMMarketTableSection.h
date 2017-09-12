//
//  FMMarketTableSection.h
//  FMMarket
//
//  Created by dangfm on 15/11/19.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kFMMarketTableSectionHeight 35
#define kFMMarketTableSectionPadding 18

@interface FMMarketTableSection : UIView
@property (nonatomic,retain) UILabel *titleLb;
@property (nonatomic,retain) NSString *typeCode;
@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) UIButton *moreBt;
@property (nonatomic,retain) UIButton *leftIcon;
@property (nonatomic,assign) BOOL isSpread;
/**
 *  初始化
 *
 *  @param frame    位置
 *  @param title    标题
 *  @param typeCode 分组类型
 *
 *  @return self
 */
-(instancetype)initWithFrame:(CGRect)frame title:(NSString*)title typeCode:(NSString*)typeCode;
@end
