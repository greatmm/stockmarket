//
//  FMReviewView.h
//  FMMarket
//
//  Created by dangfm on 15/12/17.
//  Copyright © 2015年 dangfm. All rights reserved.
//

/**
 *  行情详情页评论模块
 *  显示评论列表，评论回复等
 */
#import "FMTableView.h"
#import "FMReviewCell.h"
#define kFMReviewViewDefaultHeight 250

// 更新数据完成回调返回总高度
typedef void (^reloadFinishedBlock)(float height);
typedef void (^clickFMReviewCellBlock)(int row);

@interface FMReviewView : UIView
@property (nonatomic,retain) FMTableView *tableView;    // 表格
@property (nonatomic,retain) UIButton *noDataView;      // 无数据显示视图 “快来抢沙发吧”
@property (nonatomic,retain) NSMutableArray *datas;     // 数据
@property (nonatomic,assign) float height;              // 动态高度
@property (nonatomic,copy) reloadFinishedBlock reloadFinishedBlock;
@property (nonatomic,copy) clickFMReviewCellBlock clickFMReviewCellBlock;

// 更新
-(void)reloadData;

@end
