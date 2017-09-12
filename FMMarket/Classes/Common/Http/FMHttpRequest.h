//
//  FMHttpRequest.h
//  FMMarket
//
//  Created by dangfm on 15/8/11.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^requestSuccessBlock)(NSDictionary* dic);

@interface FMHttpRequest : NSObject
#pragma mark - 网络状态
// 联网通知
+(void)checkInternetIsConnect;

//  从通知中心获取联网状态
+(AFNetworkReachabilityStatus)getNetStatusWithNotification:(NSNotification*)notification;

+(AFHTTPSessionManager*)requestManager;
#pragma mark - HTTP Request
//  检查是否更新搜索数据 
// +(void)isUpdateSearchStocks;

#pragma mark -
#pragma mark 股票行情接口

/**
 *  请求股票最新数据
 *
 *  @param codes      股票代码数组
 *  @param startBlock 开始回调
 *  @param failBlock  失败回调
 *  @param success    成功回调数据
 */
+(void)getStockWithCodes:(NSArray*)codes start:(void(^)())startBlock failure:(void(^)())failBlock success:(requestSuccessBlock)success;

/**
 *  获取股票详情信息接口
 *
 *  @param codes      股票代码
 *  @param startBlock 开始回调
 *  @param failBlock  失败回调
 *  @param success    成功回调
 */
+(void)getStockInfoWithCodes:(NSArray*)codes start:(void(^)())startBlock failure:(void(^)())failBlock success:(requestSuccessBlock)success;

/**
 *  获取股票资金流向接口
 *
 *  @param codes      股票代码
 *  @param startBlock 开始回调
 *  @param failBlock  失败回调
 *  @param success    成功回调
 */
+(void)getStockMainForceWithCodes:(NSArray*)codes start:(void(^)())startBlock failure:(void(^)())failBlock success:(requestSuccessBlock)success;

/**
 *  获取股票公司简介
 *
 *  @param code       股票代码
 *  @param startBlock 开始回调
 *  @param failBlock  失败回调
 *  @param success    成功回调
 */
+(void)getStockCompanyWithCode:(NSString*)code start:(void(^)())startBlock failure:(void(^)())failBlock success:(requestSuccessBlock)success;

/**
 *  股票利润表
 *
 *  @param code       股票代码
 *  @param startBlock 开始回调
 *  @param failBlock  失败回调
 *  @param success    成功回调
 */
+(void)getStockProfitsWithCode:(NSString*)code start:(void(^)())startBlock failure:(void(^)())failBlock success:(requestSuccessBlock)success;

/**
 *  获取行业资金流向
 *
 *  @param startBlock 开始回调
 *  @param failBlock  失败回调
 *  @param success    成功回调
 */
+(void)getStockCapitalWithStart:(void(^)())startBlock failure:(void(^)())failBlock success:(requestSuccessBlock)success;

/**
 *  检查股票是否出现信号
 *
 *  @param code       股票代码
 *  @param startBlock 开始回调
 *  @param failBlock  失败回调
 *  @param success    成功回调
 */
+(void)checkStockSignalWithCode:(NSString*)code start:(void(^)())startBlock failure:(void(^)())failBlock success:(requestSuccessBlock)success;

#pragma mark -
#pragma mark 涨跌幅
/**
 *  行情首页指数列表
 */
+(void)getStockIndexListWithStart:(void(^)())startBlock failure:(void(^)())failBlock success:(requestSuccessBlock)success;

/**
 *  行业涨跌幅列表
 *
 *  @param count      数量
 */
+(void)getTradeUpDownListWithCount:(int)count start:(void(^)())startBlock failure:(void(^)())failBlock success:(requestSuccessBlock)success;

/**
 *  个股涨跌幅列表
 *
 *  @param start      开始页码 默认为0
 *  @param count      每页大小
 *  @param typeCode   分组类型
 */
+(void)getUpDownListWithStart:(int)start count:(int)count typeCode:(NSString*)typeCode start:(void(^)())startBlock failure:(void(^)())failBlock success:(requestSuccessBlock)success;

/**
 *  请求板块涨幅列表
 *
 *  @param typeCode   板块代码
 */
+(void)getPlateUpDownListWithStart:(int)start count:(int)count typeCode:(NSString *)typeCode start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

#pragma mark -
#pragma mark 精灵选股

