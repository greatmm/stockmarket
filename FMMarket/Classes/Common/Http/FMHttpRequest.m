//
//  FMHttpRequest.m
//  FMMarket
//
//  Created by dangfm on 15/8/11.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

#import "FMHttpRequest.h"


@implementation FMHttpRequest

#pragma mark - 网络状态
// 联网通知
+(void)checkInternetIsConnect{
    NSURL *baseURL = [NSURL URLWithString:@"http://www.baidu.com/"];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    
    NSOperationQueue *operationQueue = manager.operationQueue;
    [manager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 发送联网改变通知
        [[NSNotificationCenter defaultCenter]
         postNotificationName:kFMReachabilityChangedNotification object:[NSNumber numberWithInt:status]];
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
                
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                
                [operationQueue setSuspended:NO];
                break;
            case AFNetworkReachabilityStatusNotReachable:
            default:
                [operationQueue setSuspended:YES];
                break;
        }
        // 设置网络状态
        [FMUserDefault setInternetStatus:status];
    }];
    
    [manager.reachabilityManager startMonitoring];
}
//  从通知中心获取联网状态
+(AFNetworkReachabilityStatus)getNetStatusWithNotification:(NSNotification*)notification{
    AFNetworkReachabilityStatus status = [[notification object] intValue];
    return status;
}
//  加密参数
+(NSDictionary*)hashWithParams:(NSDictionary*)params{
    NSMutableDictionary *newParams = [NSMutableDictionary new];
    NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithDictionary:params];
    NSString *deviceId = [JPUSHService registrationID];
    NSString *deviceToken = [FMUserDefault getDeviceToken];
    if (!deviceToken) {
        deviceToken = @"";
    }
    if (!deviceId) {
        deviceId = @"";
    }
    [newDic setObject:[fn getVersion] forKey:@"v"];
    [newDic setObject:[FMUserDefault getUserId] forKey:@"userId"];
    [newDic setObject:deviceToken forKey:@"deviceToken"];
    [newDic setObject:kDeviceType forKey:@"deviceType"];
    [newDic setObject:deviceId forKey:@"deviceId"];
    NSArray *keys = newDic.allKeys;
    keys = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        NSComparisonResult result = [obj1 compare:obj2];
        return result==NSOrderedDescending;
    }];
    
    NSString *time = [NSString stringWithFormat:@"%.f",[fn getTimestamp]];
    NSString *hashStr = @"";
    NSString *paramStr = @"";
    for (NSString *key in keys) {
        id value = [newDic objectForKey:key];
        if (value && ![value isEqual:[NSNull null]]) {
            hashStr = [hashStr stringByAppendingString:[NSString stringWithFormat:@"%@",value]];
            if ([paramStr isEqualToString:@""]) {
                paramStr = [NSString stringWithFormat:@"?%@=%@",key,value];
            }else{
                paramStr = [NSString stringWithFormat:@"%@&%@=%@",paramStr,key,value];
            }
            [newParams setObject:value forKey:key];
        }
        
    }
    
    //    hashStr = [hashStr stringByAppendingString:[NSString stringWithFormat:@"%@",[fn getVersion]]];
    //    hashStr = [hashStr stringByAppendingString:[NSString stringWithFormat:@"%@",[FMUserDefault getUserId]]];
    hashStr = [hashStr stringByAppendingString:[NSString stringWithFormat:@"%@",time]];
    hashStr = [hashStr stringByAppendingString:[NSString stringWithFormat:@"%@",kAPI_Key]];
    
    
    // 加密
    NSString *auth = [fn md5:hashStr];
    //NSLog(@"%@=%@",hashStr,auth);
    
    [newParams setObject:time forKey:@"t"];
    [newParams setObject:auth forKey:@"token"];
    
    paramStr = [NSString stringWithFormat:@"%@&%@=%@",paramStr,@"t",time];
    paramStr = [NSString stringWithFormat:@"%@&%@=%@",paramStr,@"token",auth];
    NSLog(@"%@",paramStr);
    return newParams;
}

// 被迫下线
+(void)mustLogoutWithResult:(NSDictionary*)dic{
    if ([[FMUserDefault getUserId]floatValue]>0) {
        if ([[dic class]isSubclassOfClass:[NSDictionary class]]) {
            NSString *error = [NSString stringWithFormat:@"%@",dic[@"error"]];
            if ([[error class]isSubclassOfClass:[NSString class]]) {
                if ([error intValue]==kMustLogoutErrorCode) {
                    // 被迫退出登录
                    [FMUserDefault loginOut];
                    [fn showMessage:@"您已被下线" Title:@"温馨提示" timeout:3];
                }
            }
        }
    }
    
}

#pragma mark - HTTP Request

+(AFHTTPSessionManager*)request:(NSString*)url{
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    AFHTTPSessionManager *op = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
    op.responseSerializer = [AFHTTPResponseSerializer serializer];
    return op;
}
+(AFHTTPSessionManager*)requestManager{
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] init];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",@"text/plain",nil];
//    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//    manager.requestSerializer.stringEncoding = gbkEncoding;
    manager.requestSerializer.timeoutInterval = 30;
    
    
    return manager;
}

//  从网络请求最新的股票搜索数据 并更新本地数据库
//+(void)getInitSearchStocksWithVersion:(NSString*)version{
//    NSURLSessionTask *op = [self request:kAPI_SearchStocks];
//    [op setCompletionBlockWithprogress:nil
//         success:^(NSURLSessionTask *operation, id responseObject) {
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//            // 保存本地
//            NSArray *list = [str componentsSeparatedByString:@"\r\n"];
//            //DDLogDebug(@"%@",list);
//            // 清除本地旧信息
//            [db clearTable:[FMStocksModel class]];
//            NSInteger count = list.count;
//            NSLog(@"update stocks start");
//            for (NSString *item in list) {
//                NSArray *rows = [item componentsSeparatedByString:@" "];
//                if (rows.count>1) {
//                    NSString *name = [rows firstObject];
//                    NSString *pinyin = [fn pinyin:name];
//                    if (pinyin) {
//                        pinyin = pinyin.lowercaseString;
//                    }
//                    NSString *code = [rows objectAtIndex:1];
//                    
//                    NSString *type = [rows lastObject];
//                    if (![name isEqualToString:@""] && ![code isEqualToString:@""]) {
//                        // 入库
//                        //                        FMStocksModel *m = [[FMStocksModel alloc] init];
//                        //                        m.name = name;
//                        //                        m.pinyin = pinyin;
//                        //                        m.code = code;
//                        NSString *s = [NSString stringWithFormat:@"%@|%@|%@|%@",code,pinyin,name,type];
//                        [[FMAppDelegate shareApp].stocks addObject:s];
//                        s = nil;
//                        //[db insert:m FinishBlock:^(bool issuccess){}];
//                        //m = nil;
//                        
//                        // 发送通知
//                        //                        [[NSNotificationCenter defaultCenter] postNotificationName:kFMStartUpdateSearchDatabaseNotification object:nil];
//                        if ([list indexOfObject:item]==count-2) {
//                            // 更新完成
//                            [FMUserDefault setSearchStocksVersion:version];
//                            NSLog(@"update stocks finished");
//                            [[NSNotificationCenter defaultCenter] postNotificationName:kFMEndUpdateSearchDatabaseNotification object:nil];
//                            // 写入缓存
//                            [FMUserDefault setSearchStocks:[FMAppDelegate shareApp].stocks];
//                        }
//                        
//                        
//                    }
//                    name = nil;
//                    code = nil;
//                }
//                // sleep(0.1);
//                rows = nil;
//            }
//            list = nil;
//        });
//        
//    } failure:^(NSURLSessionTask *operation, NSError *error) {
//        
//    }];
//    [[NSOperationQueue mainQueue] addOperation:op];
//}

