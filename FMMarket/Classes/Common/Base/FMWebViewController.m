//
//  FMWebViewController.m
//  FMMarket
//
//  Created by dangfm on 15/12/3.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMWebViewController.h"
#import "FMShowPhotoViewController.h"
@interface FMWebViewController ()
<UIWebViewDelegate,UIScrollViewDelegate,UMSocialUIDelegate>
{
    
}
@property (nonatomic,retain) NSMutableArray *images;
@property (nonatomic,retain) NSString *shareTitle;
@property (nonatomic,retain) NSString *shareIntro;
@property (nonatomic,retain) NSString *shareUrl;
@property (nonatomic,assign) BOOL isReloadHtml; // 重新加载HTML
@end

@implementation FMWebViewController

-(void)dealloc{
    NSLog(@"FMWebViewController dealloc");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:_titler IsBack:YES ReturnType:self.returnType];
    [self createWebView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    self.tabBarController.tabBar.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Init

/**
 *  初始化
 *
 *  @param title      标题
 *  @param url        地址
 */
-(instancetype)initWithTitle:(NSString *)title url:(NSURL *)url returnType:(int)returnType{
    if (self==[super init]) {
        _titler = title;
        _url = url;
        self.returnType = returnType;
    }
    return self;
}


/**
 *  创建webView
 */
-(void)createWebView{
    
    UIButton *share = [[UIButton alloc] initWithFrame:CGRectMake(UIScreenWidth-80, 0, 80, kNavigationHeight)];
    [share setTitle:@"分享" forState:UIControlStateNormal];
    share.titleLabel.font = kFont(16);
    [share addTarget:self action:@selector(clickShareButton) forControlEvents:UIControlEventTouchUpInside];
    [self.header addSubview:share];
    
    
    CGFloat paddingTop = 0;
    CGRect frame;
    // 根据返回类型做位置处理
    if (self.returnType==1) {
        paddingTop = 0;
        frame=CGRectMake(0, self.header.frame.size.height+self.header.frame.origin.y-paddingTop, self.view.frame.size.width, self.view.frame.size.height-self.header.frame.size.height-self.header.frame.origin.y+paddingTop+50);
    }else{
        paddingTop = 0;
        frame=CGRectMake(0, self.header.frame.size.height+self.header.frame.origin.y-paddingTop, self.view.frame.size.width, self.view.frame.size.height-self.header.frame.size.height-self.header.frame.origin.y+paddingTop+50);
    }
    
    frame = CGRectMake(0, self.point.y, UIScreenWidth, UIScreenHeight-self.point.y);
    if (!_webview) {
        _webview = [[UIWebView alloc] initWithFrame:frame];
        NSLog(@"self.header.frame.size.height\n%.f  self.header.frame.origin.y\n%.f paddingTop %.f",self.header.frame.size.height,self.header.frame.origin.y,paddingTop);
        _webview.backgroundColor = [UIColor clearColor];
        _webview.opaque = NO;
        _webview.delegate = self;
        _webview.scrollView.delegate = self;
        [_webview setScalesPageToFit:YES];
        [self.view addSubview:_webview];
        [self.view sendSubviewToBack:_webview];
        
        // 有地址则请求
        if (_url) {
            NSURLRequest *request =[NSURLRequest requestWithURL:_url];
            _shareUrl = _url.absoluteString;
            [_webview loadRequest:request];
            request = nil;
        }else{
        }
    }
    
    
}

#pragma mark - UIAction
-(void)clickShareButton{
    
    
    TumblrLikeMenuItem *menuItem0 = [[TumblrLikeMenuItem alloc] initWithImage:[UIImage imageNamed:@"icon_weixin"]
                                                             highlightedImage:[UIImage imageNamed:@"icon_weixin"]
                                                                         text:@"微信好友"];
    TumblrLikeMenuItem *menuItem1 = [[TumblrLikeMenuItem alloc] initWithImage:[UIImage imageNamed:@"icon_weixinquan"]
                                                             highlightedImage:[UIImage imageNamed:@"icon_weixinquan"]
                                                                         text:@"微信朋友圈"];
    TumblrLikeMenuItem *menuItem2 = [[TumblrLikeMenuItem alloc] initWithImage:[UIImage imageNamed:@"icon_weibo"]
                                                             highlightedImage:[UIImage imageNamed:@"icon_weibo"]
                                                                         text:@"新浪微博"];
    TumblrLikeMenuItem *menuItem3 = [[TumblrLikeMenuItem alloc] initWithImage:[UIImage imageNamed:@"icon_qq"]
                                                             highlightedImage:[UIImage imageNamed:@"icon_qq"]
                                                                         text:@"QQ好友"];
    TumblrLikeMenuItem *menuItem4 = [[TumblrLikeMenuItem alloc] initWithImage:[UIImage imageNamed:@"icon_qqzone"]
                                                             highlightedImage:[UIImage imageNamed:@"icon_qqzone"]
                                                                         text:@"QQ空间"];
    TumblrLikeMenuItem *menuItem5 = [[TumblrLikeMenuItem alloc] initWithImage:[UIImage imageNamed:@"icon_copyurl"]
                                                             highlightedImage:[UIImage imageNamed:@"icon_copyurl"]
                                                                         text:@"复制链接"];
    
    NSArray *subMenus = @[menuItem0, menuItem1, menuItem2, menuItem3, menuItem4, menuItem5];
    
    TumblrLikeMenu *menu = [[TumblrLikeMenu alloc] initWithFrame:self.view.bounds
                                                        subMenus:subMenus
                                                             tip:@""];
    menu.selectBlock = ^(NSUInteger index) {
        NSLog(@"item %ld index selected", index);
        NSString *type = @"";
        UIImage *img;
        NSDictionary *dic = _images.firstObject;
        if ([[dic class] isSubclassOfClass:[NSDictionary class]]) {
            NSString *src = dic[@"src"];
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:src]];
            
            if (data) {
                img = [UIImage imageWithData:data];
            }
        }
        
        if (img==nil) {
            img = [UIImage imageNamed:@"AppIcon60x60"];
        }
        _shareUrl = [_url.absoluteString append:@"&app=iphone"];
        
        
        switch (index) {
            case 0:
            {
                //_shareTitle = [_shareTitle stringByAppendingString:_shareUrl];
                type = UMShareToWechatSession;
                [UMSocialData defaultData].extConfig.wechatSessionData.url = _shareUrl;
                [UMSocialData defaultData].extConfig.wechatSessionData.title = _shareTitle;
                //需要自定义面板样式的开发者需要自己绘制UI，在对应的分享按钮中调用此接口
                UMSocialUrlResource *urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeWeb url:
                                                    _shareUrl];
                [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[type] content:_shareIntro image:img location:nil urlResource:urlResource presentedController:self completion:^(UMSocialResponseEntity *shareResponse){
                    if (shareResponse.responseCode == UMSResponseCodeSuccess) {
                        NSLog(@"微信分享成功！");
                    }
                }];
            }
                break;
            case 1:
            {
                //_shareTitle = [_shareTitle stringByAppendingString:_shareUrl];
                type = UMShareToWechatTimeline;
                [UMSocialData defaultData].extConfig.wechatTimelineData.url = _shareUrl;
                [UMSocialData defaultData].extConfig.wechatTimelineData.title = _shareTitle;
                //需要自定义面板样式的开发者需要自己绘制UI，在对应的分享按钮中调用此接口
                UMSocialUrlResource *urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeWeb url:
                                                    _shareUrl];
                [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[type] content:_shareIntro image:img location:nil urlResource:urlResource presentedController:self completion:^(UMSocialResponseEntity *shareResponse){
                    if (shareResponse.responseCode == UMSResponseCodeSuccess) {
                        NSLog(@"朋友圈分享成功！");
                    }
                }];
            }
                break;
            case 2:
            {
                _shareIntro = [_shareTitle stringByAppendingString:_shareUrl];
                type = UMShareToSina;
                [UMSocialData defaultData].extConfig.sinaData.urlResource.url = _shareUrl;
                [UMSocialData defaultData].extConfig.sinaData.shareText = _shareIntro;
                [UMSocialData defaultData].extConfig.sinaData.shareImage = img;
                //需要自定义面板样式的开发者需要自己绘制UI，在对应的分享按钮中调用此接口
                UMSocialUrlResource *urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:
                                                    _shareUrl];
                [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[type] content:_shareIntro image:img location:nil urlResource:urlResource presentedController:self completion:^(UMSocialResponseEntity *shareResponse){
                    if (shareResponse.responseCode == UMSResponseCodeSuccess) {
                        NSLog(@"新浪分享成功！");
                    }
                }];
            }
                break;
            case 3:
            {
                _shareIntro = [_shareTitle stringByAppendingString:_shareUrl];
                type = UMShareToQQ;
                [UMSocialData defaultData].extConfig.qqData.url = _shareUrl;
                [UMSocialData defaultData].extConfig.qqData.title = _shareTitle;
                [UMSocialData defaultData].extConfig.qqData.shareImage = img;
                [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
                //需要自定义面板样式的开发者需要自己绘制UI，在对应的分享按钮中调用此接口
                UMSocialUrlResource *urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeWeb url:
                                                    _shareUrl];
                [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[type] content:_shareIntro image:img location:nil urlResource:urlResource presentedController:self completion:^(UMSocialResponseEntity *shareResponse){
                    if (shareResponse.responseCode == UMSResponseCodeSuccess) {
                        NSLog(@"QQ好友分享成功！");
                    }
                }];
            }
                break;
            case 4:
            {
                _shareIntro = [_shareTitle stringByAppendingString:_shareUrl];
                type = UMShareToQzone;
                [UMSocialData defaultData].extConfig.qzoneData.url = _shareUrl;
                [UMSocialData defaultData].extConfig.qzoneData.title = _shareTitle;
                [UMSocialData defaultData].extConfig.qzoneData.shareImage = img;
                //需要自定义面板样式的开发者需要自己绘制UI，在对应的分享按钮中调用此接口
                UMSocialUrlResource *urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeWeb url:
                                                    _shareUrl];
                [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[type] content:_shareIntro image:img location:nil urlResource:urlResource presentedController:self completion:^(UMSocialResponseEntity *shareResponse){
                    if (shareResponse.responseCode == UMSResponseCodeSuccess) {
                        NSLog(@"QQ空间分享成功！");
                    }
                }];
            }
                break;
            case 5:
            {
                type = @"copyUrl";
                if ([type isEqualToString:@"copyUrl"]) {
                    UIPasteboard *pastboad = [UIPasteboard generalPasteboard];
                    pastboad.string = _shareUrl;
                    [SVProgressHUD showSuccessWithStatus:@"复制链接成功"];
                }
            }
                break;
                
            default:
                break;
        }

        
    };
    [menu showInView:self.view];
    
    
}