/**
 *  获取精灵选股列表
 *
 *  @param codes      股票代码
 *  @param startBlock 开始回调
 *  @param failBlock  失败回调
 *  @param success    成功回调
 */
+(void)getSelectStockListWithTypeCode:(NSString*)typeCode s:(int)start count:(int)count start:(void(^)())startBlock failure:(void(^)())failBlock success:(requestSuccessBlock)success;

#pragma mark -
#pragma mark 用户中心

/**
 *  发送短信验证码
 *
 *  @param tel        手机号
 *  @param startBlock 开始回调
 *  @param failBlock  失败回调
 *  @param success    成功回调
 */
+(void)sendSMSWithTel:(NSString*)tel start:(void(^)())startBlock failure:(void(^)())failBlock success:(requestSuccessBlock)success;

/**
 *  提交注册会员
 *
 *  @param tel        手机号码
 *  @param password   密码
 *  @param code       短信验证码
 *  @param startBlock 开始回调
 *  @param failBlock  失败回调
 *  @param success    成功回调
 */
+(void)sendUserRegisterWithTel:(NSString*)tel password:(NSString*)password code:(NSString*)code start:(void(^)())startBlock failure:(void(^)())failBlock success:(requestSuccessBlock)success;

/**
 *  用户登陆
 *
 *  @param tel        手机号码
 *  @param password   密码
 *  @param startBlock 开始回调
 *  @param failBlock  失败回调
 *  @param success    成功回调
 */
+(void)sendUserLoginWithTel:(NSString *)tel password:(NSString *)password start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

+(void)updateUserLoginWithTel:(NSString *)tel start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  第三方登录
 *
 *  @param qq_open_id
 *  @param qq_access_token
 *  @param weixin_open_id
 *  @param weixin_access_token
 */
+(void)sendOtherLoginWithQQOpenId:(NSString *)qq_open_id QQAccessToken:(NSString *)qq_access_token WeiXinOpenId:(NSString*)weixin_open_id WeiXinAccessToken:(NSString*)weixin_access_token start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  忘记密码
 *
 *  @param tel        手机号
 *  @param password   重置密码
 *  @param code       短信验证码
 *  @param startBlock 开始回调
 *  @param failBlock  失败回调
 *  @param success    成功回调
 */
+(void)sendChangePasswordWithTel:(NSString *)tel password:(NSString *)password code:(NSString *)code start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  意见反馈
 *
 *  @param email      邮箱
 *  @param content    内容
 *  @param startBlock 开始回调
 *  @param failBlock  失败回调
 *  @param success    成功回调
 */
+(void)sendFeedbackWithEmail:(NSString *)email content:(NSString *)content start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  编辑昵称
 *
 *  @param nickName   新昵称
 */
+(void)updateNickName:(NSString *)nickName start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  上传头像
 */
+(void)uploadUserFaceWithImage:(UIImage*)image start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;
/**
 *  检查用户是否有VIP权限
 *
 */
+(void)checkUserIsVipWithStart:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;
// 是否vip用户
+(void)checkHttpIsVipUser:(void (^)())startBlock finishBlock:(void (^)(bool isVIP))finishBlock;

/**
 *  私信列表
 *
 *  @param subUserId  对方UserId
 */
+(void)getMessageWithSubUserId:(NSString *)subUserId page:(int)page pageSize:(int)pageSize Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  发送私信
 *
 *  @param content    私信内容
 *  @param subUserId  私信对象
 */
+(void)sendMessageWithContent:(NSString *)content subUserId:(NSString *)subUserId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  获取我的会话用户列表
 *
 *  @param page       页码
 *  @param pageSize   每页大小
 */
+(void)getSessionUsersWithPage:(int)page pageSize:(int)pageSize Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  删除私信会话
 *
 *  @param sessionUserId 会话用户ID
 */
+(void)deleteSessionUserWithSessionUserId:(NSString *)sessionUserId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  获取关注用户列表
 *
 *  @param page       页码
 *  @param pageSize   每页大小
 */
+(void)getAttentionUsersWithPage:(int)page pageSize:(int)pageSize Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  删除关注的用户，删除会把关注此用户的信息全部删除
 *
 *  @param attentionUserId 关注用户ID
 */
+(void)deleteAttentionUserWithAttentionUserId:(NSString *)attentionUserId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  删除粉丝
 *
 *  @param fansUserId 粉丝用户ID
 */
