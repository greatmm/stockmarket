//
//  FMThemeManager.h
//  FMMarket
//
//  Created by dangfm on 15/8/9.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

#ifndef _SYSTEMCONFIGURATION_H
#error  You should include the `SystemConfiguration` framework and \
add `#import <SystemConfiguration/SystemConfiguration.h>`\
to the header prefix.
#endif

#ifdef _SYSTEMCONFIGURATION_H
extern NSString * const ThemeDidChangeNotification;
#endif

#define kThemeName @"theme.bundle"

#define kThemeDefault   @"default"
#define kThemeBlack     @"black"

#define IMAGE(imagePath) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(imagePath) ofType:@"png"]]

#define ThemeImage(imageName) [[FMThemeManager sharedInstance] imageWithImageName:(imageName)]
#define ThemeColor(keyname) [[FMThemeManager sharedInstance] colorWithName:(keyname)]
#define ThemeJson(filename) [[FMThemeManager sharedInstance] jsonWithFileName:(filename)]
#define ThemeJs(filename) [[FMThemeManager sharedInstance] jsWithFileName:(filename)]
#define ThemeSaveJson(filename,data) [[FMThemeManager sharedInstance] jsonSaveFileName:(filename) Content:(data)]

typedef enum {
    ThemeStatusWillChange = 0, // todo
    ThemeStatusDidChange,
} ThemeStatus;

@interface FMThemeManager : NSObject

@property (strong, nonatomic) NSString *theme;

+ (FMThemeManager *)sharedInstance;

- (UIImage *)imageWithImageName:(NSString *)imageName;
#pragma mark 获取颜色配置
- (UIColor*)colorWithName:(NSString*)keyname;
- (NSDictionary *)jsonWithFileName:(NSString *)filename;
- (void)jsonSaveFileName:(NSString *)filename Content:(NSDictionary*)dic;
- (NSString *)jsWithFileName:(NSString *)filename;

@end
