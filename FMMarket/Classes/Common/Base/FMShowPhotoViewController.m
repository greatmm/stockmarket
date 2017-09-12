//
//  FMShowPhotoViewController.m
//  FMMarket
//
//  Created by dangfm on 16/5/4.
//  Copyright © 2016年 dangfm. All rights reserved.
//

#import "FMShowPhotoViewController.h"

@interface FMShowPhotoViewController ()
<UIScrollViewDelegate>
{
}
@property (nonatomic,retain) NSArray *images;
@property (nonatomic,retain) UIImageView *imageView;
@property (nonatomic,retain) UIImage *backgroundImg;
@property (nonatomic,retain) UIScrollView *mainBox;
@property (nonatomic,retain) UILabel *totalTip;
@property (nonatomic,retain) UIActivityIndicatorView *loadingView;
@property (nonatomic,retain) UIView *loading;

@property (nonatomic,assign) CGFloat lastScale;
@property (nonatomic,assign) CGFloat lastPix;
@property (nonatomic,assign) CGFloat lastPiy;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,assign) DirectionStyle screenType;
@property (nonatomic,assign) int page;
@property (nonatomic,assign) CGFloat lastWith;
@property (nonatomic,assign) CGFloat screenWidth;
@property (nonatomic,assign) CGFloat screenHeight;


@end


@implementation FMShowPhotoViewController

-(void)dealloc{
    NSLog(@"FMShowPhotoViewController dealloc");
}

+(instancetype)sharedManager{
    static FMShowPhotoViewController *myself = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        myself = [[self alloc] init];
    });
    return myself;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(instancetype)initWithPhotos:(NSArray*)images{
    if (self == [super init]) {
        _images = images;
        _lastScale = 1.0;
    }
    return self;
}


-(void)createPhotos:(NSArray*)images Index:(NSInteger)index ScreenType:(DirectionStyle)screenType BackgroundImg:(UIImage*)backgroundImg{
    _images = images;
    _lastScale = 1.0;
    _page = (int)index;
    _screenType = screenType;
    _backgroundImg = backgroundImg;
    self.view.backgroundColor = [UIColor clearColor];
    NSDictionary *dic = [_images firstObject];
    NSString* firstImg = [dic objectForKey:@"src"];
    
    UIImage *img = [dic objectForKey:@"img"];
    if (!img || [[img class] isSubclassOfClass:[UIImage class]]) {
        img = [self readCacheWithFileName:firstImg];
    }

    [self transToVorital];
}

-(void)transToHorizontal{
    WEAKSELF
    _screenType = direction_Horizontal;
    //设置应用程序的状态栏到指定的方向
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight animated:NO];
    //隐藏状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [UIView animateWithDuration:0.3 animations:^{
        [__weakSelf removeMySelf];
        __weakSelf.view.transform = CGAffineTransformMakeRotation(M_PI/2);
        __weakSelf.view.bounds = CGRectMake(0, 0, UIScreenHeight, UIScreenWidth);
        [__weakSelf createViews];
    } completion:^(BOOL isfinish){
        
    }];
}
-(void)transToVorital{
    _screenType = direction_Vertical;
    //设置应用程序的状态栏到指定的方向
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
    //隐藏状态栏
    //[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    [self removeMySelf];
    self.view.transform = CGAffineTransformMakeRotation(0.0);
    self.view.bounds = CGRectMake(0, 0, UIScreenWidth, UIScreenHeight);
    [self createViews];

}
-(void)createViews{
    _screenHeight = UIScreenHeight;
    _screenWidth = UIScreenWidth;
    if (_screenType==direction_Horizontal) {
        _screenHeight = UIScreenWidth;
        _screenWidth = UIScreenHeight;
    }
    self.view.backgroundColor = [UIColor clearColor];
    //self.view.frame = kScreenBounds;
    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
    [self createMainBox];
    
    
    // 长按手势
    UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                                                initWithTarget:self
                                                                action:@selector(longPressHandle:)];
    longPressGestureRecognizer.minimumPressDuration = 0.5;
    [_mainBox addGestureRecognizer:longPressGestureRecognizer];
    longPressGestureRecognizer = nil;
    
    // 单击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(returnBack)];
    [_mainBox addGestureRecognizer:tap];
    
    // 双击手势
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapVideoBoxHandle:)];
    
    [_mainBox addGestureRecognizer:doubleTapRecognizer];
    doubleTapRecognizer.numberOfTapsRequired = 2; // 双击
    // 关键在这一行，双击手势确定监测失败才会触发单击手势的相应操作
    [tap requireGestureRecognizerToFail:doubleTapRecognizer];
    tap = nil;
    doubleTapRecognizer = nil;

}