//  检查是否更新搜索数据
//+(void)isUpdateSearchStocks{
//    WEAKSELF
//    // 加载缓存
//    [[FMAppDelegate shareApp].stocks addObjectsFromArray:[FMUserDefault getSearchStocks]];
//    // 检查更新
//    AFHTTPSessionManager *manager = [self requestManager];
//    [manager GET:kAPI_SearchStocks_IsUpdate
//      parameters:[self hashWithParams:nil]
//         progress:nil
//         success:^(NSURLSessionTask *operation,id responseObj){
//             NSDictionary *dic = (NSDictionary*)responseObj;
//             NSString *data = [dic objectForKey:@"data"];
//             //NSInteger count = [db getCount:[FMStocksModel class]];
//             NSString *localVersion = [FMUserDefault getSearchStocksVersion];
//             if (![data isEqualToString:localVersion] ||
//                 [FMAppDelegate shareApp].stocks.count<=0) {
//                 // 更新
//                 [__weakSelf getInitSearchStocksWithVersion:data];
//             }
//             dic = nil;
//             data = nil;
//             
//         }
//         failure:^(NSURLSessionTask* operation,NSError *error){
//             
//         }];
//}



#pragma mark -
#pragma mark 请求股票接口

+(void)getStockWithCodes:(NSArray*)codes start:(void(^)())startBlock failure:(void(^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    NSString *codeStr = [codes componentsJoinedByString:@","];
    // 开始请求
    startBlock();
    
    [manager GET:kAPI_Stocks_NewData
      parameters:[self hashWithParams:@{@"code":codeStr}]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *dic = (NSDictionary*)responseObj;
             NSArray *data = [dic objectForKey:@"data"];
             if ([[data class] isSubclassOfClass:[NSArray class]]) {
                 // 回调数据
                 success([NSDictionary dictionaryWithObject:data forKey:@"data"]);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)getStockInfoWithCodes:(NSArray*)codes start:(void(^)())startBlock failure:(void(^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    NSString *codeStr = [codes componentsJoinedByString:@","];
    // 开始请求
    startBlock();
    [manager GET:kAPI_Stocks_Info
      parameters:[self hashWithParams:@{@"code":codeStr}]
        progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *dic = (NSDictionary*)responseObj;
             if ([[dic class] isSubclassOfClass:[NSDictionary class]]) {
                 // 回调数据
                 success(dic);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
    // NSLog(@"%@",manager.requestSerializer.JSONRepresentation);
}

+(void)getStockMainForceWithCodes:(NSArray*)codes start:(void(^)())startBlock failure:(void(^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    NSString *codeStr = [codes componentsJoinedByString:@","];
    // 开始请求
    startBlock();
    [manager GET:kAPI_Stocks_MainForce
      parameters:[self hashWithParams:@{@"code":codeStr}]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *dic = (NSDictionary*)responseObj;
             NSArray *data = [dic objectForKey:@"data"];
             if ([[data class] isSubclassOfClass:[NSArray class]]) {
                 // 回调数据
                 success([NSDictionary dictionaryWithObject:data forKey:@"data"]);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)getStockCompanyWithCode:(NSString*)code start:(void(^)())startBlock failure:(void(^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager GET:kAPI_Stocks_StockCompany
      parameters:[self hashWithParams:@{@"code":code}]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *dic = (NSDictionary*)responseObj;
             NSDictionary *data = [dic objectForKey:@"data"];
             if ([[data class] isSubclassOfClass:[NSDictionary class]]) {
                 // 回调数据
                 success([NSDictionary dictionaryWithObject:data forKey:@"data"]);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)getStockProfitsWithCode:(NSString *)code start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager GET:kAPI_Stocks_StockProfits
      parameters:[self hashWithParams:@{@"code":code}]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *dic = (NSDictionary*)responseObj;
             NSDictionary *data = [dic objectForKey:@"data"];
             if ([[data class] isSubclassOfClass:[NSDictionary class]]) {
                 // 回调数据
                 success([NSDictionary dictionaryWithObject:data forKey:@"data"]);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)getStockCapitalWithStart:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager GET:kAPI_Stocks_StockCapital
      parameters:[self hashWithParams:nil]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *dic = (NSDictionary*)responseObj;
             NSArray *data = [dic objectForKey:@"data"];
             if ([[data class] isSubclassOfClass:[NSArray class]]) {
                 // 回调数据
                 success([NSDictionary dictionaryWithObject:data forKey:@"data"]);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)checkStockSignalWithCode:(NSString *)code start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager GET:kAPI_Users_CheckSignalQuickly
      parameters:[self hashWithParams:@{@"code":code}]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *dic = (NSDictionary*)responseObj;
             if ([[dic class] isSubclassOfClass:[NSDictionary class]]) {
                 // 回调数据
                 success(dic);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

#pragma mark -
#pragma mark 涨跌幅

+(void)getStockIndexListWithStart:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager GET:kAPI_Stocks_IndexList
      parameters:[self hashWithParams:nil]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *dic = (NSDictionary*)responseObj;
             if ([[dic class] isSubclassOfClass:[NSDictionary class]] && dic) {
                 // 回调数据
                 success(dic);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)getTradeUpDownListWithCount:(int)count start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager GET:kAPI_Stocks_TradeUpDownList
      parameters:[self hashWithParams:@{@"count":[NSString stringWithFormat:@"%d",count]}]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *dic = (NSDictionary*)responseObj;
             if ([[dic class] isSubclassOfClass:[NSDictionary class]] && dic) {
                 // 回调数据
                 success(dic);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)getUpDownListWithStart:(int)start count:(int)count typeCode:(NSString *)typeCode start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager GET:kAPI_Stocks_UpDownList
      parameters:[self hashWithParams:@{
                                        @"count":[NSString stringWithFormat:@"%d",count],
                                        @"start":[NSString stringWithFormat:@"%d",start],
                                        @"typeCode":(typeCode==nil?@"":typeCode)
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *dic = (NSDictionary*)responseObj;
             if ([[dic class] isSubclassOfClass:[NSDictionary class]] && dic) {
                 // 回调数据
                 success(dic);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)getPlateUpDownListWithStart:(int)start count:(int)count typeCode:(NSString *)typeCode start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager GET:kAPI_Stocks_TradeUpDownList
      parameters:[self hashWithParams:@{
                                        @"count":[NSString stringWithFormat:@"%d",count],
                                        @"start":[NSString stringWithFormat:@"%d",start],
                                        @"typeCode":(typeCode==nil?@"":typeCode)
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *dic = (NSDictionary*)responseObj;
             if ([[dic class] isSubclassOfClass:[NSDictionary class]] && dic) {
                 // 回调数据
                 success(dic);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}


#pragma mark -
#pragma mark 精灵选股

+(void)getSelectStockListWithTypeCode:(NSString *)typeCode s:(int)start count:(int)count start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager GET:kAPI_Stocks_SelectStocks
      parameters:[self hashWithParams:@{@"type_code":typeCode,@"start":[NSString stringWithFormat:@"%d",start],@"count":[NSString stringWithFormat:@"%d",count]}]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *dic = (NSDictionary*)responseObj;
            
             if ([[dic class] isSubclassOfClass:[NSDictionary class]] && dic) {
                 // 回调数据
                 success(dic);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

#pragma mark -
#pragma mark 用户中心

+(void)sendSMSWithTel:(NSString *)tel start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager POST:kAPI_Users_UserSendSMS
      parameters:[self hashWithParams:@{@"tel":tel}]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *dic = (NSDictionary*)responseObj;
             if ([[dic class] isSubclassOfClass:[NSDictionary class]]) {
                 // 回调数据
                 success(dic);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)sendUserRegisterWithTel:(NSString *)tel password:(NSString *)password code:(NSString *)code start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager POST:kAPI_Users_UserRegister
      parameters:[self hashWithParams:@{
                                        @"tel":tel,
                                        @"password":password,
                                        @"code":code,
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *dic = (NSDictionary*)responseObj;
             if ([[dic class] isSubclassOfClass:[NSDictionary class]]) {
                 // 回调数据
                 success(dic);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)sendUserLoginWithTel:(NSString *)tel password:(NSString *)password start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager POST:kAPI_Users_UserLogin
       parameters:[self hashWithParams:@{
                                         @"tel":tel,
                                         @"password":password,
                                         }]
          progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL); NSDictionary *dic = (NSDictionary*)responseObj;
              if ([[dic class] isSubclassOfClass:[NSDictionary class]]) {
                  // 回调数据
                  success(dic);
              }else{
                  failBlock();
              }
              [http mustLogoutWithResult:responseObj];
          }
          failure:^(NSURLSessionTask* operation,NSError *error){
              failBlock();
          }];
}

+(void)sendOtherLoginWithQQOpenId:(NSString *)qq_open_id QQAccessToken:(NSString *)qq_access_token WeiXinOpenId:(NSString*)weixin_open_id WeiXinAccessToken:(NSString*)weixin_access_token start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    
    if (!qq_open_id) {
        qq_open_id = @"";
    }
    if (!qq_access_token) {
        qq_access_token = @"";
    }
    if (!weixin_open_id) {
        weixin_open_id = @"";
    }
    if (!weixin_access_token) {
        weixin_access_token = @"";
    }
    
    NSString*nickName = [FMUserDefault getNickName];
    if (!nickName) {
        nickName = @"";
    }
    NSString*userFace = [FMUserDefault getUserFace];
    if (!userFace) {
        userFace = @"";
    }
    
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager POST:kAPI_Users_OtherLogin
       parameters:[self hashWithParams:@{
                                         @"nickName":nickName,
                                         @"userFace":userFace,
                                         @"qq_open_id":qq_open_id,
                                         @"qq_access_token":qq_access_token,
                                         @"weixin_open_id":weixin_open_id,
                                         @"weixin_access_token":weixin_access_token,
                                         }]
          progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL); NSDictionary *dic = (NSDictionary*)responseObj;
              if ([[dic class] isSubclassOfClass:[NSDictionary class]]) {
                  // 回调数据
                  success(dic);
              }else{
                  failBlock();
              }
              [http mustLogoutWithResult:responseObj];
          }
          failure:^(NSURLSessionTask* operation,NSError *error){
              failBlock();
          }];
}

+(void)updateUserLoginWithTel:(NSString *)tel start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager POST:kAPI_Users_UserLogin
       parameters:[self hashWithParams:@{
                                         @"tel":tel
                                         }]
          progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL); NSDictionary *dic = (NSDictionary*)responseObj;
              if ([[dic class] isSubclassOfClass:[NSDictionary class]]) {
                  // 回调数据
                  success(dic);
              }else{
                  failBlock();
              }
              [http mustLogoutWithResult:responseObj];
          }
          failure:^(NSURLSessionTask* operation,NSError *error){
              failBlock();
          }];
}

+(void)sendChangePasswordWithTel:(NSString *)tel password:(NSString *)password code:(NSString *)code start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager POST:kAPI_Users_UserForgetPassword
       parameters:[self hashWithParams:@{
                                         @"tel":tel,
                                         @"password":password,
                                         @"code":code
                                         }]
          progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL); NSDictionary *dic = (NSDictionary*)responseObj;
              if ([[dic class] isSubclassOfClass:[NSDictionary class]]) {
                  // 回调数据
                  success(dic);
              }else{
                  failBlock();
              }
              [http mustLogoutWithResult:responseObj];
          }
          failure:^(NSURLSessionTask* operation,NSError *error){
              failBlock();
          }];
}

+(void)sendFeedbackWithEmail:(NSString *)email content:(NSString *)content start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager POST:kAPI_Users_UserFeedbacks
       parameters:[self hashWithParams:@{
                                         @"content":content,
                                         @"email":email
                                         }]
          progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL); NSDictionary *dic = (NSDictionary*)responseObj;
              if ([[dic class] isSubclassOfClass:[NSDictionary class]]) {
                  // 回调数据
                  success(dic);
              }else{
                  failBlock();
              }
              [http mustLogoutWithResult:responseObj];
          }
          failure:^(NSURLSessionTask* operation,NSError *error){
              failBlock();
          }];
}