+(void)deleteFansUserWithFansUserId:(NSString *)fansUserId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  未读消息总数
 *
 *  @param fromUserId 来自某用户的未读消息总数，默认是所有未读消息总数
 */
+(void)getUsersUnReadCountWithFromUserId:(NSString*)fromUserId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  获取我的粉丝用户列表
 *
 *  @param page       页码
 *  @param pageSize   每页大小
 */
+(void)getFansUserListWithPage:(int)page pageSize:(int)pageSize Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  绑定用户手机号
 *
 *  @param tel        手机号码
 *  @param password   密码
 *  @param code       验证码
 */
+(void)sendJoinMobileWithTel:(NSString*)tel password:(NSString*)password code:(NSString*)code Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  获取用户资料
 *
 */
+(void)getUserInfoWithStart:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;
#pragma mark -
#pragma mark 模拟交易
/**
 *  获取模拟交易账户信息
 *
 *  @param startBlock 开始回调
 *  @param failBlock  失败回调
 *  @param success    成功回调
 */
+(void)getSimulatorAccountWithTeacherId:(NSString*)teacherId groupId:(NSString*)groupId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  获取模拟交易持仓列表
 *
 *  @param startBlock 开始回调
 *  @param failBlock  失败回调
 *  @param success    成功回调
 */
+(void)getSimulatorRepertoryWithTeacherId:(NSString*)teacherId page:(int)page pageSize:(int)pageSize groupId:(NSString*)groupId start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  获取委托列表
 *
 *  @param isToday    是否是今天还是历史 1=今天
 *  @param isClinch   是否是已成交还是正在委托 1=成交
 *  @param history    是否查询所有历史
 *  @param startBlock 开始回调
 *  @param failBlock  失败回调
 *  @param success    成功回调
 */
+(void)getSimulatorEntrustsWithIsToday:(BOOL)isToday teacherId:(NSString*)teacherId groupId:(NSString*)groupId isClinch:(BOOL)isClinch history:(BOOL)isHistory page:(int)page pageSize:(int)pageSize start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  获取交易列表
 *
 *  @param isToday    是否是今天的
 *  @param startBlock 开始回调
 *  @param failBlock  失败回调
 *  @param success    成功回调
 */
+(void)getSimulatorClinchsWithIsToday:(BOOL)isToday teacherId:(NSString*)teacherId groupId:(NSString*)groupId page:(int)page pageSize:(int)pageSize start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  添加删除委托
 *
 *  @param code       股票代码
 *  @param price      委托价格
 *  @param direction  买卖方向 0＝buy 1=sell
 *  @param entrustId  委托Id 删除时候用到
 *  @param action     委托操作 add=添加 del=删除
 *  @param startBlock 开始回调
 *  @param failBlock  失败回调
 *  @param success    成功回调
 */
+(void)sendSimulatorEntrustWithCode:(NSString*)code price:(NSString*)price amount:(NSString*)amount  direction:(int)direction entrustId:(NSString*)entrustId groupId:(NSString*)groupId action:(NSString*)action start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

#pragma mark - 组合
/**
 *  获取组合列表
 *
 *  @param isPay      是否付费组合 -1=所有 0=免费 1＝收费
 *  @param type       组合类型 type＝sub 订阅
 *  @param orderField 排序字段，默认0=时间排序
 *  @param orderType  排序类型 desc和asc 默认desc
 *  @param page       页码
 *  @param pageSize   每页大小
 */
+(void)getSimulatorGroupListWithIsPay:(int)isPay type:(NSString*)type orderField:(int)orderField orderType:(NSString*)orderType page:(int)page pageSize:(int)pageSize start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  获取组合详情
 *
 *  @param groupId    组合ID
 */
+(void)getSimulatorGroupDetailWithGroupId:(NSString*)groupId start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  获取组合净值列表
 *
 *  @param groupId    组合ID
 */
+(void)getSimulatorChartWithGroupId:(NSString*)groupId teacherId:(NSString*)teacherId start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  添加删除组合
 *
 *  @param groups     组合数据集合
 */
+(void)setSimulatorGroupWithGroups:(NSDictionary*)groups start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  组合订阅
 *
 *  @param groupId    组合ID
 */
+(void)getSimulatorGroupSubWithGroupId:(NSString*)groupId start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;
#pragma mark -
#pragma mark 牛人

