//
//  FMDBManager.m
//  FMMarket
//
//  Created by dangfm on 15/8/8.
//  Copyright (c) 2015年 dangfm. All rights reserved.
//

/*
 [self insert:@"SelfStocks" withFiledValues:@{
 @"Name":@"浦发银行",
 @"Code":@"600000",
 @"Type":@"sh",
 @"Price":@"16.34",
 @"ChangeRate":@"0.3",
 @"OrderValue":order,
 @"Timestamp":timestamp
 }];
 
 FMResultSet *rs = [self select:@"SelfStocks" Where:[NSString stringWithFormat:@" Code='%@'",@"600000"] Order:@" OrderValue desc" Limit:nil];
 while ([rs next]) {
 NSString *name = [rs stringForColumn:@"Name"];
 int OrderValue = [rs intForColumn:@"OrderValue"];
 DDLogDebug(@"name=%@ OrderValue=%d",name,OrderValue);
 }
 */

#import "FMDBManager.h"


@interface FMDBManager(){
    FMDatabase *_db;
    FMDatabaseQueue *_queue;
}

@end

@implementation FMDBManager

+(instancetype)shareManager{
    static FMDBManager *instance = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        instance = [[FMDBManager alloc] init];
    });
    return instance;
}

-(instancetype)init{
    if (self==[super init]) {
        
        [self createDB];
    }
    return self;
}

#pragma mark - 
#pragma mark 创建数据库
//  创建数据库
-(void)createDB{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentDirectory stringByAppendingPathComponent:kFMDBName];
    _queue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    _db = [FMDatabase databaseWithPath:dbPath] ;
    if (![_db open]) {
        NSLog(@"Could not open db.");
        return ;
    }
    NSLog(@"database path : %@",dbPath);
    // 创建表
    [self createTables];
}
//  创建表结构
-(void)createTables{
    [self createTableWithModel:[FMSelfStocksModel class]];
    [self createTableWithModel:[FMStocksModel class]];
    [self createTableWithModel:[FMStockRemindModel class]];
}

//  通过模型创建表
-(void)createTableWithModel:(id)model{
    if (![self isExit:model]) {
        NSString *s = [self createSqlWithTableModel:[model class]];
        [_db executeUpdate:s];
    }
}

