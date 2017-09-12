//
//  FMWebViewController.h
//  FMMarket
//
//  Created by dangfm on 15/12/3.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

/**
 *  主要用于打开web界面
    文章详情页，h5页面等
 */


#import "FMBaseViewController.h"

@interface FMWebViewController : FMBaseViewController
@property (nonatomic,retain) NSString *titler;          // 标题
@property (nonatomic,retain) NSURL *url;                // url地址
@property (nonatomic,retain) UIWebView *webview;        // webView对象

/**
 *  初始化webView界面
 *
 *  @param title      标题
 *  @param url        地址
 *  @param returnType 返回类型 1是返回上一页 2是退出
 *
 *  @return FMWebViewController
 */
-(instancetype)initWithTitle:(NSString*)title url:(NSURL*)url returnType:(int)returnType;


@end
