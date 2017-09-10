//
//  FMEditStocksTableViewCell.h
//  FMMarket
//
//  Created by dangfm on 15/10/2.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMTableViewCell.h"

@class FMEditStocksTableViewCell;
typedef void (^clickMoveUpButtonBlock)(FMEditStocksTableViewCell* myself);
typedef void (^clickMySelfToSelectBlock)(FMEditStocksTableViewCell* myself);
typedef void (^clickMySelfToRemindBlock)(FMEditStocksTableViewCell* myself);

@interface FMEditStocksTableViewCell : FMTableViewCell

@property (nonatomic,retain) UIButton *moveBt;
@property (nonatomic,retain) UIButton *selectedBt;
@property (nonatomic,retain) UIButton *remindBt;
@property (nonatomic,retain) FMSelfStocksModel* model;
@property (nonatomic,copy) clickMoveUpButtonBlock clickMoveUpButtonBlock;
@property (nonatomic,copy) clickMySelfToSelectBlock clickMySelfToSelectBlock;
@property (nonatomic,copy) clickMySelfToRemindBlock clickMySelfToRemindBlock;
-(void)setContent:(FMSelfStocksModel*)model;
-(void)updateSelectView:(NSArray*)selectDatas;

@end
