//
//  FMStockCapital.m
//  FMMarket
//
//  Created by dangfm on 15/10/7.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMStockCapital.h"
#import "UILabel+stocking.h"
#import "FMTableView.h"
#import "FMStockCapitalCell.h"
#import <FMStockChart/FMStockChart.h>

@implementation FMStockCapitalModel

-(instancetype)initWithDic:(NSDictionary *)dic{
    if (self==[super init]) {
        [fn reflectDataFromOtherObject:dic WithTarget:self];
    }
    return self;
}
@end
@interface FMStockCapital()
<UITableViewDataSource,UITableViewDelegate>
{
    FMTableView *_tableView;
    NSMutableArray *_datas;
}

@end

@implementation FMStockCapital

-(instancetype)initWithFrame:(CGRect)frame{
    if (self==[super initWithFrame:frame]) {
        [self createViews];
        [self getHttpStockCapital];
    }
    return self;
}


#pragma mark -
#pragma mark UI Create

-(void)createViews{
    self.height = kFMStockCapitalHeight;
    _datas = [NSMutableArray new];
    if (!_tableView) {
        CGRect frame = self.bounds;
        _tableView = [[FMTableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        //_tableView.backgroundColor = FMBgGreyColor;
        _tableView.scrollEnabled = NO;
        [self addSubview:_tableView];
     
    }
    
}


#pragma mark -
#pragma mark UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kTableViewCellDefaultHeight;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _datas.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIndentifier = [NSString stringWithFormat:@"cell_%d_%d",(int)indexPath.section,(int)indexPath.row];
    
    FMStockCapitalCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (!cell) {
        cell = [[FMStockCapitalCell alloc] initWithStyle:UITableViewCellStyleDefault
                                               reuseIdentifier:cellIndentifier];
        
        
    }
    if (indexPath.row < _datas.count) {
        [cell setContent:[_datas objectAtIndex:indexPath.row]];
    }
    
    
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

#pragma mark -
#pragma mark HTTP Request
-(void)getHttpStockCapital{
    [http getStockCapitalWithStart:^{
    
    } failure:^{
        
    } success:^(NSDictionary *dic){
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSArray *list = [dic objectForKey:@"data"];
            if (list.count>0) {
                [_datas removeAllObjects];
                for (NSDictionary* item in list) {
                    FMStockCapitalModel *m = [[FMStockCapitalModel alloc] initWithDic:item];
                    if (m) {
                        [_datas addObject:m];
                    }
                    m = nil;
                }
                _height = _datas.count * kTableViewCellDefaultHeight;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_tableView reloadData];
                    if (self.whenFinishedLoadDatasBlock) {
                        self.whenFinishedLoadDatasBlock();
                    }
                });
            }
            
        });
        
    }];
}


@end
