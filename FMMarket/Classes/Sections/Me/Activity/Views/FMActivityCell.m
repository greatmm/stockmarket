//
//  FMActivityCell.m
//  FMMarket
//
//  Created by dangfm on 16/5/22.
//  Copyright © 2016年 dangfm. All rights reserved.
//

#import "FMActivityCell.h"
#import <UIImageView+WebCache.h>

@implementation FMActivityModel

-(instancetype)initWithDic:(NSDictionary *)dic{
    if (self==[super init]) {
        [fn reflectDataFromOtherObject:dic WithTarget:self];
    }
    return self;
}

@end
@implementation FMActivityCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initView];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    if (self.frame.origin.x!=10) {
        self.frame = CGRectMake(10,self.frame.origin.y+10,_box.frame.size.width,_box.frame.size.height);
    }
}

-(void)initView{
    
    self.backgroundColor = [UIColor clearColor];
    CGFloat h = 180;
    _box = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth-20, kNewActivityTableViewCellHeight-20)];
    _box.backgroundColor = [UIColor whiteColor];
    _box.layer.cornerRadius = 5;
    _box.clipsToBounds = YES;
    // 选中背景
    UIView *_selectbg = [[UIView alloc]initWithFrame:_box.frame];
    _selectbg.backgroundColor = FMBgGreyColor;
    _selectbg.layer.cornerRadius = 10;
    _selectbg.clipsToBounds = YES;
    self.selectedBackgroundView = _selectbg;
    _selectbg = nil;
    // 图片
    _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, _box.frame.size.width-20, h)];
    _imgView.layer.cornerRadius = 5;
    _imgView.layer.masksToBounds = YES;
    _imgView.backgroundColor = FMBgGreyColor;
    [_box addSubview:_imgView];
    // 标题
    _title = [[UILabel alloc] initWithFrame:CGRectMake(10, h+10, _box.frame.size.width, 25)];
    _title.font = kFont(14);
    _title.textColor = FMZeroColor;
    [_box addSubview:_title];
    // 时间
    _time = [[UILabel alloc] initWithFrame:CGRectMake(10, h+40, 220, 20)];
    _time.font = kFont(12);
    _time.textColor = FMGreyColor;
    [_box addSubview:_time];
    // 线
    //[fn drawLineWithSuperView:_box Color:FMBottomLineColor Frame:CGRectMake(5, h+40, _box.frame.size.width-10, 0.5)];
    // 描述
    _info = [[UILabel alloc] initWithFrame:CGRectMake(10, h+40, _box.frame.size.width-20, 20)];
    _info.font = _time.font;
    _info.textColor = _time.textColor;
    _info.textAlignment = NSTextAlignmentRight;
    [_box addSubview:_info];
    [self.contentView addSubview:_box];

}

-(void)setContentWithModel:(FMActivityModel *)model{
    NSString *src = model.pic;
    NSString *title = model.title;
    NSString *summary = @"查看详情";
    NSString *add_time = model.createTime;
//    if (add_time) {
//        add_time = [NSString stringFromDate:[NSDate dateWithTimeIntervalSince1970:[add_time floatValue]] format:@"yyyy-MM-dd HH:mm:ss"];
//    }
    src = [src stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [_imgView sd_setImageWithURL:[NSURL URLWithString:src] placeholderImage:nil];
    
    _title.text = title;
    _time.text = add_time;
    _info.text = summary;
}

@end
