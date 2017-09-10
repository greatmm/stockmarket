//
//  FMGlobalDefines.h
//  FMMarket
//
//  Created by dangfm on 15/8/7.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#ifndef FMMarket_FMGlobalDefines_h
#define FMMarket_FMGlobalDefines_h

#define IOS8            ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0)
#define UIScreenWidth                              [UIScreen mainScreen].bounds.size.width
#define UIScreenHeight                             [UIScreen mainScreen].bounds.size.height
#define UISreenWidthScale   UIScreenWidth / 320
#define kNavigationHeight 44
#define kTabBarNavigationHeight 50
#define kTabBarNavigationHeight64 64
#define kStatusBarHeight 20

#define FMNavTitleColor UIColorFromRGB(0xFFFFFF)
#define FMNavColor UIColorFromRGB(0xde3031)
#define FMRedColor UIColorFromRGB(0xde3031)
#define FMGreenColor UIColorFromRGB(0x18c062)
#define FMGreyColor UIColorFromRGB(0x92a0ad)
#define FMBlueColor UIColorFromRGB(0x174da5)
#define FMYellowColor UIColorFromRGB(0xff8448)
#define FMLowGreenColor UIColorFromRGB(0x61da9d)
#define FMZeroColor UIColorFromRGB(0x000000)
#define FMTabbarColor UIColorFromRGB(0x333333)
#define FMBlackColor ThemeColor(@"Font_Black_Color")
#define FMBgGreyColor ThemeColor(@"Body_Grey_Color")
#define FMBottomLineColor ThemeColor(@"UITableViewCell_BottomLine_Color")
#define FMNoPhotoBgColor ThemeColor(@"Body_Grey_Color")

//  通知
#define kFMReachabilityChangedNotification  @"kFMReachabilityChangedNotification"
//  开始更新搜索数据库
#define kFMStartUpdateSearchDatabaseNotification  @"kFMStartUpdateSearchDatabaseNotification"
//  搜索数据库更新成功
#define kFMEndUpdateSearchDatabaseNotification  @"kFMEndUpdateSearchDatabaseNotification"
//  隐藏键盘通知
#define kFMMustHiddenKeyboardNotification  @"kFMMustHiddenKeyboardNotification"
//  界面变动通知
#define kFMTabBarChangeNotification @"kFMTabBarChangeNotification"
//  App回到前台通知
#define kFMAppWillEnterForegroundNotification @"kFMAppWillEnterForegroundNotification"
//  App回到后台台通知
#define kFMAppWillEnterBackgroundNotification @"kFMAppWillEnterBackgroundNotification"
// App将回到前台通知
#define kFMAppWillBecomeActiveNotification @"kFMAppWillBecomeActiveNotification"
// 启动开机广告
#define kFMAppStartAdViewNotification @"kFMAppStartAdViewNotification"
// 微信授权成功
#define kWechatDidLoginNotification @"wechatDidLoginNotification"
// 话题发布成功
#define kCommunitySendFinishedNotification @"kCommunitySendFinishedNotification"

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)


#pragma mark - UIColor宏定义
#define UIColorFromRGBA(rgbValue, alphaValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:alphaValue]

#define UIColorFromRGB(rgbValue) UIColorFromRGBA(rgbValue, 1.0)

#define dispatch_sync_main_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

#define dispatch_async_main_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

/*
 release的时候会关掉
 */
#ifdef DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s:%d\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(FORMAT, ...) nil
#endif



// 功能
#define fn FMHelper
#define db [FMDBManager shareManager]
#define http FMHttpRequest
#define WEAKSELF __weak typeof(self) __weakSelf = self;
//字体
// HelveticaNeue，HelveticaNeue-Bold
#define kFontSize 14.0
#define kFontName @"HelveticaNeue"
#define kFontBoldName @"HelveticaNeue-Bold"
#define kFontNumberName @"DINAlternate-Bold"
#define kFontNumberBoldName @"DINAlternate-Bold"
#define kFont(fontSize) [UIFont fontWithName:kFontName size:fontSize]
#define kFontBold(fontSize) [UIFont fontWithName:kFontBoldName size:fontSize]
#define kFontNumber(fontSize) [UIFont fontWithName:kFontNumberName size:fontSize]
#define kFontNumberBold(fontSize) [UIFont fontWithName:kFontNumberBoldName size:fontSize]
#define kDefaultFont kFont(kFontSize)

#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960),[[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136),[[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334),[[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208),[[UIScreen mainScreen] currentMode].size) : NO)

// 设备类型 0=ios 1=android 2=winphone 3=other
#define kDeviceType @"0"

#define kMustLogoutErrorCode 100110 // 被迫下线出错代码