+(void)updateNickName:(NSString *)nickName start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager POST:kAPI_Users_UserNickName
       parameters:[self hashWithParams:@{
                                         @"nickName":nickName
                                         }]
          progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL); NSDictionary *dic = (NSDictionary*)responseObj;
              if ([[dic class] isSubclassOfClass:[NSDictionary class]]) {
                  // 回调数据
                  success(dic);
              }else{
                  failBlock();
              }
              [http mustLogoutWithResult:responseObj];
          }
          failure:^(NSURLSessionTask* operation,NSError *error){
              failBlock();
          }];
}


+(void)uploadUserFaceWithImage:(UIImage*)image start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager POST:kAPI_Users_UserUploadFace parameters:[self hashWithParams:nil] constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSData *data = UIImageJPEGRepresentation(image, 0.8f);
        NSString *fileName = [NSString stringWithFormat:@"%f.jpg",[fn getTimestamp]];
        [formData appendPartWithFileData:data name:@"file" fileName:fileName mimeType:@"image/jpeg"];
        data = nil;
        fileName = nil;
        
    }
    progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
        NSDictionary *dic = (NSDictionary*)responseObj;
        if ([[dic class] isSubclassOfClass:[NSDictionary class]]) {
            // 回调数据
            success(dic);
        }else{
            failBlock();
        }
        [http mustLogoutWithResult:responseObj];
    }
    failure:^(NSURLSessionTask* operation,NSError *error){
        failBlock();
    }];
}

+(void)checkUserIsVipWithStart:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager POST:kAPI_Users_UserIsVip
       parameters:[self hashWithParams:nil]
          progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL); NSDictionary *dic = (NSDictionary*)responseObj;
              if ([[dic class] isSubclassOfClass:[NSDictionary class]]) {
                  // 回调数据
                  success(dic);
              }else{
                  failBlock();
              }
              [http mustLogoutWithResult:responseObj];
          }
          failure:^(NSURLSessionTask* operation,NSError *error){
              failBlock();
          }];
}

