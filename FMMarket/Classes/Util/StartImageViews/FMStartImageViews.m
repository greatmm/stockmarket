//
//  FMStartImageViews.m
//  FMMarket
//
//  Created by dangfm on 16/9/7.
//  Copyright © 2016年 dangfm. All rights reserved.
//

#import "FMStartImageViews.h"

@interface FMStartImageViews()<UIScrollViewDelegate>

@property (nonatomic,retain) NSArray *images;
@property (nonatomic,retain) UIPageControl *page;
@property (nonatomic,assign) float maxScrollX;

@end

@implementation FMStartImageViews

+ (instancetype)sharedManager
{
    static FMStartImageViews *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[FMStartImageViews alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if(self) {
        
        [self createViews];
    }
    return self;
}

+(void)show{
    if ([FMUserDefault isShowUserGuideLoad]) {
        [self sharedManager];
    }
}

-(void)createViews{
    _images = @[@"_1",@"_2",@"_3",@"_4",@"_5"];
    float width = UIScreenWidth*[UIScreen mainScreen].scale;
    float height = UIScreenHeight*[UIScreen mainScreen].scale;
    // 根据分辨率识别文件名
    float x = 0;
    float y = 0;
    float w = UIScreenWidth;
    float h = UIScreenHeight;
    UIView *lastV = nil;
    for (int i=0; i<_images.count; i++) {
        NSString *filename = [NSString stringWithFormat:@"start/%.f_%.f%@",width,height,_images[i]];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x,y,w, h)];
        UIImageView *iv = [[UIImageView alloc] initWithFrame:view.bounds];
        UIImage *img = ThemeImage(filename);
        iv.image = img;
        iv.userInteractionEnabled = NO;
        [view addSubview:iv];
        [self addSubview:view];
        lastV = view;
        x += w;
        img = nil;
        iv = nil;
        filename = nil;
        view = nil;
    }
    self.contentSize = CGSizeMake(_images.count*w, h);
    self.pagingEnabled = YES;
    self.delegate = self;
    self.frame = CGRectMake(0, 0, UIScreenWidth, UIScreenHeight);
    self.backgroundColor = [UIColor clearColor];
    self.showsHorizontalScrollIndicator = NO;
    if (self.superview!=[FMAppDelegate shareApp].window) {
        [[FMAppDelegate shareApp].window addSubview:self];
    }
    
    self.page = [[UIPageControl alloc] initWithFrame:CGRectMake(0, UIScreenHeight-kNavigationHeight, UIScreenWidth, kNavigationHeight)];
    self.page.currentPage = 1;
    self.page.numberOfPages = _images.count;
    [self addSubview:_page];
    
    UIButton *bt = [[UIButton alloc] initWithFrame:CGRectMake(75, UIScreenHeight-4*kNavigationHeight-20, UIScreenWidth-150, kNavigationHeight)];
    bt.backgroundColor = FMRedColor;
    [bt setTitle:@"马上进入" forState:UIControlStateNormal];
    bt.titleLabel.font = kFontBold(22);
    [lastV addSubview:bt];
    bt.layer.cornerRadius = 5;
    bt.layer.masksToBounds = YES;
    [bt addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
}

-(void)hide{
    WEAKSELF
    [UIView animateWithDuration:0.5 animations:^{
        
        __weakSelf.frame = CGRectMake(-UIScreenWidth, 0, UIScreenWidth, UIScreenHeight);
        
    } completion:^(BOOL finished){
        [__weakSelf removeFromSuperview];
    }];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    int x = (int)scrollView.contentOffset.x;
    int w = (int)scrollView.frame.size.width;
    int p = x / w;
    
    self.page.currentPage = p;
    
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    _maxScrollX = scrollView.contentOffset.x;
    if (_maxScrollX>((_images.count-1)*UIScreenWidth+80)) {
        [self hide];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSLog(@"%f",scrollView.contentOffset.x);
    float x = scrollView.contentOffset.x;
    if (x<=0) {
        x = 0;
    }
    scrollView.contentOffset = CGPointMake(x, 0);
    
    CGRect frame = self.page.frame;
    frame.origin.x = x;
    self.page.frame = frame;
}

@end
