//
//  HttpManager.m
//  FMStockChart
//
//  Created by dangfm on 15/8/19.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "HttpManager.h"
#import "FMCommon.h"

//  接口
#define fmHttpAPIKeyName @"fmHttpAPIKeyName"
#define fmHttpAPIServer @"fmHttpAPIKeyServer"
#define fmHttpAPI_StockDays fmURL(@"/stockdays.php")
#define fmHttpAPI_StockMinute fmURL(@"/stockminute.php")
#define fmHttpAPI_StockFiveDays fmURL(@"/stockfivedays.php")
#define fmHttpAPI_StockWeeks fmURL(@"/stockweeks.php")
#define fmHttpAPI_StockMonths fmURL(@"/stockmonths.php")
#define fmHttpAPI_StockNewData fmURL(@"/stocknewdata.php")
#define fmHttpAPI_StockMKline fmURL(@"/stockmkline.php")

@interface HttpManager(){
    
}

@end

@implementation HttpManager


+(void)config:(NSString *)key server:(NSString*)server userIdKey:(NSString*)userIdKey userIsPayKey:(NSString*)userIsPayKey{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:key forKey:fmHttpAPIKeyName];
    [ud setObject:server forKey:fmHttpAPIServer];
    [ud setObject:userIdKey forKey:fmUserIdKey];
    [ud setObject:userIsPayKey forKey:fmUserIsPayKey];
    [ud synchronize];
    ud = nil;
}

#pragma mark -
#pragma mark 初始化

+(instancetype)instance{
    HttpManager *manager = [[HttpManager alloc] init];
    return manager;
}

-(instancetype)init{
    if (self == [super init]) {
        [self initParams];
    }
    return self;
}

-(instancetype)initWithUrl:(NSString*)url{
    if (self == [super init]) {
        [self initParams];
        [self setUrl:url];
    }
    return self;
}

-(void)initParams{
    _httpMethod = fmHttpRequestMethod;
    _request = [NSMutableURLRequest new];
    [_request setHTTPMethod:_httpMethod];
    [_request setTimeoutInterval:fmHttpRequestTimeout];
    _postDatas = [NSMutableDictionary new];
    _server = [HttpManager server];
}

#pragma mark -
#pragma mark 自定义方法
+(NSString *)server{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *v = [ud valueForKey:fmHttpAPIServer];
    return v;
}
-(NSString*)getKey{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *key = [ud objectForKey:fmHttpAPIKeyName];
    if (!key || [key isEqual:[NSNull null]]) {
        key = @"";
    }
    [ud synchronize];
    ud = nil;
    return key;
}
+(NSString *)userId{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *v = [ud valueForKey:fmUserIdKey];
    v = [ud valueForKey:v];
    return v;
}
-(void)setUrl:(NSString*)url{
    NSString *urlStr = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [_request setURL:[NSURL URLWithString:urlStr]];
}

-(void)setPostValue:(id)value ForKey:(id)key{
    [_postDatas setObject:value forKey:key];
}

//  整合POST值
-(NSString*)stringWithPostData{
    NSString *appKey = [self getKey];
    NSString *str = @"";
    NSString *values = @"";
    NSString *userId = [HttpManager userId];
    if (userId==nil) {
        userId = @"";
    }
    NSArray *keys = _postDatas.allKeys;
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        NSComparisonResult result = [obj1 compare:obj2];
        return result==NSOrderedDescending;
    }];
    
    for (NSString *key in keys) {
        NSString *value = [_postDatas objectForKey:key];
        if (value && ![value isEqual:[NSNull null]]) {
            if ([str isEqualToString:@""]) {
                str = [NSString stringWithFormat:@"%@=%@",key,value];
            }else
                str = [str stringByAppendingFormat:@"&%@=%@",key,value];
            values = [values stringByAppendingString:value];
        }
    }
    long long time = [[NSDate date] timeIntervalSince1970]*1000;
    NSString *timeStr = [NSString stringWithFormat:@"%lld",time];
    str = [str stringByAppendingFormat:@"&userId=%@",userId];
    str = [str stringByAppendingFormat:@"&t=%@",timeStr];
    // token
    values = [values stringByAppendingString:userId];
    values = [values stringByAppendingString:timeStr];
    values = [values stringByAppendingString:appKey];
    
    
    NSString *token = [FMCommon md5:values];
    str = [str stringByAppendingFormat:@"&token=%@",token];
    return str;
}