// 是否vip用户
+(void)checkHttpIsVipUser:(void (^)())startBlock finishBlock:(void (^)(bool isVIP))finishBlock{
    if (startBlock) {
        startBlock();
    }
    [http checkUserIsVipWithStart:^{} failure:^{
        if (finishBlock) {
            finishBlock(NO);
        }
    }
        success:^(NSDictionary*dic){
        if (![dic[@"data"] isEqual:[NSNull null]]) {
            BOOL success = [dic[@"data"]boolValue];
            if (success) {
                // 是vip
                [FMUserDefault setUserIsPayed:1];
                if (finishBlock) {
                    finishBlock(YES);
                }
            }else{
                [FMUserDefault setUserIsPayed:0];
                if (finishBlock) {
                    finishBlock(NO);
                }
            }
        }else{
            [FMUserDefault setUserIsPayed:0];
            if (finishBlock) {
                finishBlock(NO);
            }
        }
        
    }];
}


+(void)getMessageWithSubUserId:(NSString *)subUserId page:(int)page pageSize:(int)pageSize Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager GET:kAPI_Users_MessageList
      parameters:[self hashWithParams:@{@"sub_userId":subUserId,
                                        @"page":[NSString stringWithFormat:@"%d",page],
                                        @"pageSize":[NSString stringWithFormat:@"%d",pageSize]}]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if ([[NSDictionary class] isSubclassOfClass:[NSDictionary class]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)sendMessageWithContent:(NSString *)content subUserId:(NSString *)subUserId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager POST:kAPI_Users_SendMessage
       parameters:[self hashWithParams:@{@"sub_userId":subUserId,
                                         @"content":content
                                         }]
          progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL); NSDictionary *data = (NSDictionary*)responseObj;
              if ([[NSDictionary class] isSubclassOfClass:[NSDictionary class]]) {
                  // 回调数据
                  success(data);
              }else{
                  failBlock();
              }
              [http mustLogoutWithResult:responseObj];
          }
          failure:^(NSURLSessionTask* operation,NSError *error){
              failBlock();
          }];
}