#pragma mark 创建盒子
-(void)createMainBox{
    if (!_mainBox) {
        _mainBox = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight)];
        _mainBox.backgroundColor = [UIColor clearColor];
        CGFloat w = (int)_images.count * _screenWidth;
        if (w<_screenWidth) {
            w = _screenWidth;
        }
        _mainBox.contentSize = CGSizeMake(w+1, _screenHeight);
        _mainBox.pagingEnabled = YES;
        _mainBox.scrollEnabled = YES;
        _mainBox.delegate = self;
        _mainBox.alpha = 0;
        _mainBox.backgroundColor = [UIColor blackColor];
        _mainBox.contentMode = UIViewContentModeCenter;
        [self.view addSubview:_mainBox];
        
        
        // 关闭按钮
        UIImage *img = ThemeImage(@"global/icon_close_normal");
        UIButton *closeBt = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, img.size.width+30, img.size.height+60)];
        [closeBt setImage:img forState:UIControlStateNormal];
        [closeBt setImage:ThemeImage(@"global/icon_close_normal") forState:UIControlStateHighlighted];
        [closeBt addTarget:self action:@selector(returnBack) forControlEvents:UIControlEventTouchUpInside];
        closeBt.alpha = 0.9;
        [self.view addSubview:closeBt];
        self.view.alpha = 0;
        // 加载第一张图片
        [self createImagesViews:0];
        WEAKSELF
        [UIView animateWithDuration:0.5 animations:^{
            _mainBox.alpha = 0.99;
            __weakSelf.view.alpha = 1;
        } completion:^(BOOL isfinished){
            
        }];

        // 移动到指定位置
        [self move:_page animated:NO];
        for (int i=0; i<_images.count; i++) {
            [self createImagesViews:i];
        }
        [self createTotalTip];
    }else{
        CGFloat w = (int)_images.count * _screenWidth;
        if (w<_screenWidth) {
            w = _screenWidth;
        }
        _mainBox.contentSize = CGSizeMake(w+1, _screenHeight);
        _mainBox.frame = CGRectMake(0, 0, _screenWidth, _screenHeight);
        for (int i=0; i<_images.count; i++) {
            [self createImagesViews:i];
        }
        [self createImagesViews:_page];
        [self createTotalTip];
    }
}
-(void)createTotalTip{
    if (!_totalTip) {
        _totalTip = [[UILabel alloc] init];
        [self.view addSubview:_totalTip];
    }
    _totalTip.font = kFont(14);
    _totalTip.textColor = [UIColor whiteColor];
    _totalTip.text = [NSString stringWithFormat:@"%d / %ld",_page+1,(long)_images.count];
    [_totalTip sizeToFit];
    _totalTip.frame = CGRectMake((_screenWidth-_totalTip.frame.size.width)/2, 35, _totalTip.frame.size.width, _totalTip.frame.size.height);
    
}
#pragma mark 加载指定位置图片
-(void)createImagesViews:(NSInteger)page{
    WEAKSELF
    if (page<=0) {
        page = 0;
    }
    CGFloat startX = page * _screenWidth;
    NSDictionary *dic = [_images objectAtIndex:page];
    NSString* img = [dic objectForKey:@"src"];
    // 从webVie拿到的缓存图片
    UIImage *imgCache = dic[@"img"];
    if ([[img class] isSubclassOfClass:[NSString class]]) {
        // 请求网络图片
        UIImage *loadingImage ;
        UIScrollView *imgBox;
        imgBox = (UIScrollView*)[_mainBox viewWithTag:1000+page];
        
        if (imgBox) {
            return;
        }
        imgBox = [[UIScrollView alloc] init];
        imgBox.maximumZoomScale = 100;
        imgBox.minimumZoomScale = 1;
        imgBox.delegate = self;
        imgBox.contentMode = UIViewContentModeCenter;
        [_mainBox addSubview:imgBox];
        // 加载
        UIActivityIndicatorView *lv = [self loadingView];
        [imgBox addSubview:lv];
        
        UIImageView *imgview = [[UIImageView alloc] initWithImage:loadingImage];
        [imgBox addSubview:imgview];
        CGFloat x = startX;
        CGFloat y = (_screenHeight - loadingImage.size.height)/2;
        imgBox.frame = CGRectMake(x,  0 , _screenWidth, _screenHeight);
        CGRect frame = CGRectMake(0 , y , loadingImage.size.width , loadingImage.size.height);
        imgview.frame = frame;
        imgview.tag = 100;
        imgBox.tag = 1000+page;
        //imgview.isMultipleTouchEnabled = YES;
        // 读取缓存
        UIImage *imageTemp = imgCache;
        if (imageTemp==nil) {
            imageTemp = [self readCacheWithFileName:img];
        }
        if (!imageTemp) {
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:img] options:SDWebImageDownloaderContinueInBackground progress:^(NSInteger a,NSInteger b){
                //NSLog(@"a=%ld",(long)a);
                
            } completed:^(UIImage *image ,NSData *data,NSError *error,BOOL isfinish){
                [lv stopAnimating];
                lv.hidden = YES;
                if (image.imageOrientation!=UIImageOrientationUp && _screenType==direction_Vertical) {
                    // 修改图片的方向为竖方向
//                    image = [fn image:image rotation:image.imageOrientation];
                }
                if (image) {
                    imgview.image = image;
                    imgview.frame = [self frameWithimg:image];
                    
                    imgview.alpha = 0;
                    [UIView animateWithDuration:0.3 animations:^{
                        imgview.alpha = 1;
                    }];
                    
                    // 缓存
                    [__weakSelf createCacheWithImage:image FileName:img];
                    
                }
                
            }];
        }else{
            [lv stopAnimating];
            lv.hidden = YES;
            imgview.image = imageTemp;
            imgview.frame = [self frameWithimg:imageTemp];
            imgview.alpha = 1;
            
            [UIView animateWithDuration:0.3 animations:^{
                imgview.alpha = 1;
            }];
        }
        
        
        imgview = nil;
    }
}