//  通过模型生成创建表语句
-(NSString*)createSqlWithTableModel:(id)model{
    NSArray *propertys = [fn propertyKeysWithClass:[model class]];
    NSString *keys = @"";
    NSString *className = NSStringFromClass([model class]);
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE %@ (",className];
    for (NSString *key in propertys) {
        //  字符串
        if ([[key class] isSubclassOfClass:[NSString class]]) {
            keys = [keys stringByAppendingString:[NSString stringWithFormat:@"%@ text,",key]];
        }
        //  数字
        if ([[key class] isSubclassOfClass:[NSNumber class]]) {
            keys = [keys stringByAppendingString:[NSString stringWithFormat:@"%@ integer,",key]];
        }
    }
    if ([[keys substringFromIndex:keys.length-1] isEqualToString:@","]) {
        keys = [keys substringToIndex:keys.length-1];
    }
    sql = [sql stringByAppendingString:[NSString stringWithFormat:@"%@)",keys]];
    return sql;
}

-(void)removeDatabase{
    [_db close];
    // 直接删除文件
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dbPath = _db.databasePath;
    if ([fileManager fileExistsAtPath:dbPath]) {
        [fileManager removeItemAtPath:dbPath error:nil];
    }
}

-(void)dropTable:(id)model{
    NSString *table = NSStringFromClass([model class]);
    NSString *sql = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@",table];
    [_db executeUpdate:sql];
}

-(void)clearTable:(id)model{
    NSString *table = NSStringFromClass([model class]);
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@",table];
    [_db executeUpdate:sql];
}

#pragma mark -
#pragma mark 数据库操作

//  插入数据
-(void)insert:(id)model FinishBlock:(void (^)(bool issuccess))finishBlock{
    NSString *fileds = @"";
    NSArray *keys = [fn propertyKeysWithClass:[model class]];
    //NSString *wenhao = @"";
    NSString *values = @"";
    for (NSString *key in keys) {
        NSString* value = [NSString stringWithFormat:@"%@",[model valueForKey:key]];
        if ([value isEqualToString:@"(null)"] || !value) {
            value = @"";
        }
        if ([fileds isEqualToString:@""]) {
            fileds = [fileds stringByAppendingFormat:@"%@",key];
            values = [values stringByAppendingFormat:@"'%@'",value];
        }else{
            fileds = [fileds stringByAppendingFormat:@",%@",key];
            values = [values stringByAppendingFormat:@",'%@'",value];
        }
    }
    NSString *table = NSStringFromClass([model class]);
    NSString *sql = [[NSString alloc]
                            initWithFormat:@"INSERT INTO %@ (%@) Values(%@)",table,fileds,values];
    // 加入队列
    [_queue inDatabase:^(FMDatabase *dbs){
        bool success = [_db executeUpdate:sql];
        // DDLogDebug(@"insert sql:%@",sql);
        if (finishBlock) {
            finishBlock(success);
        }
    }];
    
}

//  更新数据
-(void)update:(id)model Where:(NSString*)where FinishBlock:(void (^)(bool issuccess))finishBlock{

    NSString *fileds = @"";
    NSArray *keys = [fn propertyKeysWithClass:[model class]];
    for (NSString *key in keys) {
        NSString* value = [NSString stringWithFormat:@"%@",[model valueForKey:key]];
        if (![value isEqualToString:@"(null)"] && value) {
            if ([fileds isEqualToString:@""]) {
                fileds = [fileds stringByAppendingFormat:@"%@='%@'",key,value];
            }else{
                fileds = [fileds stringByAppendingFormat:@",%@='%@'",key,value];
            }
        }
        
    }
    NSString *table = NSStringFromClass([model class]);
    NSString *sql = [[NSString alloc]
                     initWithFormat:@"UPDATE %@ SET %@",table,fileds];
    if (where) {
        sql = [sql stringByAppendingFormat:@" WHERE %@",where];
    }
    // 加入队列
    [_queue inDatabase:^(FMDatabase *dbs){
        bool success = [_db executeUpdate:sql];
        // DDLogDebug(@"insert sql:%@",sql);
        if (finishBlock) {
            finishBlock(success);
        }
    }];
}

//  查询
-(NSArray*)select:(id)model Where:(NSString*)where Order:(NSString*)order Limit:(NSString*)limit{
    NSString *table = NSStringFromClass([model class]);
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@",table];
    if (where) {
        sql = [sql stringByAppendingFormat:@" WHERE %@",where];
    }
    if (order) {
        sql = [sql stringByAppendingFormat:@" ORDER BY %@",order];
    }
    if (limit) {
        sql = [sql stringByAppendingFormat:@" LIMIT %@",limit];
    }
    NSMutableArray *array = [NSMutableArray new];
    FMResultSet *rs = [_db executeQuery:sql];
    while ([rs next]) {
        NSDictionary *dic = [rs resultDictionary];
        id m = [[[model class] alloc] initWithDic:dic];
        [array addObject:m];
        dic = nil;
        m = nil;
    }
    return array;
    
}


//  删除
-(BOOL)delete:(id)model Where:(NSString*)where{
    NSString *table = NSStringFromClass([model class]);
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@",table];
    if (where) {
        sql = [sql stringByAppendingFormat:@" WHERE %@",where];
    }

    BOOL success = [_db executeUpdate:sql];
    return success;
    
}

//  获取表记录总数
-(NSInteger)getCount:(id)model{
    NSString *table = NSStringFromClass([model class]);
    NSInteger count = 0;
    NSString *sqlStr = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@",table];
    count = [_db intForQuery:sqlStr];
    return count;
}

-(NSInteger)getCount:(id)model where:(NSString*)where{
    NSString *table = NSStringFromClass([model class]);
    NSInteger count = 0;
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@",table];
    if (where) {
        sql = [sql stringByAppendingFormat:@" WHERE %@",where];
    }
    count = [_db intForQuery:sql];
    return count;
}

-(NSInteger)getSum:(id)model Filed:(NSString*)filed where:(NSString*)where{
    NSString *table = NSStringFromClass([model class]);
    NSInteger count = 0;
    NSString *sql = [NSString stringWithFormat:@"SELECT SUM(%@) FROM %@",filed,table];
    if (where) {
        sql = [sql stringByAppendingFormat:@" WHERE %@",where];
    }
    count = [_db intForQuery:sql];
    return count;
}

//  表是否存在
-(BOOL)isExit:(id)model{
    NSString *table = NSStringFromClass([model class]);
    BOOL exit = NO;
    exit = [_db intForQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?",table];
    return exit;
}


@end
