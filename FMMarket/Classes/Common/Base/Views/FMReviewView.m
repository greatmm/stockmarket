//
//  FMReviewView.m
//  FMMarket
//
//  Created by dangfm on 15/12/17.
//  Copyright © 2015年 dangfm. All rights reserved.
//

#import "FMReviewView.h"
#import "FMReviewCell.h"

@interface FMReviewView()
<UITableViewDataSource,UITableViewDelegate,UITextViewDelegate>
{
}

@end

@implementation FMReviewView

#pragma mark -
#pragma mark Init
-(instancetype)initWithFrame:(CGRect)frame{
    if (self==[super initWithFrame:frame]) {
        [self createViews];
    }
    return self;
}

#pragma mark -
#pragma mark UI Create
// 初始化视图
-(void)createViews{
    self.backgroundColor = [UIColor whiteColor];
    // 默认高度
    _height = kFMReviewViewDefaultHeight;
    [self createTableView];
}


//  Create TableView
-(void)createTableView{
    if (!_tableView) {
        _tableView = [[FMTableView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, _height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];;
        _tableView.scrollEnabled = NO;
        [self addSubview:_tableView];
    }
    // 没有数据的时候显示
    if (!_noDataView) {
        _noDataView = [UIButton createButtonWithTitle:@"快来抢沙发吧～" Frame:CGRectMake(0,0,UIScreenWidth,self.frame.size.height)];
        [self addSubview:_noDataView];
        _noDataView.hidden = YES;
    }
}

// 更新
-(void)reloadData{
    // 更新tableView高度
    if (_datas.count>0) {
        float h = 0;
        for (FMReviewModel *item in _datas) {
            h += [FMReviewCell heightWithModel:item];
        }
        _height = h;
        _tableView.backgroundColor = [UIColor whiteColor];;
        _noDataView.hidden = YES;
    }else{
        _height = kFMReviewViewDefaultHeight;
        _tableView.backgroundColor = [UIColor whiteColor];
        _noDataView.hidden = NO;
    }
//    float h = _height-kNavigationHeight;
//    if (h<kFMReviewViewDefaultHeight) {
//        h = kFMReviewViewDefaultHeight;
//    }
    CGRect frame = _tableView.frame;
    frame.origin.y = 0;
    frame.size.height = _height;
    _tableView.frame = frame;
    frame.size.height = _height;
    self.frame = frame;
    [_tableView reloadData];
    // 更新完成回调
    if (self.reloadFinishedBlock) {
        self.reloadFinishedBlock(_height);
    }
}


#pragma mark -
#pragma mark UI Action

#pragma mark -
#pragma mark UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    FMReviewModel *m = _datas[indexPath.row];
    float h = m.height;
    return h;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_datas count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIndentifier = @"cell";
    FMReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[FMReviewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                        reuseIdentifier:cellIndentifier];
        [cell.askButton addTarget:self action:@selector(clickAskButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    cell.askButton.tag = indexPath.row;
    [cell setContents:_datas[indexPath.row]];
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    // 点击cell回调
//    if (self.clickFMReviewCellBlock){
//        self.clickFMReviewCellBlock((int)indexPath.row);
//    }
}

// 点击回复按钮
-(void)clickAskButtonAction:(UIButton*)sender{
    // 点击按钮回调
    if (self.clickFMReviewCellBlock){
        self.clickFMReviewCellBlock((int)sender.tag);
    }
}

@end