+(void)getSessionUsersWithPage:(int)page pageSize:(int)pageSize Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager GET:kAPI_Users_SessionUsers
      parameters:[self hashWithParams:@{
                                        @"page":[NSString stringWithFormat:@"%d",page],
                                        @"pageSize":[NSString stringWithFormat:@"%d",pageSize]
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if ([[NSDictionary class] isSubclassOfClass:[NSDictionary class]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)deleteSessionUserWithSessionUserId:(NSString *)sessionUserId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    
    // 开始请求
    startBlock();
    [manager GET:kAPI_Users_DeleteSessionUsers
      parameters:[self hashWithParams:@{
                                        @"sessionUserId":sessionUserId
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && ![data isEqual:[NSNull null]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)getAttentionUsersWithPage:(int)page pageSize:(int)pageSize Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager GET:kAPI_Users_AttentionUsers
      parameters:[self hashWithParams:@{
                                        @"page":[NSString stringWithFormat:@"%d",page],
                                        @"pageSize":[NSString stringWithFormat:@"%d",pageSize]
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if ([[NSDictionary class] isSubclassOfClass:[NSDictionary class]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)deleteAttentionUserWithAttentionUserId:(NSString *)attentionUserId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    
    // 开始请求
    startBlock();
    [manager GET:kAPI_Users_DeleteAttentionUsers
      parameters:[self hashWithParams:@{
                                        @"attentionUserId":attentionUserId
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && ![data isEqual:[NSNull null]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)deleteFansUserWithFansUserId:(NSString *)fansUserId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    
    // 开始请求
    startBlock();
    [manager GET:kAPI_Users_DeleteFansUsers
      parameters:[self hashWithParams:@{
                                        @"fansUserId":fansUserId
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && ![data isEqual:[NSNull null]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}


+(void)getUsersUnReadCountWithFromUserId:(NSString*)fromUserId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    if (!fromUserId) {
        fromUserId = @"";
    }
    startBlock();
    [manager GET:kAPI_Users_UnReadCount
      parameters:[self hashWithParams:@{@"fromUserId":fromUserId}]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if ([[NSDictionary class] isSubclassOfClass:[NSDictionary class]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)getFansUserListWithPage:(int)page pageSize:(int)pageSize Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager GET:kAPI_Users_FansUserList
      parameters:[self hashWithParams:@{
                                        @"page":[NSString stringWithFormat:@"%d",page],
                                        @"pageSize":[NSString stringWithFormat:@"%d",pageSize]
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if ([[NSDictionary class] isSubclassOfClass:[NSDictionary class]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)sendJoinMobileWithTel:(NSString*)tel password:(NSString*)password code:(NSString*)code Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager GET:kAPI_Users_JoinMobile
      parameters:[self hashWithParams:@{
                                        @"tel":tel,
                                        @"password":password,
                                        @"code":code
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if ([[NSDictionary class] isSubclassOfClass:[NSDictionary class]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)getUserInfoWithStart:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager GET:kAPI_Users_UserInfo
      parameters:[self hashWithParams:nil]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if ([[NSDictionary class] isSubclassOfClass:[NSDictionary class]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}


#pragma mark -
#pragma mark 模拟交易
+(void)getSimulatorAccountWithTeacherId:(NSString*)teacherId groupId:(NSString*)groupId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    if (!teacherId) {
        teacherId = @"";
    }
    if (!groupId) {
        groupId = @"0";
    }
    // 开始请求
    startBlock();
    [manager GET:kAPI_Stocks_Simulator_Account
      parameters:[self hashWithParams:@{@"groupId":groupId,@"teacherId":teacherId}]
        progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSLog(@"%@",operation.currentRequest.URL);
             NSDictionary *dic = (NSDictionary*)responseObj;
             NSDictionary *data = [dic objectForKey:@"data"];
             if ([[data class] isSubclassOfClass:[NSDictionary class]]) {
                 // 回调数据
                 success([NSDictionary dictionaryWithObject:data forKey:@"data"]);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             NSLog(@"%@,%@",operation.currentRequest.URL,error);
             failBlock();
         }];
}


+(void)getSimulatorRepertoryWithTeacherId:(NSString*)teacherId page:(int)page pageSize:(int)pageSize groupId:(NSString*)groupId start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    
    NSString *userId = [FMUserDefault getUserId];
    if ([userId intValue]<=0) {
        userId = @"";
    }
    if (!teacherId) {
        teacherId = @"";
    }
    if (!groupId) {
        groupId = @"0";
    }
    // 开始请求
    startBlock();
    [manager GET:kAPI_Stocks_Simulator_Repertory
      parameters:[self hashWithParams:@{
                                        @"groupId":groupId,
                                        @"page":@(page).stringValue,
                                        @"pageSize":@(pageSize).stringValue,
                                        @"teacherId":teacherId
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSLog(@"%@",operation.currentRequest.URL);
             NSDictionary *dic = (NSDictionary*)responseObj;
             NSArray *data = [dic objectForKey:@"data"];
             if ([[data class] isSubclassOfClass:[NSArray class]]) {
                 // 回调数据
                 success([NSDictionary dictionaryWithObject:data forKey:@"data"]);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             NSLog(@"%@,%@",operation.currentRequest.URL,error);
             failBlock();
         }];
}


+(void)getSimulatorEntrustsWithIsToday:(BOOL)isToday teacherId:(NSString*)teacherId groupId:(NSString*)groupId isClinch:(BOOL)isClinch history:(BOOL)isHistory page:(int)page pageSize:(int)pageSize start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    if (!teacherId) {
        teacherId = @"";
    }
    if (!groupId) {
        groupId = @"0";
    }
    // 开始请求
    startBlock();
    [manager GET:kAPI_Stocks_Simulator_Entrust
      parameters:[self hashWithParams:@{
                                        @"groupId":groupId,
                                        @"today":[NSString stringWithFormat:@"%d",isToday],
                                        @"isClinch":[NSString stringWithFormat:@"%d",isClinch],
                                        @"history":[NSString stringWithFormat:@"%d",isHistory],
                                        @"page":[NSString stringWithFormat:@"%d",page],
                                        @"pageSize":[NSString stringWithFormat:@"%d",pageSize],
                                        @"teacherId":teacherId
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSLog(@"%@",operation.currentRequest.URL);
             NSDictionary *dic = (NSDictionary*)responseObj;
             NSArray *data = [dic objectForKey:@"data"];
             if ([[data class] isSubclassOfClass:[NSArray class]]) {
                 // 回调数据
                 success([NSDictionary dictionaryWithObject:data forKey:@"data"]);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             NSLog(@"%@,%@",operation.currentRequest.URL,error);
             failBlock();
         }];
}

+(void)getSimulatorClinchsWithIsToday:(BOOL)isToday teacherId:(NSString*)teacherId groupId:(NSString*)groupId page:(int)page pageSize:(int)pageSize start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    if (!teacherId) {
        teacherId = @"";
    }
    if (!groupId) {
        groupId = @"0";
    }
    // 开始请求
    startBlock();
    [manager GET:kAPI_Stocks_Simulator_Clinchs
      parameters:[self hashWithParams:@{
                                        @"groupId":groupId,
                                        @"teacherId":teacherId,
                                        @"today":[NSString stringWithFormat:@"%d",isToday],
                                        @"page":[NSString stringWithFormat:@"%d",page],
                                        @"pageSize":[NSString stringWithFormat:@"%d",pageSize]
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSLog(@"%@",operation.currentRequest.URL);
             NSDictionary *dic = (NSDictionary*)responseObj;
             NSArray *data = [dic objectForKey:@"data"];
             if ([[data class] isSubclassOfClass:[NSArray class]]) {
                 // 回调数据
                 success([NSDictionary dictionaryWithObject:data forKey:@"data"]);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             NSLog(@"%@,%@",operation.currentRequest.URL,error);
             failBlock();
         }];
}

+(void)sendSimulatorEntrustWithCode:(NSString *)code price:(NSString *)price amount:(NSString*)amount direction:(int)direction entrustId:(NSString *)entrustId groupId:(NSString*)groupId action:(NSString *)action start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    if (!entrustId) {
        entrustId = @"";
    }
    if (!groupId) {
        groupId = @"0";
    }
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager POST:kAPI_Stocks_Simulator_Insert
       parameters:[self hashWithParams:@{
                                         @"groupId":groupId,
                                         @"code":code,
                                         @"price":price,
                                         @"direction":[NSString stringWithFormat:@"%d",direction],
                                         @"action":action,
                                         @"entrustId":entrustId,
                                         @"amount":amount
                                         }]
          progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL); NSLog(@"%@",operation.currentRequest.URL);
              NSDictionary *dic = (NSDictionary*)responseObj;
              if ([[dic class] isSubclassOfClass:[NSDictionary class]]) {
                  // 回调数据
                  success(dic);
              }else{
                  failBlock();
              }
              [http mustLogoutWithResult:responseObj];
          }
          failure:^(NSURLSessionTask* operation,NSError *error){
              failBlock();
          }];
}
#pragma mark -
#pragma mark 组合

/**
 *  获取组合列表
 *
 *  @param isPay      是否付费组合
 *  @param type       组合类型 type＝sub 订阅
 *  @param orderField 排序字段，默认0=时间排序
 *  @param orderType  排序类型 desc和asc 默认desc
 *  @param page       页码
 *  @param pageSize   每页大小
 */
+(void)getSimulatorGroupListWithIsPay:(int)isPay type:(NSString*)type orderField:(int)orderField orderType:(NSString*)orderType page:(int)page pageSize:(int)pageSize start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    if (!orderType) {
        orderType = @"";
    }
    // 开始请求
    startBlock();
    [manager GET:kAPI_Stocks_Simulator_GroupList
      parameters:[self hashWithParams:@{
                                        @"orderField":@(orderField).stringValue,
                                        @"orderType":orderType,
                                        @"isPay":[NSString stringWithFormat:@"%d",isPay],
                                        @"page":[NSString stringWithFormat:@"%d",page],
                                        @"pageSize":[NSString stringWithFormat:@"%d",pageSize],
                                        @"type":[NSString stringWithFormat:@"%@",type],
                                        }]
        progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSLog(@"%@",operation.currentRequest.URL);
             NSDictionary *dic = (NSDictionary*)responseObj;
             NSArray *data = [dic objectForKey:@"data"];
             if ([[data class] isSubclassOfClass:[NSArray class]]) {
                 // 回调数据
                 success([NSDictionary dictionaryWithObject:data forKey:@"data"]);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             NSLog(@"%@,%@",operation.currentRequest.URL,error);
             failBlock();
         }];
}

+(void)getSimulatorGroupDetailWithGroupId:(NSString*)groupId start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager GET:kAPI_Stocks_Simulator_GroupDetail
      parameters:[self hashWithParams:@{
                                        @"groupId":groupId
                                        }]
        progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSLog(@"%@",operation.currentRequest.URL);
             NSDictionary *dic = (NSDictionary*)responseObj;
             if ([[dic class] isSubclassOfClass:[NSDictionary class]]) {
                 // 回调数据
                 success(dic);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             NSLog(@"%@,%@",operation.currentRequest.URL,error);
             failBlock();
         }];
}

+(void)getSimulatorChartWithGroupId:(NSString*)groupId teacherId:(NSString*)teacherId start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    if (!teacherId) {
        teacherId = @"";
    }
    // 开始请求
    startBlock();
    [manager GET:kAPI_Stocks_Simulator_GroupChart
      parameters:[self hashWithParams:@{
                                        @"groupId":groupId,
                                        @"teacherId":teacherId
                                        }]
        progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSLog(@"%@",operation.currentRequest.URL);
             NSDictionary *dic = (NSDictionary*)responseObj;
             if ([[dic class] isSubclassOfClass:[NSDictionary class]]) {
                 // 回调数据
                 success(dic);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             NSLog(@"%@,%@",operation.currentRequest.URL,error);
             failBlock();
         }];
}

+(void)setSimulatorGroupWithGroups:(NSDictionary*)groups start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager GET:kAPI_Stocks_Simulator_Group
      parameters:[self hashWithParams:groups]
        progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSLog(@"%@",operation.currentRequest.URL);
             NSDictionary *dic = (NSDictionary*)responseObj;
             if ([[dic class] isSubclassOfClass:[NSDictionary class]]) {
                 // 回调数据
                 success(dic);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             NSLog(@"%@,%@",operation.currentRequest.URL,error);
             failBlock();
         }];
}

+(void)getSimulatorGroupSubWithGroupId:(NSString *)groupId start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager GET:kAPI_Stocks_Simulator_GroupSub
      parameters:[self hashWithParams:@{@"groupId":groupId}]
        progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);
             NSDictionary *dic = (NSDictionary*)responseObj;
             if ([[dic class] isSubclassOfClass:[NSDictionary class]]) {
                 // 回调数据
                 success(dic);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             NSLog(@"%@,%@",operation.currentRequest.URL,error);
             failBlock();
         }];
}


#pragma mark -
#pragma mark 牛人

+(void)getTeacherListWithSize:(int)page pageSize:(int)pageSize type:(NSString*)type Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    if (!type) {
        type = @"";
    }
    // 开始请求
    startBlock();
    [manager GET:kAPI_Teacher_TeacherList
      parameters:[self hashWithParams:@{@"page":[NSString stringWithFormat:@"%d",page],
                                        @"pageSize":[NSString stringWithFormat:@"%d",pageSize],
                                        @"type":type
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if ([[data class] isSubclassOfClass:[NSDictionary class]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}


+(void)getTeacherDetailWithTeacherId:(NSString *)teacherId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager GET:kAPI_Teacher_TeacherDetail
      parameters:[self hashWithParams:@{@"teacherId":teacherId}]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if ([[NSDictionary class] isSubclassOfClass:[NSDictionary class]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)postTeacherAttentionWithTeacherId:(NSString *)teacherId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager POST:kAPI_Teacher_payAttention
      parameters:[self hashWithParams:@{@"teacherId":teacherId}]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if ([[NSDictionary class] isSubclassOfClass:[NSDictionary class]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)getTeacherHistoryTradeWithTeacherId:(NSString*)teacherId page:(int)page pageSize:(int)pageSize start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager GET:kAPI_Teacher_tradehistory
      parameters:[self hashWithParams:@{
                                        @"teacherId":teacherId,
                                        @"page":[NSString stringWithFormat:@"%d",page],
                                        @"pageSize":[NSString stringWithFormat:@"%d",pageSize]
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *dic = (NSDictionary*)responseObj;
             NSArray *data = [dic objectForKey:@"data"];
             if ([[data class] isSubclassOfClass:[NSArray class]]) {
                 // 回调数据
                 success([NSDictionary dictionaryWithObject:data forKey:@"data"]);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

#pragma mark -
#pragma mark 自选股

+(void)getSelfStocksWithAction:(NSString *)action codes:(NSString *)codes Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    if (!codes) {
        codes = @"";
    }
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager GET:kAPI_Stocks_SelfStocks
      parameters:[self hashWithParams:@{@"action":action,
                                        @"code":codes}]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && ![data isEqual:[NSNull null]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)sendSelfStockRmindWithCode:(NSString *)code
                        upToPrice:(NSString *)upToPrice
                      downToPrice:(NSString *)downToPrice
                    upRateToValue:(NSString *)upRateToValue
                  downRateToValue:(NSString *)downRateToValue
                            Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    if (!code) {
        failBlock();
        return;
    }
    if (!upToPrice) {
        upToPrice = @"";
    }
    if (!downToPrice) {
        downToPrice = @"";
    }
    if (!upRateToValue) {
        upRateToValue = @"";
    }
    if (!downRateToValue) {
        downRateToValue = @"";
    }
    if ([upToPrice floatValue]<=0 &&
        [downToPrice floatValue]<=0 &&
        [upRateToValue floatValue]<=0 &&
        [downRateToValue floatValue]<=0) {
        failBlock();
        return;
    }
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager POST:kAPI_Stocks_StockRemind
      parameters:[self hashWithParams:@{
                                        @"action":@"a",
                                        @"upToPrice":upToPrice,
                                        @"downToPrice":downToPrice,
                                        @"upRateToValue":upRateToValue,
                                        @"downRateToValue":downRateToValue,
                                        @"code":code}]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && ![data isEqual:[NSNull null]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)getSelfStockRemindInfoWithCode:(NSString *)code Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{

    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager GET:kAPI_Stocks_StockRemind
      parameters:[self hashWithParams:@{
                                        @"action":@"",
                                        @"code":code}]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && ![data isEqual:[NSNull null]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

#pragma mark - 首页幻灯片快捷按钮

+(void)getFlashListWithStart:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager GET:kAPI_FlashList
      parameters:[self hashWithParams:nil]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && ![data isEqual:[NSNull null]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)getShortcutWithStart:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager GET:kAPI_Shortcut
      parameters:[self hashWithParams:nil]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && ![data isEqual:[NSNull null]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

#pragma mark -
#pragma mark 新闻资讯

+(void)getArticleListWithPage:(int)page pageSize:(int)pageSize typeCode:(NSString*)typeCode withStart:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    if (page<=1) {
        page = 1;
    }
    if (pageSize<=0) {
        pageSize = 0;
    }
    if (typeCode==nil) {
        typeCode = @"";
    }
    // 开始请求
    startBlock();
    [manager GET:kAPI_ArticleList
      parameters:[self hashWithParams:@{
                                        @"page":[NSString stringWithFormat:@"%d",page],
                                        @"pageSize":[NSString stringWithFormat:@"%d",pageSize],
                                        @"typeCode":typeCode
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && ![data isEqual:[NSNull null]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)getNewsLiveListWithPage:(int)page pageSize:(int)pageSize typeCode:(NSString*)typeCode withStart:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    if (page<=1) {
        page = 1;
    }
    if (pageSize<=0) {
        pageSize = 0;
    }
    if (typeCode==nil) {
        typeCode = @"";
    }
    // 开始请求
    startBlock();
    [manager GET:kAPI_NewsLive
      parameters:[self hashWithParams:@{
                                        @"page":[NSString stringWithFormat:@"%d",page],
                                        @"pageSize":[NSString stringWithFormat:@"%d",pageSize],
                                        @"typeCode":typeCode
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && ![data isEqual:[NSNull null]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)getArticleColumnListWithStart:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    
    // 开始请求
    if (startBlock) startBlock();
    [manager GET:kAPI_ArticleColumn
      parameters:[self hashWithParams:nil]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && [data isKindOfClass:[NSDictionary class]]) {
                 // 存入缓存
                 NSArray *list = data[@"data"];
                 if (list && [list isKindOfClass:[NSArray class]]) {
                     [[EGOCache globalCache] setString:[list JSONRepresentation] forKey:kAPI_ArticleColumnCacheKey];
                     // 回调数据
                     if(success)success(data);
                     return ;
                 }
                 
             }
             
             if(failBlock)failBlock();
             
             [http mustLogoutWithResult:responseObj];
             
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             if(failBlock)failBlock();
         }];
}


+(void)getActivityListWithPage:(int)page pageSize:(int)pageSize withStart:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    if (page<=1) {
        page = 1;
    }
    if (pageSize<=0) {
        pageSize = 0;
    }

    // 开始请求
    startBlock();
    [manager GET:kAPI_ActivityList
      parameters:[self hashWithParams:@{
                                        @"page":[NSString stringWithFormat:@"%d",page],
                                        @"pageSize":[NSString stringWithFormat:@"%d",pageSize]
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && ![data isEqual:[NSNull null]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

#pragma mark -
#pragma mark 搜索股票
+(void)getSearchStocksListWithKey:(NSString*)key start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    startBlock();
    key = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *url = [NSString stringWithFormat:@"%@?key=%@",kAPI_Search,key];
    [[NSOperationQueue mainQueue] cancelAllOperations];
    
    AFHTTPSessionManager *manager = [self requestManager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [manager GET:url parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if ([[str class] isSubclassOfClass:[NSString class]]) {
            success(@{@"data":str});
            return ;
        }
        failBlock();
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"FlyElephant-Error: %@", error);
    }];
    
    
//    [op setCompletionBlockWith
//         success:^(NSURLSessionTask *operation, id responseObject) {
//        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        if ([[str class] isSubclassOfClass:[NSString class]]) {
//            success(@{@"data":str});
//            return ;
//        }
//        failBlock();
//        
//    } failure:^(NSURLSessionTask *operation, NSError *error) {
//        failBlock();
//    }];
//    [[NSOperationQueue mainQueue] addOperation:];
}

#pragma mark -
#pragma mark 远程配置
+(void)getServerConfig{
    AFHTTPSessionManager *manager = [self requestManager];
    [manager.operationQueue waitUntilAllOperationsAreFinished];
    [manager GET:kAPI_Config
      parameters:[self hashWithParams:nil]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && ![data isEqual:[NSNull null]]) {
                 data = data[@"data"];
                 if ([[data class] isSubclassOfClass:[NSDictionary class]]) {
                     NSString *isClose = [NSString stringWithFormat:@"%@",data[@"marketIsClose_cn"]];
                     [FMUserDefault setMarketIsClose:[isClose boolValue]];
                     return ;
                 }
             }
             [FMUserDefault setMarketIsClose:false];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             [FMUserDefault setMarketIsClose:false];
         }];
}

#pragma mark -
#pragma mark 下载启动广告图片
+(void)getStartAd{
    AFHTTPSessionManager *manager = [self requestManager];
//    [manager.operationQueue waitUntilAllOperationsAreFinished];
    [manager GET:kAPI_StartAD
      parameters:[self hashWithParams:nil]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && [data isKindOfClass:[NSDictionary class]]) {
                 NSLog(@"广告图数据下载成功：%@",data);
                 [FMUserDefault setStartADDatas:data];
             }

         }
         failure:^(NSURLSessionTask* operation,NSError *error){

         }];
}

#pragma mark - 请求自定义指标

+(void)getStockSelfIndexWithCode:(NSString *)code indexCode:(NSString *)indexCode type:(int)type page:(int)page pageSize:(int)pageSize withStart:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    if (page<=1) {
        page = 1;
    }
    if (pageSize<=0) {
        pageSize = 0;
    }
    
    // 开始请求
    startBlock();
    [manager GET:kAPI_StockSelfIndex
      parameters:[self hashWithParams:@{
                                        @"code":code,
                                        @"indexCode":indexCode,
                                        @"type":[NSString stringWithFormat:@"%d",type],
                                        @"page":[NSString stringWithFormat:@"%d",page],
                                        @"pageSize":[NSString stringWithFormat:@"%d",pageSize]
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && ![data isEqual:[NSNull null]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

#pragma mark - 策略列表

+(void)getCelueListWithStart:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    
    // 开始请求
    startBlock();
    [manager GET:kAPI_Celue
      parameters:[self hashWithParams:nil]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && ![data isEqual:[NSNull null]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

#pragma mark - 股票池列表

+(void)getGupiaochiListWithPage:(int)page pageSize:(int)pageSize Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    
    // 开始请求
    startBlock();
    [manager GET:kAPI_Gupiaochi
      parameters:[self hashWithParams:@{
                                        @"page":[NSString stringWithFormat:@"%d",page],
                                        @"pageSize":[NSString stringWithFormat:@"%d",pageSize]
                                        
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && ![data isEqual:[NSNull null]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}


#pragma mark - 策略平台列表

+(void)getTacticsListWithTacticsUserId:(NSString*)tacticsUserId type:(NSString*)type page:(int)page pageSize:(int)pageSize Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    if (!tacticsUserId) {
        tacticsUserId = @"";
    }
    if (type==nil) {
        type = @"";
    }
    // 开始请求
    startBlock();
    [manager GET:kAPI_TacticsList
      parameters:[self hashWithParams:@{
                                        @"page":[NSString stringWithFormat:@"%d",page],
                                        @"pageSize":[NSString stringWithFormat:@"%d",pageSize],
                                        @"tacticsUserId":tacticsUserId,
                                        @"type":type
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && ![data isEqual:[NSNull null]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)getTacticsDetailWithTacticsId:(NSString*)tacticsId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager GET:kAPI_TacticsDetail
      parameters:[self hashWithParams:@{
                                        @"tacticsId":tacticsId
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && ![data isEqual:[NSNull null]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)getTacticsStocksWithTacticsId:(NSString*)tacticsId page:(int)page pageSize:(int)pageSize Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];

    // 开始请求
    startBlock();
    [manager GET:kAPI_TacticsStocks
      parameters:[self hashWithParams:@{
                                        @"page":[NSString stringWithFormat:@"%d",page],
                                        @"pageSize":[NSString stringWithFormat:@"%d",pageSize],
                                        @"tacticsId":tacticsId
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && ![data isEqual:[NSNull null]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)sendTacticsWithTacticsId:(NSString *)tacticsId title:(NSString *)title intro:(NSString *)intro stocks:(NSArray*)stocks Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    if (!tacticsId) {
        tacticsId = @"";
    }
    // 开始请求
    startBlock();
    [manager POST:kAPI_EditTactics
       parameters:[self hashWithParams:@{
                                         @"tacticsId":tacticsId,
                                         @"title":title,
                                         @"intro":intro,
                                         @"stocks":[stocks JSONRepresentation]
                                         }]
          progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL); NSDictionary *data = (NSDictionary*)responseObj;
              if (data && ![data isEqual:[NSNull null]]) {
                  // 回调数据
                  success(data);
              }else{
                  failBlock();
              }
              [http mustLogoutWithResult:responseObj];
          }
          failure:^(NSURLSessionTask* operation,NSError *error){
              failBlock();
          }];
}

+(void)deleteTacticsStocksWithTacticsId:(NSString *)tacticsId code:(NSString *)code Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];

    // 开始请求
    startBlock();
    [manager GET:kAPI_DeleteTacticsStocks
       parameters:[self hashWithParams:@{
                                         @"tacticsId":tacticsId,
                                         @"code":code
                                         }]
          progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL); NSDictionary *data = (NSDictionary*)responseObj;
              if (data && ![data isEqual:[NSNull null]]) {
                  // 回调数据
                  success(data);
              }else{
                  failBlock();
              }
              [http mustLogoutWithResult:responseObj];
          }
          failure:^(NSURLSessionTask* operation,NSError *error){
              failBlock();
          }];
}

+(void)deleteTacticsWithTacticsId:(NSString *)tacticsId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    
    // 开始请求
    startBlock();
    [manager GET:kAPI_DeleteTactics
       parameters:[self hashWithParams:@{
                                         @"tacticsId":tacticsId
                                         }]
          progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL); NSDictionary *data = (NSDictionary*)responseObj;
              if (data && ![data isEqual:[NSNull null]]) {
                  // 回调数据
                  success(data);
              }else{
                  failBlock();
              }
              [http mustLogoutWithResult:responseObj];
          }
          failure:^(NSURLSessionTask* operation,NSError *error){
              failBlock();
          }];
}

#pragma mark - 点评，关注，点赞
+(void)setCommunityLikeWithObjectId:(NSString *)objectId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    
    // 开始请求
    startBlock();
    [manager GET:kAPI_Community_Like
      parameters:[self hashWithParams:@{
                                        @"objectId":objectId
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && ![data isEqual:[NSNull null]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)setCommunityAttentionWithObjectId:(NSString *)objectId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    
    // 开始请求
    startBlock();
    [manager GET:kAPI_Community_Attention
      parameters:[self hashWithParams:@{
                                        @"objectId":objectId
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && ![data isEqual:[NSNull null]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)sendCommunityPostsWithObjectId:(NSString *)objectId content:(NSString *)content postId:(NSString *)postId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    if (!postId) {
        postId = @"";
    }
    // 开始请求
    startBlock();
    [manager POST:kAPI_Community_posts
      parameters:[self hashWithParams:@{
                                        @"objectId":objectId,
                                        @"action":@"add",
                                        @"content":content,
                                        @"postId":postId
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && ![data isEqual:[NSNull null]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)getCommunityPostsListWithObjectId:(NSString *)objectId page:(int)page pageSize:(int)pageSize Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];

    // 开始请求
    startBlock();
    [manager POST:kAPI_Community_posts
       parameters:[self hashWithParams:@{
                                         @"objectId":objectId,
                                         @"action":@"list",
                                         @"page":@(page).stringValue,
                                         @"pageSize":@(pageSize).stringValue
                                         }]
          progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL); NSDictionary *data = (NSDictionary*)responseObj;
              if (data && ![data isEqual:[NSNull null]]) {
                  // 回调数据
                  success(data);
              }else{
                  failBlock();
              }
              [http mustLogoutWithResult:responseObj];
          }
          failure:^(NSURLSessionTask* operation,NSError *error){
              failBlock();
          }];
}

+(void)sendCommunityThemeWithThemeId:(NSString *)themeId pics:(NSString*)pics content:(NSString*)content Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    if (!themeId) {
        themeId = @"";
    }
    if (!pics) {
        pics = @"";
    }
//    content = [content stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // 开始请求
    startBlock();
    [manager POST:kAPI_Community_addThemes
       parameters:[self hashWithParams:@{
                                         @"themeId":themeId,
                                         @"pics":pics,
                                         @"content":content
                                         }]
          progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL); NSDictionary *data = (NSDictionary*)responseObj;
              if (data && ![data isEqual:[NSNull null]]) {
                  // 回调数据
                  success(data);
              }else{
                  failBlock();
              }
              [http mustLogoutWithResult:responseObj];
          }
          failure:^(NSURLSessionTask* operation,NSError *error){
              failBlock();
          }];
}

+(void)uploadCommunityThemePicsWithImage:(UIImage*)image start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager POST:kAPI_Community_uploadThemePics parameters:[self hashWithParams:nil] constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSData *data = UIImageJPEGRepresentation(image, 0.5);
        NSString *fileName = [NSString stringWithFormat:@"%f.png",[fn getTimestamp]];
        [formData appendPartWithFileData:data name:@"file" fileName:fileName mimeType:@"image/jpeg"];
        data = nil;
        fileName = nil;
        
    }
          progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL); NSDictionary *dic = (NSDictionary*)responseObj;
              if ([[dic class] isSubclassOfClass:[NSDictionary class]]) {
                  // 回调数据
                  success(dic);
              }else{
                  failBlock();
              }
              [http mustLogoutWithResult:responseObj];
          }
          failure:^(NSURLSessionTask* operation,NSError *error){
              failBlock();
          }];
}

+(void)getCommunityThemeListWithThemeUserId:(NSString*)themeUserId type:(NSString*)type page:(int)page pageSize:(int)pageSize Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    if (!themeUserId) {
        themeUserId = @"";
    }
    if (type==nil) {
        type = @"";
    }
    // 开始请求
    startBlock();
    [manager GET:kAPI_Community_ThemeList
      parameters:[self hashWithParams:@{
                                        @"page":[NSString stringWithFormat:@"%d",page],
                                        @"pageSize":[NSString stringWithFormat:@"%d",pageSize],
                                        @"themeUserId":themeUserId,
                                        @"type":type
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && ![data isEqual:[NSNull null]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)getCommunityDetailWithThemeId:(NSString*)themeId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager GET:kAPI_Community_ThemeDetail
      parameters:[self hashWithParams:@{
                                        @"themeId":themeId
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && ![data isEqual:[NSNull null]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)deleteCommunityWithThemeId:(NSString*)themeId Start:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    // 开始请求
    startBlock();
    [manager GET:kAPI_Community_DeleteTheme
      parameters:[self hashWithParams:@{
                                        @"themeId":themeId
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && ![data isEqual:[NSNull null]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

#pragma mark - 视频直播
+(void)getVideoListWithPage:(int)page pageSize:(int)pageSize withStart:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    if (page<=1) {
        page = 1;
    }
    if (pageSize<=0) {
        pageSize = 0;
    }
    
    // 开始请求
    startBlock();
    [manager GET:kAPI_Video_List
      parameters:[self hashWithParams:@{
                                        @"page":[NSString stringWithFormat:@"%d",page],
                                        @"pageSize":[NSString stringWithFormat:@"%d",pageSize]
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && ![data isEqual:[NSNull null]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)getVideoDetailWithVideoId:(NSString*)videoId withStart:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    
    // 开始请求
    startBlock();
    [manager GET:kAPI_Video_Detail
      parameters:[self hashWithParams:@{
                                        @"videoId":videoId
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && ![data isEqual:[NSNull null]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

+(void)getVideoTeacherSayListWithVideoId:(NSString*)videoId page:(int)page pageSize:(int)pageSize withStart:(void (^)())startBlock failure:(void (^)())failBlock success:(requestSuccessBlock)success{
    AFHTTPSessionManager *manager = [self requestManager];
    
    // 开始请求
    startBlock();
    [manager GET:kAPI_Video_TeacherSayList
      parameters:[self hashWithParams:@{
                                        @"videoId":videoId,
                                        @"page":@(page).stringValue,
                                        @"pageSize":@(pageSize).stringValue
                                        }]
         progress:nil
         success:^(NSURLSessionTask *operation,id responseObj){
             NSLog(@"%@",operation.currentRequest.URL);NSDictionary *data = (NSDictionary*)responseObj;
             if (data && ![data isEqual:[NSNull null]]) {
                 // 回调数据
                 success(data);
             }else{
                 failBlock();
             }
             [http mustLogoutWithResult:responseObj];
         }
         failure:^(NSURLSessionTask* operation,NSError *error){
             failBlock();
         }];
}

@end