/**
 *  牛人列表
 *
 *  @param page       页码
 *  @param pageSize   每页大小
 *  @param type       列表类型 myattention＝我关注的牛人列表 order＝收益排序 空默认最新买入排序
 */
+(void)getTeacherListWithSize:(int)page pageSize:(int)pageSize type:(NSString*)type  Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  牛人详情
 *
 *  @param teacherId  牛人Id
 */
+(void)getTeacherDetailWithTeacherId:(NSString *)teacherId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  关注牛人
 *
 *  @param teacherId  牛人ID
 */
+(void)postTeacherAttentionWithTeacherId:(NSString *)teacherId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  获取牛人的历史交易列表
 *
 *  @param teacherId  牛人ID
 *  @param page       页码
 *  @param pageSize   每页大小
 */
+(void)getTeacherHistoryTradeWithTeacherId:(NSString*)teacherId page:(int)page pageSize:(int)pageSize start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

#pragma mark -
#pragma mark 自选股
/**
 *  自选股
 *
 *  @param action     操作类型 a=添加 d=删除 u=更新 s=查询
 *  @param codes      股票代码 多个代码逗号分割
 */
+(void)getSelfStocksWithAction:(NSString *)action codes:(NSString*)codes Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  提交股价提醒
 *
 *  @param code            股票代码
 *  @param upToPrice       股价涨到
 *  @param downToPrice     股价跌倒
 *  @param upRateToValue   日涨幅
 *  @param downRateToValue 日跌幅
 */
+(void)sendSelfStockRmindWithCode:(NSString *)code
                        upToPrice:(NSString*)upToPrice
                      downToPrice:(NSString*)downToPrice
                    upRateToValue:(NSString*)upRateToValue
                  downRateToValue:(NSString*)downRateToValue
                            Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  查询股价提醒
 *
 *  @param code       股票代码
 */
+(void)getSelfStockRemindInfoWithCode:(NSString*)code Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

#pragma mark -
#pragma mark 首页幻灯片快捷按钮
/**
 *  请求幻灯片列表
 */
+(void)getFlashListWithStart:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  请求快捷按钮
 */
+(void)getShortcutWithStart:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

#pragma mark -
#pragma mark 新闻资讯

/**
 *  请求文章列表
 *
 *  @param page       页码 默认1
 *  @param pageSize   每页大小 默认20
 *  @param typeCode   文章类型编码 例如：main＝要闻
 */
+(void)getArticleListWithPage:(int)page pageSize:(int)pageSize typeCode:(NSString*)typeCode withStart:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  请求7*24小时文字直播接口
 *
 *  @param page       页码
 *  @param pageSize   每页大小
 *  @param typeCode   直播类型
 */
+(void)getNewsLiveListWithPage:(int)page pageSize:(int)pageSize typeCode:(NSString*)typeCode withStart:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  请求新闻分类列表
 *  每次App启动调用一次
 */
+(void)getArticleColumnListWithStart:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  请求活动列表
 *
 *  @param page       页码
 *  @param pageSize   每页大小
 */
+(void)getActivityListWithPage:(int)page pageSize:(int)pageSize withStart:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;
#pragma mark -
#pragma mark 搜索股票
/**
 *  搜索股票
 *
 *  @param key        股票关键词，拼音或者代码
 */
+(void)getSearchStocksListWithKey:(NSString*)key start:(void (^)())startBlock
                         failure:(void (^)())failBlock
                         success:(requestSuccessBlock)success;
#pragma mark -
#pragma mark 远程配置
+(void)getServerConfig;

#pragma mark -
#pragma mark 下载启动图广告
+(void)getStartAd;

#pragma mark - 自定义指标
/**
 *  请求自定义指标数据
 *
 *  @param code       股票代码
 *  @param indexCode  指标类型代码  如 buySell 买卖点指标
 *  @param type       图表类型 0=主图 1=副图
 */
+(void)getStockSelfIndexWithCode:(NSString*)code indexCode:(NSString*)indexCode type:(int)type page:(int)page pageSize:(int)pageSize  withStart:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;


#pragma mark - 信号列表
/**
 *  获取信号列表
 */
+(void)getCelueListWithStart:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

#pragma mark - 股票池列表

+(void)getGupiaochiListWithPage:(int)page pageSize:(int)pageSize Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

#pragma mark - 策略平台列表

