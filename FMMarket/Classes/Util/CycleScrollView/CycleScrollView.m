//
//  CycleScrollView.m
//  PagedScrollView
//
//  Created by 陈政 on 14-1-23.
//  Copyright (c) 2014年 Apple Inc. All rights reserved.
//

#import "CycleScrollView.h"
#import "NSTimer+Addition.h"

@interface CycleScrollView () <UIScrollViewDelegate>

@property (nonatomic , assign) NSInteger currentPageIndex;
@property (nonatomic , assign) NSInteger totalPageCount;
@property (nonatomic , strong) NSMutableArray *contentViews;
@property (nonatomic , strong) UIScrollView *scrollView;
@property (nonatomic , retain) NSString *title;
@property (nonatomic , strong) NSTimer *animationTimer;
@property (nonatomic , assign) NSTimeInterval animationDuration;
@end

@implementation CycleScrollView

-(void)dealloc{
    self.scrollView.delegate = nil;
    NSLog(@"CycleScrollView dealloc");
}

-(void)clear{
    [self.animationTimer invalidate];
}

- (void)setTotalPagesCount:(NSInteger (^)(void))totalPagesCount
{
    _totalPageCount = totalPagesCount();
    if (_totalPageCount > 0) {
        [self configContentViews];
        [self.animationTimer resumeTimerAfterTimeInterval:self.animationDuration];
    }
}

- (id)initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration
{
    self = [self initWithFrame:frame];
    NSDictionary *dic = [NSDictionary dictionaryWithObject:@"title" forKey:@"title"];
    _dataArray = [NSMutableArray arrayWithObject:dic];
    if (animationDuration > 0.0) {
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:(self.animationDuration = animationDuration)
                                                               target:self
                                                             selector:@selector(animationTimerDidFired:)
                                                             userInfo:nil
                                                              repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.animationTimer forMode:NSDefaultRunLoopMode];
        [self.animationTimer pauseTimer];
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame animationDuration:(NSTimeInterval)animationDuration andDataArray:(NSMutableArray *)dataArray
{
    
    _dataArray = dataArray;
    _totalPageCount = dataArray.count;
    self = [self initWithFrame:frame];
    if (animationDuration > 0.0) {
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:(self.animationDuration = animationDuration)
                                                               target:self
                                                             selector:@selector(animationTimerDidFired:)
                                                             userInfo:nil
                                                              repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.animationTimer forMode:NSDefaultRunLoopMode];
        [self.animationTimer pauseTimer];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizesSubviews = YES;
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.scrollView.autoresizingMask = 0xFF;
        self.scrollView.contentMode = UIViewContentModeCenter;
        self.scrollView.contentSize = CGSizeMake(3 * CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
        self.scrollView.delegate = self;
        self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
        self.scrollView.pagingEnabled = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:self.scrollView];
        self.currentPageIndex = 0;
        
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.frame.size.height-30, self.frame.size.width, 30)];
        self.pageControl.currentPage = 0;
        self.pageControl.numberOfPages = self.totalPageCount;
        self.pageControl.pageIndicatorTintColor = FMBlueColor;
        [self addSubview:self.pageControl];
        
        // flash 标题文字及背景
        self.flashTitlebackColor = [[UILabel alloc]initWithFrame:CGRectMake(0, self.frame.size.height-45, self.frame.size.width, 45)];
        self.flashTitlebackColor.backgroundColor = [UIColor blackColor];
        self.flashTitlebackColor.alpha = 0.2;
        self.flashTitlebackColor.hidden = YES;
        [self addSubview:_flashTitlebackColor];
        
        self.flashTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, self.frame.size.height-35, self.frame.size.width, 20)];
        self.flashTitle.backgroundColor = [UIColor clearColor];
        _flashTitle.text = _dataArray[0][@"title"];
        self.flashTitle.textColor = [UIColor whiteColor];
        self.flashTitle.font = [UIFont systemFontOfSize:14];
        self.flashTitle.textAlignment = NSTextAlignmentCenter;
        self.flashTitle.hidden = YES;
        [self addSubview:_flashTitle];
        
    }
    return self;
}

#pragma mark -
#pragma mark - 私有函数