#pragma mark 自适应尺寸
-(CGRect)frameWithimg:(UIImage*)image{
    CGFloat w = image.size.width;
    CGFloat h = image.size.height;
    CGFloat b = w/h; // 宽高比例
    CGFloat y = (self.view.bounds.size.height - h)/2;
    CGFloat x = (self.view.bounds.size.width-w)/2;
    CGFloat screenWidth = UIScreenWidth;
    CGFloat screenHeight = UIScreenHeight;
    if (_screenType==direction_Horizontal) {
        screenHeight = UIScreenWidth;
        screenWidth = UIScreenHeight;
    }
    
    if (w>screenWidth) {
        // 按比例高度
        w = screenWidth;
        h = w/b;
    }
    if (h>screenHeight) {
        // 按比例宽度
        h = screenHeight;
        w = h*b;
    }
    y = (screenHeight - h)/2;
    x = (screenWidth-w)/2;
    
    return CGRectMake(x, y, w, h);
}

-(UIActivityIndicatorView*)loadingView{
    
    UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    loadingView.frame = CGRectMake((_screenWidth-loadingView.frame.size.width)/2, (_screenHeight-loadingView.frame.size.height)/2, loadingView.frame.size.width, loadingView.frame.size.height);
    [loadingView startAnimating];
    loadingView.hidden = NO;
    [loadingView performSelector:@selector(stopAnimating) withObject:nil afterDelay:10];
    return loadingView;
    
}
#pragma mark 缓存操作
-(void)createCacheWithImage:(UIImage*)image FileName:(NSString*)fileName{
    fileName = [fn md5:fileName];
    fileName = [fn realPathWithFileName:fileName Path:@"newsImages"];
    if (image) {
        // 保存缓存
        NSData *data = UIImagePNGRepresentation(image);
        [data writeToFile:fileName atomically:YES];
        data = nil;
    }
}
-(UIImage*)readCacheWithFileName:(NSString*)fileName{
    if ([fileName rangeOfString:@"/var/mobile/"].location==NSNotFound) {
        fileName = [fn md5:fileName];
        fileName = [fn realPathWithFileName:fileName Path:@"newsImages"];
    }
    
    // 保存缓存
    NSData *data = [NSData dataWithContentsOfFile:fileName];
    UIImage *img;
    if (data) {
        img = [UIImage imageWithData:data];
    }
    
    return img;
}

