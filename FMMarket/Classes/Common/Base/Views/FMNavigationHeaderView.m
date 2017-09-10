//
//  FMNavigationHeaderView.m
//  FMMarket
//
//  Created by dangfm on 15/8/13.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMNavigationHeaderView.h"

@interface FMNavigationHeaderView(){
    
}
@property(nonatomic,assign) int w;
@property(nonatomic,assign) int h;
@property(nonatomic,retain) NSString *titlestring;
@property(nonatomic,assign) BOOL isback;

@end

@implementation FMNavigationHeaderView

-(void)dealloc{
    _titler = nil;
    _titlestring = nil;
    _backButton = nil;
    _bottomline = nil;
    NSLog(@"FMNavigationHeaderView dealloc");
}

#pragma mark - 
#pragma mark UI Create

-(instancetype)initWithFrame:(CGRect)frame title:(NSString*)title isBack:(BOOL)isback{
    if(self = [super initWithFrame:frame]){
        _w = frame.size.width;
        _h = frame.size.height;
        _titlestring = title;
        _isback = isback;
        [self initViews];
    }
    return self;
}

-(void)initViews{
    if (!_titler) {
        // 标题
        _titler = [[UILabel alloc] init];
        _titler.text = _titlestring;
        _titler.font = [UIFont boldSystemFontOfSize:16];
        _titler.backgroundColor = [UIColor clearColor];
        [_titler sizeToFit];
        _titler.textAlignment = NSTextAlignmentCenter;
//        _titler.adjustsFontSizeToFitWidth = YES;
        float w = UIScreenWidth - 150;
        _titler.frame = CGRectMake((_w-w)/2, (_h-_titler.frame.size.height)/2, w, _titler.frame.size.height);
        [self addSubview:_titler];
    }
    if (!_backButton && _isback) {
        //标题栏的返回键
        UIImage *back_imge=ThemeImage(@"global/return");
        back_imge = [UIImage imageWithTintColor:FMNavTitleColor blendMode:kCGBlendModeDestinationIn WithImageObject:back_imge];
        _backButton=[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, _h)];
        _backButton.backgroundColor=[UIColor clearColor];
        [_backButton setImage:back_imge forState:UIControlStateNormal];
        [self addSubview:_backButton];
        [_backButton setTag:100];
        back_imge = nil;
    }
    
    if (!_bottomline) {
        _bottomline = [[UIView alloc] initWithFrame:CGRectMake(0, _h-0.5, _w, 0.5)];
        [self addSubview:_bottomline];
    }
    
    [self changeViewBackgroundColor:FMNavColor titleColor:FMNavTitleColor];
}

#pragma mark 背景变化
#pragma mark 背景变化
-(void)changeViewBackgroundColor:(UIColor*)color titleColor:(UIColor *)titleColor{
    [self setBackgroundColor:color];
    _bottomline.backgroundColor = color;
    _titler.textColor = titleColor;
    [self setBackgroundColor:color];
    _bottomline.backgroundColor = color;
}

@end