- (void)configContentViews
{
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setScrollViewContentDataSource];
    
    NSInteger counter = 0;
    for (UIView *contentView in self.contentViews) {
        contentView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewTapAction:)];
        [contentView addGestureRecognizer:tapGesture];
        CGRect rightRect = contentView.frame;
        rightRect.origin = CGPointMake(CGRectGetWidth(self.scrollView.frame) * (counter ++), 0);
        //DDLogDebug(@"%d=%f",counter, rightRect.origin.x);
        contentView.frame = rightRect;
        [self.scrollView addSubview:contentView];
        
    }
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
    self.pageControl.numberOfPages = self.totalPageCount;
    self.pageControl.currentPage = self.currentPageIndex;
}

/**
 *  设置scrollView的content数据源，即contentViews
 */
- (void)setScrollViewContentDataSource
{
    NSInteger previousPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex - 1];
    NSInteger rearPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex + 1];
    if (self.contentViews == nil) {
        self.contentViews = [@[] mutableCopy];
    }
    [self.contentViews removeAllObjects];
    
    if (self.imageViews) {
        //UIView *preObj = self.fetchContentViewAtIndex(previousPageIndex);
        UIImageView *preObj = self.imageViews[previousPageIndex];
        if (previousPageIndex==_currentPageIndex) {
            preObj = [[UIImageView alloc] initWithImage:preObj.image];
        }
//        if ([[preObj class]isSubclassOfClass:[UIImageView class]]) {
//            UIImageView *iv = [[UIImageView alloc] initWithImage:((UIImageView*)preObj).image];
//            iv.frame = preObj.frame;
//            preObj = iv;
//            iv = nil;
//        }
        
        if (preObj) {
            [self.contentViews addObject:preObj];
            
        }
        if (self.imageViews[_currentPageIndex]){
            [self.contentViews addObject:self.imageViews[_currentPageIndex]];
        }
        if (self.imageViews[rearPageIndex]) {
            if (previousPageIndex==_currentPageIndex) {
                UIImageView *nextImage = self.imageViews[rearPageIndex];
                [self.contentViews addObject:[[UIImageView alloc] initWithImage:nextImage.image]];
                nextImage = nil;
            }else{
                [self.contentViews addObject:self.imageViews[rearPageIndex]];
            }
            
        }
        
        
        
    }
}

- (NSInteger)getValidNextPageIndexWithPageIndex:(NSInteger)currentPageIndex;
{
    if(currentPageIndex == -1) {
        return self.totalPageCount - 1;
    } else if (currentPageIndex == self.totalPageCount) {
        return 0;
    } else {
        return currentPageIndex;
    }
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.animationTimer pauseTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.animationTimer resumeTimerAfterTimeInterval:self.animationDuration];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_dataArray.count==1) {
        
    }else{
        
        NSDictionary *dict = _dataArray[_totalPageCount-1];
        [_dataArray addObject:dict];
    }
    
    int contentOffsetX = scrollView.contentOffset.x;
    if(contentOffsetX >= (2 * CGRectGetWidth(scrollView.frame))) {
        self.currentPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex + 1];
//        NSLog(@"next，当前页:%d",self.currentPageIndex);
        if (_dataArray.count ==1) {
            _flashTitle.text = _dataArray[0][@"title"];
        }else{
            _flashTitle.text = _dataArray[self.currentPageIndex][@"title"];
        }
        
        [self configContentViews];
    }
    if(contentOffsetX <= 0) {
        self.currentPageIndex = [self getValidNextPageIndexWithPageIndex:self.currentPageIndex - 1];
//        NSLog(@"previous，当前页:%d",self.currentPageIndex);
        if (_dataArray.count ==1) {
        _flashTitle.text = _dataArray[0][@"title"];
        }else{
            _flashTitle.text = _dataArray[self.currentPageIndex][@"title"];
        }

        [self configContentViews];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [scrollView setContentOffset:CGPointMake(CGRectGetWidth(scrollView.frame), 0) animated:YES];
}

#pragma mark -
#pragma mark - 响应事件

- (void)animationTimerDidFired:(NSTimer *)timer
{
    int x = self.scrollView.contentOffset.x;
    int w = self.scrollView.frame.size.width;
    if ((x % w)>0) {
        int y = x % w; // 余数
        // 如果余数大于宽度的一半，就证明要滚动到下一页了
        if (y<w/2) {
            x = x/w * w;
        }
    }
    CGPoint newOffset = CGPointMake(x + CGRectGetWidth(self.scrollView.frame), self.scrollView.contentOffset.y);
    [self.scrollView setContentOffset:newOffset animated:YES];
}

- (void)contentViewTapAction:(UITapGestureRecognizer *)tap
{
    if (self.TapActionBlock) {
        self.TapActionBlock(self.currentPageIndex);
    }
}

 

@end
