//
//  ThreeButton.h
//  FMMarket
//
//  Created by dangfm on 15/11/18.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kTopThreeFont_Title 16
#define kTopThreeFont_price 12

@interface ThreeButton : UIButton
@property (nonatomic,retain) UILabel *titler;
@property (nonatomic,retain) UILabel *price;
@property (nonatomic,retain) UILabel *change;
@property (nonatomic,retain) UILabel *changeRate;
@property (nonatomic,retain) NSString *code;
@property (nonatomic,retain) NSString *type;
@property (nonatomic,retain) NSString *tradeType;
@property (nonatomic,retain) UILabel *trade;
@property (nonatomic,retain) NSString *tradeRate;

-(void)clearText;
-(void)updateTextColor;
-(void)changeBgColorWithOldPrice:(NSString*)price;
@end