#pragma mark -
#pragma mark 分享代理 UMSocialUIDelegate
// 分享完成成功
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response{
    
}

//// 点击分享平台
//-(void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData
//{
//
//}

#pragma mark -
#pragma mark UIWebViewDelegate

// webView代理 开始加载
-(void)webViewDidStartLoad:(UIWebView *)webView{
    if (_isReloadHtml) {
        return;
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeNone];
    _webview.alpha = 0;
}

// 加载完成
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    if (_isReloadHtml) {
        return;
    }
    
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('title')[0].innerHTML;"];
    _shareTitle = title;
    // 根据H5标题设置控制器标题
    if ([self.header.titler.text isEqualToString:@""]) {
        [self titleWithName:title];
        
        title = nil;
    }
    
    if ([_url.absoluteString rangeOfString:kAPI_ArticleContent].location!=NSNotFound) {
        NSString *jsToGetHTMLSource = @"document.getElementsByTagName('html')[0].innerHTML";
        NSString *HTMLSource = [webView stringByEvaluatingJavaScriptFromString:jsToGetHTMLSource];
        jsToGetHTMLSource = @"document.getElementById('description').getAttribute('content')";
        NSString *innerText = [webView stringByEvaluatingJavaScriptFromString:jsToGetHTMLSource];
        HTMLSource = [fn formatImgWithHTML:HTMLSource];
        _images = [fn findImgFromHTML:HTMLSource];
        
        NSString *js = @"<script Type='text/javascript'>\n"
        "function returnImgPoint(index) {\n"
        "var img = document.getElementsByTagName(\"img\")[index];\n"
        "var offset = img.offsetTop-(document.body.clientHeight-img.clientHeight)/2+44+20;\n"
        "//alert('点击按钮了！'+offset);\n"
        "window.scrollTo(0,offset);\n"
        "return offset;"
        "}\n"
        "function show(index){\n"
        "var img= document.getElementsByTagName('img')[index];\n"
        "//alert(img);\n"
        "//img = img.childNodes[0];\n"
        "//alert(img);\n"
        "var canvas = document.createElement(\"canvas\");\n"
        "var context = canvas.getContext(\"2d\");\n"
        "canvas.width = img.width;\n"
        "canvas.height = img.height;\n"
        "//alert(img.width+','+img.height);\n"
        "context.drawImage(img,0,0,img.width,img.height);\n"
        "//alert(canvas.toDataURL(\"image/png\"));\n"
        "document.getElementsByTagName('h1').innerHTML = canvas.toDataURL(\"image/png\");\n"
        "return canvas.toDataURL(\"image/png\");\n"
        "}\n"
        "</script>\n";
        
        HTMLSource = [HTMLSource stringByAppendingString:js];
        HTMLSource = [NSString stringWithFormat:@"<!DOCTYPE html><html style=\"font-size: 100px;\" data-percent=\"100\" data-width=\"750\" data-dpr=\"1\" lang=\"zh\">%@</html>",HTMLSource];
        [webView loadHTMLString:HTMLSource baseURL:_url];
        
        _shareIntro = innerText;
    }
    
    _isReloadHtml = YES;
    WEAKSELF
    [UIView animateWithDuration:0.5 animations:^{
        __weakSelf.webview.alpha = 1;
        [SVProgressHUD dismiss];
    } completion:^(BOOL finish){
        
    }];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [SVProgressHUD dismiss];
}


