//
//  HttpManager.h
//  FMStockChart
//
//  Created by dangfm on 15/8/19.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMHeader.h"

@interface HttpManager : NSObject

@property (nonatomic,retain) NSMutableURLRequest *request;      // 请求
@property (nonatomic,retain) NSMutableDictionary *postDatas;    // 请求数据
@property (nonatomic,retain) NSString *httpMethod;              // 请求方式
@property (nonatomic,assign) NSTimeInterval timeout;            // 超时
@property (nonatomic,retain) NSString *server;                  // 请求服务器根地址

#pragma mark -
#pragma mark 配置
/**
 *  配置请求SDK key和跟地址
 *
 *  @param key    SDK key
 *  @param server 跟服务器地址
 *  @parma userIdKey  保存用户ID的键名
 */
+(void)config:(NSString *)key server:(NSString*)server userIdKey:(NSString*)userIdKey userIsPayKey:(NSString*)userIsPayKey;

#pragma mark -
#pragma mark 初始化
+(instancetype)instance;
-(instancetype)initWithUrl:(NSString*)url;
-(void)setUrl:(NSString*)url;
/**
 *  设置POST值
 *
 *  @param value 值
 *  @param key   字段
 */
-(void)setPostValue:(id)value ForKey:(id)key;

/**
 *  开始请求
 *
 *  @param startBlock 开始回调
 *  @param success    成功回调
 *  @param failure    失败回调
 */
-(void)sendStartBlock:(void(^)())startBlock
              Success:(void(^)(NSMutableDictionary *response,NSInteger statusCode))success
              Failure:(void(^)(NSError *error))failure;


#pragma mark -
#pragma mark 数据请求

/**
 *  获取分钟k线数据
 *
 *  @param code       股票代码
 *  @param minute     分钟周期 1，15，30，60
 */
+(void)getHttpStockMKlineWithCode:(NSString*)code
                           minute:(int)minute
                       StartBlock:(void(^)())startBlock
                          Success:(void(^)(NSMutableDictionary *response,NSInteger statusCode))success
                          Failure:(void(^)(NSError *error))failure;

/**
 *  日K数据
 *
 *  @param code       股票代码
 *  @param startBlock 开始回调
 *  @param success    成功回调
 *  @param failure    失败回调
 */
+(void)getHttpStockDaysWithCode:(NSString*)code
                     fuquanType:(NSString*)fuquanType
                     StartBlock:(void(^)())startBlock
                        Success:(void(^)(NSMutableDictionary *response,NSInteger statusCode))success
                        Failure:(void(^)(NSError *error))failure;

/**
 *  周K数据
 *
 *  @param code       股票代码
 *  @param startBlock 开始回调
 *  @param success    成功回调
 *  @param failure    失败回调
 */
+(void)getHttpStockWeeksWithCode:(NSString*)code
                      fuquanType:(NSString*)fuquanType
                      StartBlock:(void(^)())startBlock
                         Success:(void(^)(NSMutableDictionary *response,NSInteger statusCode))success
                         Failure:(void(^)(NSError *error))failure;

/**
 *  月K数据
 *
 *  @param code       股票代码
 *  @param startBlock 开始回调
 *  @param success    成功回调
 *  @param failure    失败回调
 */
+(void)getHttpStockMonthsWithCode:(NSString*)code
                       fuquanType:(NSString*)fuquanType
                       StartBlock:(void(^)())startBlock
                          Success:(void(^)(NSMutableDictionary *response,NSInteger statusCode))success
                          Failure:(void(^)(NSError *error))failure;

/**
 *  分时图数据
 *
 *  @param code       股票代码
 *  @param startBlock 开始回调
 *  @param success    成功回调
 *  @param failure    失败回调
 */
+(void)getHttpStockMinuteWithCode:(NSString*)code
                       StartBlock:(void(^)())startBlock
                          Success:(void(^)(NSMutableDictionary *response,NSInteger statusCode))success
                          Failure:(void(^)(NSError *error))failure;

/**
 *  五日行情
 *
 *  @param code       股票代码
 *  @param startBlock 开始回调
 *  @param success    成功回调
 *  @param failure    失败回调
 */
+(void)getHttpStockFiveDaysWithCode:(NSString*)code
                         StartBlock:(void(^)())startBlock
                            Success:(void(^)(NSMutableDictionary *response,NSInteger statusCode))success
                            Failure:(void(^)(NSError *error))failure;

/**
 *  股票当前行情
 *
 *  @param code       股票代码
 *  @param startBlock 开始回调
 *  @param success    成功回调
 *  @param failure    失败回调
 */
+(void)getHttpStockNewDataWithCode:(NSString*)code
                        StartBlock:(void(^)())startBlock
                           Success:(void(^)(NSMutableDictionary *response,NSInteger statusCode))success
                           Failure:(void(^)(NSError *error))failure;
@end