// umeng
#define kUmeng_AppKey @"560d3a04e0f55a63c70084fd"
// 分享
#define kShare_SinaAppKey @"2313130527"
#define kShare_SinaAppSecret @"db22c634c8e465f8d3609936a0c19902"
#define kShare_SinaRedirectURL @"http://sns.whalecloud.com/sina2/callback"
#define kShare_WeixinAppKey @"wxae2fa6f401228151"
#define kShare_WeixinAppSecret @"67346b5f8465d0b3aa783b9136311265"
#define kShare_QQAppId @"1104933320"
#define kShare_QQAppKey @"FmkD4J2n3uWeMXUV"
// jpush
#define kJpush_AppKey @"0f80f1863c78bfc04b803dd2"
#define kJpush_cannel @"App Stroe"
// leancloud
#define kLeancloud_AppId @"kGWNVsfcq2s1FtgD45XFrPYM-gzGzoHsz"
#define kLeancloud_AppKey @"WtShETcu8IzjlLzbMADTdYDp"

// 清楚制定目录缓存
#define kClearCacheFolders @[@"/EGOCache",@"/fsCachedData",@"/day_",@"/month_",@"year_",@"SDWebImageCache",@"/newsImages"]

// app id
#define kAppStoreID @"1050396967"

// 接口地址
#define kBaseURL @"http://106.14.154.205:8082" // 线上发布服务器的根地址
#define kURL(...) [kBaseURL stringByAppendingFormat:__VA_ARGS__]

// 接口Token 签名用
#define kAPI_Key @"ed284ef243ee3c6c02f85875842cf21f"

// 启动图间隔启动时间 秒，到点后回触发还原机制，即界面会返回首页，并开启启动图广告，类似于重启
#define kUserDefault_StartTimeout 20*60

