//
//  FMFiveStallsView.h
//  FMStockChart
//
//  Created by dangfm on 15/10/29.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMBaseView.h"
#import "FMStockFiveStallsModel.h"
#define kFMFiveStallsViewDefaultWidth 100
typedef void (^updateFMStockFiveStallsViewFinished)(FMStockFiveStallsModel*m);
@interface FMFiveStallsView : FMBaseView
@property (nonatomic,retain) UIFont *font;
@property (nonatomic,retain) UIFont *textFont;
@property (nonatomic,retain) NSString *stockCode;
@property (nonatomic,retain) UIButton *tabBar;
@property (nonatomic,retain) FMStockFiveStallsModel *stallModel;
@property (nonatomic,copy) updateFMStockFiveStallsViewFinished updateFMStockFiveStallsViewFinished;
-(instancetype)initWithFrame:(CGRect)frame StockCode:(NSString*)code;
-(void)getHttpStockNewData;
-(void)createListWithModel:(FMStockFiveStallsModel*)model;
@end
