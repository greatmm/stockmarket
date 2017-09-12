//
//  FMHeader.h
//  FMStockChart
//
//  Created by dangfm on 15/8/19.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#ifndef FMStockChart_FMHeader_h
#define FMStockChart_FMHeader_h

#define kFMColor(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255.0 green:((float)((hex & 0xFF00) >> 8))/255.0 blue:((float)(hex & 0xFF))/255.0 alpha:1.0]

/*
 release的时候会关掉
 */
#ifdef DEBUG
#define FMLog(FORMAT, ...) fprintf(stderr,"%s:%d\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define FMLog(FORMAT, ...) nil
#endif

#define __FMWeakSelf __weak typeof(self) __weakSelf = self

#define IOS8            ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0)
#define UIScreenWidth                              [UIScreen mainScreen].bounds.size.width
#define UIScreenHeight                             [UIScreen mainScreen].bounds.size.height

#define fmBaseURL [HttpManager server] //线上发布服务器地址
#define fmURL(...) [fmBaseURL stringByAppendingFormat:__VA_ARGS__]

#define fmHttpRequestTimeout 20.0    // 默认20秒超时
#define fmHttpRequestMethod @"POST"

#define fmUserIdKey @"fmUserIdKey"
#define fmUserIsPayKey @"fmUserIsPayKey"

#endif