/**
 *  获取策略平台列表
 *
 *  @param tacticsUserId 策略所属用户ID，查看某个用户的策略列表
 *  @param type          请求的类型，myattention 我关注的策略列表，此时tacticsUserId应为空
 *  @param page          页码
 *  @param pageSize      每页大小
 */
+(void)getTacticsListWithTacticsUserId:(NSString*)tacticsUserId type:(NSString*)type  page:(int)page pageSize:(int)pageSize Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  策略详情
 *
 *  @param tacticsId  策略ID
 */
+(void)getTacticsDetailWithTacticsId:(NSString*)tacticsId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  策略个股列表详情
 *
 *  @param tacticsId  策略ID
 */
+(void)getTacticsStocksWithTacticsId:(NSString*)tacticsId page:(int)page pageSize:(int)pageSize Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  添加编辑策略
 *
 *  @param tacticsId  策略ID，编辑的时候要传
 *  @param title      策略标题
 *  @param intro      策略简介
 *  @param stocks     策略个股列表 @[@"code":"股票代码",@"name":"股票名称",@"intro":"入选理由",@"id":"如果有"]
 */
+(void)sendTacticsWithTacticsId:(NSString *)tacticsId title:(NSString *)title intro:(NSString *)intro stocks:(NSArray*)stocks Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  删除策略股票
 *
 *  @param tacticsId  策略ID
 *  @param code       股票代码
 */
+(void)deleteTacticsStocksWithTacticsId:(NSString *)tacticsId code:(NSString *)code Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  删除策略
 *
 *  @param tacticsId  策略ID
 */
+(void)deleteTacticsWithTacticsId:(NSString *)tacticsId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

#define mark - 点赞，评论，关注
/**
 *  点赞
 *
 *  @param objectId  对象ID  对象@ID 格式 例如 fm_member@987
 */
+(void)setCommunityLikeWithObjectId:(NSString*)objectId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  关注
 *
 *  @param objectId  对象ID  对象@ID 格式 例如 fm_member@987
 */
+(void)setCommunityAttentionWithObjectId:(NSString*)objectId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  发布评论操作接口
 *
 *  @param objectId   评论对象ID
 *  @param action     操作方式 add 添加评论 del 删除评论 list 取列表
 *  @param content    评论内容
 *  @param postId     回复评论ID
 */
+(void)sendCommunityPostsWithObjectId:(NSString*)objectId content:(NSString*)content postId:(NSString*)postId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  评论列表接口
 *
 *  @param objectId   对象ID
 *  @param page       页码
 *  @param pageSize   每页大小
 */
+(void)getCommunityPostsListWithObjectId:(NSString *)objectId page:(int)page pageSize:(int)pageSize Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  发表话题接口
 *
 *  @param themeId    话题ID，如果转发的话
 *  @param pics       图片，多个图片地址逗号分割
 *  @param content    内容
 */
+(void)sendCommunityThemeWithThemeId:(NSString *)themeId pics:(NSString*)pics content:(NSString*)content Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  上传话题图片
 *
 *  @param image      单个图片对象
 */
+(void)uploadCommunityThemePicsWithImage:(UIImage*)image start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  获取话题列表
 *
 *  @param themeUserId 话题用户ID
 *  @param type        话题类型 请求类型，比如 myAttention 我关注的话题
 *  @param page        页码
 *  @param pageSize    每页大小
 */
+(void)getCommunityThemeListWithThemeUserId:(NSString*)themeUserId type:(NSString*)type page:(int)page pageSize:(int)pageSize Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  话题详情接口
 *
 *  @param themeId    话题ID
 */
+(void)getCommunityDetailWithThemeId:(NSString*)themeId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  删除话题
 *  删除话题需要用户登录，并且只能删除自己的话题
 *  @param themeId    话题ID
 */
+(void)deleteCommunityWithThemeId:(NSString*)themeId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

#pragma mark - 视频直播
/**
 *  请求视频直播列表
 *
 *  @param page       页码
 *  @param pageSize   每页大小
 */
+(void)getVideoListWithPage:(int)page pageSize:(int)pageSize withStart:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  视频详情接口
 *
 *  @param videoId    视频ID
 */
+(void)getVideoDetailWithVideoId:(NSString*)videoId withStart:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;

/**
 *  获取视频直播老师观点列表
 *
 *  @param videoId    视频直播室ID
 */
+(void)getVideoTeacherSayListWithVideoId:(NSString*)videoId page:(int)page pageSize:(int)pageSize withStart:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success;
@end
