//
//  FMActivityCell.h
//  FMMarket
//
//  Created by dangfm on 16/5/22.
//  Copyright © 2016年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kNewActivityTableViewCellHeight 270

@class FMActivityModel;

@interface FMActivityCell : UITableViewCell

@property(nonatomic,retain) UIImageView *imgView;
@property(nonatomic,retain) UILabel *title;
@property(nonatomic,retain) UILabel *time;
@property(nonatomic,retain) UILabel *info;
@property(nonatomic,retain) UIView *box;

-(void)setContentWithModel:(FMActivityModel*)model;

@end


@interface FMActivityModel : NSObject

@property(nonatomic,retain) NSString *pic;
@property(nonatomic,retain) NSString *title;
@property(nonatomic,retain) NSString *createTime;
@property(nonatomic,retain) NSString *intro;
@property(nonatomic,retain) NSString *url;
-(instancetype)initWithDic:(NSDictionary*)dic;
@end