// 搜索股票 返回所有股票
// #define kAPI_SearchStocks kURL(@"/fmstocks.txt")
#define kAPI_SearchStocks_IsUpdate kURL(@"/search.php")
#define kAPI_Stocks_NewData kURL(@"/stocknewdata.php")
#define kAPI_Stocks_Info kURL(@"/stockinfo.php")
#define kAPI_Stocks_MainForce kURL(@"/stockmainforce.php")
#define kAPI_Stocks_StockCompany kURL(@"/stockcompany.php")
#define kAPI_Stocks_StockProfits kURL(@"/stockprofits.php")
#define kAPI_Stocks_StockCapital kURL(@"/stockcapital.php")
#define kAPI_Stocks_SelectStocks kURL(@"/selectstocks.php")
// User Center
#define kAPI_Users_UserRegister kURL(@"/user/register.php")
#define kAPI_Users_UserLogin kURL(@"/user/login.php")
#define kAPI_Users_UserSendSMS kURL(@"/user/sendsms.php")
#define kAPI_Users_UserForgetPassword kURL(@"/user/forgetpassword.php")
#define kAPI_Users_UserFeedbacks kURL(@"/user/feedback.php")
#define kAPI_Users_UserNickName kURL(@"/user/editnickname.php")
#define kAPI_Users_UserUploadFace kURL(@"/user/uploadface.php")
#define kAPI_Users_CheckSignalQuickly kURL(@"/stocksignal_quickly.php")
#define kAPI_Users_UserIsVip kURL(@"/user/isvip.php")
#define kAPI_Users_MessageList kURL(@"/user/mymessage.php")
#define kAPI_Users_SendMessage kURL(@"/user/sendmessage.php")
#define kAPI_Users_SessionUsers kURL(@"/user/sessionusers.php")
#define kAPI_Users_DeleteSessionUsers kURL(@"/user/delsessionuser.php")
#define kAPI_Users_AttentionUsers kURL(@"/user/attentionusers.php")
#define kAPI_Users_DeleteAttentionUsers kURL(@"/user/delattentionuser.php")
#define kAPI_Users_DeleteFansUsers kURL(@"/user/delfans.php")
#define kAPI_Users_UnReadCount kURL(@"/user/unread.php")
#define kAPI_Users_FansUserList kURL(@"/user/fanslist.php")
#define kAPI_Users_OtherLogin kURL(@"/user/otherlogin.php")
#define kAPI_Users_JoinMobile kURL(@"/user/joinmobile.php")
#define kAPI_Users_UserInfo kURL(@"/user/userinfo.php")
// 模拟交易
#define kAPI_Stocks_Simulator_Account kURL(@"/transaction/simulatoraccount.php")
#define kAPI_Stocks_Simulator_Repertory kURL(@"/transaction/simulatorrepertory.php")
#define kAPI_Stocks_Simulator_Entrust kURL(@"/transaction/simulatorentrusts.php")
#define kAPI_Stocks_Simulator_Clinchs kURL(@"/transaction/simulatorclinchs.php")
#define kAPI_Stocks_Simulator_Insert kURL(@"/transaction/simulatorinsert.php")
// 组合
#define kAPI_Stocks_Simulator_Group kURL(@"/transaction/simulatorgroup.php")
#define kAPI_Stocks_Simulator_GroupList kURL(@"/transaction/simulatorgrouplist.php")
#define kAPI_Stocks_Simulator_GroupDetail kURL(@"/transaction/simulatorgroupdetail.php")
#define kAPI_Stocks_Simulator_GroupChart kURL(@"/transaction/simulatorchart.php")
#define kAPI_Stocks_Simulator_GroupSub kURL(@"/transaction/simulatorgroupsub.php")
// 涨跌幅
#define kAPI_Stocks_IndexList kURL(@"/stockindexlist.php")
#define kAPI_Stocks_TradeUpDownList kURL(@"/tradeupdownlist.php")
#define kAPI_Stocks_UpDownList kURL(@"/updownlist.php")
// 牛人
#define kAPI_Teacher_TeacherList kURL(@"/teacher/teacherlist.php")
#define kAPI_Teacher_TeacherDetail kURL(@"/teacher/teacherdetail.php")
#define kAPI_Teacher_payAttention kURL(@"/teacher/attentionuser.php")
#define kAPI_Teacher_tradehistory kURL(@"/teacher/teachertradehistory.php")
// 自选股
#define kAPI_Stocks_SelfStocks kURL(@"/user/selfstock.php")
#define kAPI_Stocks_StockRemind kURL(@"/user/stockremind.php")
// 幻灯片
#define kAPI_FlashList kURL(@"/flash.php")
// 快捷按钮
#define kAPI_Shortcut kURL(@"/shortcut.php")
// 文章列表
#define kAPI_ArticleList kURL(@"/news/articlelist.php")
#define kAPI_NewsLive kURL(@"/news/newslive.php")
#define kAPI_ArticleContent kURL(@"/news/articlecontent.php")
#define kAPI_ArticleColumn kURL(@"/news/articlecolumn.php")
#define kAPI_ArticleColumnCacheKey @"kAPI_ArticleColumnCacheKey"  // 用来每次启动App保存最新的新闻栏目数据
// 活动
#define kAPI_ActivityList kURL(@"/news/activitylist.php")
// 搜索
#define kAPI_Search kURL(@"/search.php")
// 远程配置
#define kAPI_Config kURL(@"/config.php")
// 关于我们风险提示单页
#define kAPI_AboutUs kURL(@"/wap/singlepage.php?articleId=20434")
#define kAPI_DangerTip kURL(@"/wap/singlepage.php?articleId=20432")
// 广告
#define kAPI_StartAD kURL(@"/startad.php")
// 自定义指标接口
#define kAPI_StockSelfIndex kURL(@"/stockselfindex.php")
// 信号列表
#define kAPI_Celue kURL(@"/celue.php")
// 股票池列表
#define kAPI_Gupiaochi kURL(@"/gupiaochi.php")
// 策略平台列表
#define kAPI_TacticsList kURL(@"/tactics/tacticslist.php")
#define kAPI_TacticsDetail kURL(@"/tactics/tacticsdetail.php")
#define kAPI_TacticsStocks kURL(@"/tactics/tacticsstocks.php")
#define kAPI_EditTactics kURL(@"/tactics/edittactics.php")
#define kAPI_DeleteTactics kURL(@"/tactics/deltactics.php")
#define kAPI_DeleteTacticsStocks kURL(@"/tactics/deltacticstocks.php")
// 点赞 关注 评论
#define kAPI_Community_Like kURL(@"/community/like.php")
#define kAPI_Community_Attention kURL(@"/community/attention.php")
#define kAPI_Community_posts kURL(@"/community/posts.php")
#define kAPI_Community_addThemes kURL(@"/community/addtheme.php")
#define kAPI_Community_uploadThemePics kURL(@"/community/uploadthemepic.php")
#define kAPI_Community_ThemeList kURL(@"/community/themelist.php")
#define kAPI_Community_ThemeDetail kURL(@"/community/themedetail.php")
#define kAPI_Community_DeleteTheme kURL(@"/community/deltheme.php")
// 视频直播列表
#define kAPI_Video_List kURL(@"/video/videolist.php")
#define kAPI_Video_Detail kURL(@"/video/videodetail.php")
#define kAPI_Video_TeacherSayList kURL(@"/video/videoteachersaylist.php")

#endif