// webView协议处理，这里暂时用不到
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    // 从webView里的图片缓存获取图片
    for (int i=0; i<_images.count; i++) {
        if (!_images[i][@"img"]) {
            NSString *imgDataStr = [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"show(%d);",i]];
            if ([imgDataStr rangeOfString:@","].location !=NSNotFound) {
                NSArray *datas = [imgDataStr componentsSeparatedByString:@","];
                imgDataStr = datas[1];
                NSData *imgData = [[NSData alloc] initWithBase64EncodedString:imgDataStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
                UIImage *img = [UIImage imageWithData:imgData];
                if (img) {
                    NSMutableDictionary *dic = [_images objectAtIndex:i];
                    [dic setObject:img forKey:@"img"];
                    dic = nil;
                }
                imgData = nil;
                datas = nil;
                img = nil;
            }
            imgDataStr = nil;
        }
    }
    
    NSString *url = request.URL.absoluteString;
    NSString *scheme = request.URL.scheme;
    if ([scheme isEqualToString:@"mqq"]) {
        
    }
    
    if([url rangeOfString:@"show("].location !=NSNotFound){
        NSString *indexStr = [url substringFromIndex:[url rangeOfString:@"show("].location];
        indexStr = [indexStr stringByReplacingOccurrencesOfString:@"show(" withString:@""];
        indexStr = [indexStr stringByReplacingOccurrencesOfString:@")" withString:@""];
        NSInteger index = [indexStr integerValue];
        
        // 图片数组
        if (index>=_images.count) {
            index = _images.count - 1;
        }
        if (_images && index<_images.count) {
            NSDictionary *dic = [_images objectAtIndex:index];
            //NSLog(@"%@",dic);
            DirectionStyle screenType = direction_Vertical;
            WEAKSELF
            // 调用图片展示
            [[FMShowPhotoViewController sharedManager] createPhotos:_images Index:index ScreenType:screenType BackgroundImg:[fn imageFromView:self.view]];
            [FMShowPhotoViewController sharedManager].moveBlock = ^(int page){
                [__weakSelf imageScrollTopInWebView:page];
            };
            dic = nil;
        }
        indexStr = nil;
    }
    
    return YES;
}

-(void)imageScrollTopInWebView:(int)index{
    NSString *pointStr = [_webview stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"returnImgPoint(%ld)",(long)index]];
    CGFloat poingY = [pointStr floatValue]/[UIScreen mainScreen].scale;
    //NSLog(@"pointStr=%@ pointY=%f index=%ld",pointStr,poingY,(long)index);
    poingY = poingY - self.point.x;
    if (poingY<0) {
        poingY = 0;
    }
    if (poingY>_webview.scrollView.contentSize.width-_webview.frame.size.height) {
        poingY = _webview.scrollView.contentSize.width-_webview.frame.size.height;
    }
    //[_webview.scrollView setContentOffset:CGPointMake(0, poingY) animated:YES];
}

@end