//  开始请求并回调
-(void)sendStartBlock:(void(^)())startBlock
              Success:(void(^)(NSMutableDictionary *response,NSInteger statusCode))success
              Failure:(void(^)(NSError *error))failure{
    // 开始请求回调
    if (startBlock) {
        startBlock();
    }
    NSString *postValue = [self stringWithPostData];
    FMLog(@"%@?%@",_request.URL.absoluteString,postValue);
    [_request setHTTPBody:[postValue dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:_request
                                       queue:queue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                               // NSLog(@"%@",error);
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   if (error || !data || !response) {
                                       // 网络问题或者服务器问题
                                       if (failure) {
                                           failure(error);
                                       }
                                   }else{
                                       // 状态码
                                       NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
                                       // 返回数据
                                       NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
                                       if (responseCode==200 && json) {
                                           if (success) {
                                               success(json,responseCode);
                                           }
                                       }else{
                                           if (failure) {
                                               failure(error);
                                           }
                                       }
                                       
                                   }
                               });
                               
                           }];
}



#pragma mark -
#pragma mark 数据请求

+(void)getHttpStockMKlineWithCode:(NSString*)code
                           minute:(int)minute
                       StartBlock:(void(^)())startBlock
                          Success:(void(^)(NSMutableDictionary *response,NSInteger statusCode))success
                          Failure:(void(^)(NSError *error))failure{
    
    HttpManager *hm = [[HttpManager instance] initWithUrl:fmHttpAPI_StockMKline];
    [hm setPostValue:code ForKey:@"code"];
    [hm setPostValue:@(minute).stringValue ForKey:@"min"];
    [hm sendStartBlock:startBlock Success:success Failure:failure];
    hm = nil;
}

+(void)getHttpStockDaysWithCode:(NSString*)code
                     fuquanType:(NSString*)fuquanType
                     StartBlock:(void(^)())startBlock
                        Success:(void(^)(NSMutableDictionary *response,NSInteger statusCode))success
                        Failure:(void(^)(NSError *error))failure{
    
    HttpManager *hm = [[HttpManager instance] initWithUrl:fmHttpAPI_StockDays];
    [hm setPostValue:code ForKey:@"code"];
    [hm setPostValue:fuquanType ForKey:@"dr"];
    [hm sendStartBlock:startBlock Success:success Failure:failure];
    hm = nil;
}

+(void)getHttpStockWeeksWithCode:(NSString*)code
                      fuquanType:(NSString*)fuquanType
                      StartBlock:(void(^)())startBlock
                         Success:(void(^)(NSMutableDictionary *response,NSInteger statusCode))success
                         Failure:(void(^)(NSError *error))failure{
    
    HttpManager *hm = [[HttpManager instance] initWithUrl:fmHttpAPI_StockWeeks];
    [hm setPostValue:code ForKey:@"code"];
    [hm setPostValue:fuquanType ForKey:@"dr"];
    [hm sendStartBlock:startBlock Success:success Failure:failure];
    hm = nil;
}

+(void)getHttpStockMonthsWithCode:(NSString*)code
                       fuquanType:(NSString*)fuquanType
                       StartBlock:(void(^)())startBlock
                          Success:(void(^)(NSMutableDictionary *response,NSInteger statusCode))success
                          Failure:(void(^)(NSError *error))failure{
    
    HttpManager *hm = [[HttpManager instance] initWithUrl:fmHttpAPI_StockMonths];
    [hm setPostValue:code ForKey:@"code"];
    [hm setPostValue:fuquanType ForKey:@"dr"];
    [hm sendStartBlock:startBlock Success:success Failure:failure];
    hm = nil;
}

+(void)getHttpStockMinuteWithCode:(NSString*)code
                       StartBlock:(void(^)())startBlock
                          Success:(void(^)(NSMutableDictionary *response,NSInteger statusCode))success
                          Failure:(void(^)(NSError *error))failure{
    
    HttpManager *hm = [[HttpManager instance] initWithUrl:fmHttpAPI_StockMinute];
    [hm setPostValue:code ForKey:@"code"];
    [hm sendStartBlock:startBlock Success:success Failure:failure];
    hm = nil;
}

+(void)getHttpStockFiveDaysWithCode:(NSString*)code
                         StartBlock:(void(^)())startBlock
                            Success:(void(^)(NSMutableDictionary *response,NSInteger statusCode))success
                            Failure:(void(^)(NSError *error))failure{
    
    HttpManager *hm = [[HttpManager instance] initWithUrl:fmHttpAPI_StockFiveDays];
    [hm setPostValue:code ForKey:@"code"];
    [hm sendStartBlock:startBlock Success:success Failure:failure];
    hm = nil;
}

+(void)getHttpStockNewDataWithCode:(NSString*)code
                        StartBlock:(void(^)())startBlock
                           Success:(void(^)(NSMutableDictionary *response,NSInteger statusCode))success
                           Failure:(void(^)(NSError *error))failure{
    
    HttpManager *hm = [[HttpManager instance] initWithUrl:fmHttpAPI_StockNewData];
    [hm setPostValue:code ForKey:@"code"];
    [hm sendStartBlock:startBlock Success:success Failure:failure];
    hm = nil;
}
@end