-(void)returnBack{
    
    WEAKSELF
    //强制旋转
    FMAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.allowRotation = YES;
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger: UIDeviceOrientationPortrait] forKey:@"orientation"];
    appDelegate.didRotationBlock = nil;
    appDelegate.allowRotation = NO;
    appDelegate = nil;
    
    [UIView animateWithDuration:0.3 animations:^{
        _mainBox.alpha = 0;
        __weakSelf.view.alpha = 0;
        //设置应用程序的状态栏到指定的方向
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
        //显示状态栏
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        __weakSelf.view.transform = CGAffineTransformMakeRotation(0.0f);
        __weakSelf.view.bounds = CGRectMake(0, 0, UIScreenWidth, UIScreenHeight);
    } completion:^(BOOL isfinish){
        [__weakSelf removeMySelf];
        // 发通知
        [[NSNotificationCenter defaultCenter] postNotificationName:kFMShowPhotoComplateCloseNotificationKey object:nil];
        
    }];
    
    
}
-(void)removeMySelf{
    [_totalTip removeFromSuperview];
    _totalTip = nil;
    [_mainBox removeFromSuperview];
    _mainBox = nil;
    [self.view removeFromSuperview];
}

-(void)move:(int)page animated:(BOOL)animate{
    //self.contentOffset = CGPointMake(self.frame.size.width*page, self.frame.size.height);
    [_mainBox scrollRectToVisible:CGRectMake(_screenWidth*page, 0, _screenWidth, _screenHeight) animated:animate];
    _page = page;
    _lastWith = _screenWidth;
    [self createImagesViews:_page];
    [self createTotalTip];
}



-(void)longPressHandle:(UILongPressGestureRecognizer*)longPress{
    NSLog(@"保存");
}

// 双击放大
-(void)doubleTapVideoBoxHandle:(UITapGestureRecognizer*)tap{
    UIScrollView *scrollView = (UIScrollView*)[_mainBox viewWithTag:1000+_page];
    if ([[scrollView class] isSubclassOfClass:[UIScrollView class]]) {
        UIImageView *imageView = (UIImageView*)[scrollView viewWithTag:100];
        if(imageView.transform.a<2)
            [scrollView setZoomScale:2.0 animated:YES];
        else
            [scrollView setZoomScale:1.0 animated:YES];
        imageView = nil;
    }
    scrollView = nil;
    
}

#pragma mark *****************scrollView代理*******************
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (scrollView==_mainBox) {
        // 页码
        int page = scrollView.contentOffset.x / scrollView.frame.size.width;
        if (page!=_page) {
            _page = page;
            [self move:_page animated:YES];
            if (self.moveBlock) {
                self.moveBlock(_page);
            }
        }
        
    }
    
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    
}
-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    if (scrollView!=_mainBox) {
        UIImageView *imageView = (UIImageView*)[scrollView viewWithTag:100];
        UIScrollView *imgBox = (UIScrollView*)imageView.superview;
        
//        if (imageView.frame.size.height<=_screenHeight) {
//            imageView.frame = CGRectMake((_screenWidth-imageView.frame.origin.x)/2, (_screenHeight-imageView.frame.size.height)/2+imgBox.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height);
//        }else{
//            imageView.frame = CGRectMake(imageView.frame.origin.x, imgBox.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height);
//        }
        float x = (_screenWidth-imageView.frame.size.width)/2;
        float y = (_screenHeight-imageView.frame.size.height)/2;
        y = y<=0?0:y;
        x = x<=0?0:x;
        imageView.frame = CGRectMake(x, y, imageView.frame.size.width, imageView.frame.size.height);
        if (imageView.frame.size.width>_screenWidth || imageView.frame.size.height>_screenHeight) {
            imgBox.contentSize = imageView.frame.size;
        }
    }
    
}
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    if (scrollView!=_mainBox) {
        UIImageView *imgview = (UIImageView*)[scrollView viewWithTag:100];
        CGRect frame = imgview.frame;
        return imgview;
    }
    return nil;
}

@end
