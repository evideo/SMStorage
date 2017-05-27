//
//  SMStorage.m
//  SMStorageExample
//
//  Created by StarNet on 3/29/17.
//  Copyright © 2017 smallmuou. All rights reserved.
//

#import "SMStorage.h"
#import "FMDB.h"
#import "SMSQLGrammer.h"

#if !__has_feature(objc_arc)
#error SMStorage must be compiled with ARC. Convert your project to ARC or specify the -fobjc-arc flag.
#endif

NSString* SMStorageVersionString = @"1.0.0";


#pragma mark - NSObject (SMStorage)

@implementation NSObject (SMStorage)

static NSMutableDictionary* primaryKeyCache = nil;
+ (void)sms_setPrimaryKey:(NSString* )variable {
    NSAssert([self sms_hasVariable:variable], @"%@ does not contain variable ", NSStringFromClass([self class]), variable);
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        primaryKeyCache = [NSMutableDictionary dictionary];
    });
    
    primaryKeyCache[NSStringFromClass([self class])] = variable;
}

+ (NSString* )sms_primaryKey {
    return primaryKeyCache[NSStringFromClass([self class])];
}

+ (void)sms_read:(NSString* )condition completion:(void(^)(NSArray* objects))completion {
    [[SMStorage defaultStorage] readFromClass:[self class] condition:condition completion:completion];
}

+ (void)sms_delete:(NSString* )condition completion:(void(^)())completion {
    [[SMStorage defaultStorage] deleteFromClass:[self class] condition:condition completion:completion];
}

+ (void)sms_clear:(void(^)())completion {
    [[SMStorage defaultStorage] clearFromClass:[self class] completion:completion];
}

- (void)sms_write:(void(^)())completion {
    [[SMStorage defaultStorage] writeObject:self completion:completion];
}

- (void)sms_delete:(void(^)())completion {
    [[SMStorage defaultStorage] deleteObject:self completion:completion];
}

@end

#pragma mark - SMStorage

@interface SMStorage () {
    FMDatabaseQueue*    _fmdbQueue;
    dispatch_queue_t    _queue;
}

@end

@implementation SMStorage
+ (instancetype)defaultStorage {
    static SMStorage* storage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storage = [[SMStorage alloc] init];
    });
    return storage;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _queue = dispatch_queue_create("SMStorage", NULL);
        NSString* basepath = [NSString stringWithFormat:@"%@/Documents/SMStorage", NSHomeDirectory()];
        NSFileManager* fileManager = [NSFileManager defaultManager];
        
        if (![fileManager fileExistsAtPath:basepath]) {
            [fileManager createDirectoryAtPath:basepath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSString* path = [NSString stringWithFormat:@"%@/SMStorage.db", basepath];
        SMStorageDebug(@"SQLITE DB FILE PATH: %@", path);
        _fmdbQueue = [FMDatabaseQueue databaseQueueWithPath:path];
    }
    return self;
}

- (void)dealloc {
    [_fmdbQueue close];
    
#if !OS_OBJECT_USE_OBJC
    dispatch_release(_queue);
#endif
}

- (void)inDatabase:(void(^)(FMDatabase *db))block {
    dispatch_async(_queue, ^{
        [_fmdbQueue inDatabase:block];
    });
}

- (void)inTransaction:(void (^)(FMDatabase *db, BOOL *rollback))block {
    dispatch_async(_queue, ^{
        [_fmdbQueue inTransaction:block];
    });
}

- (BOOL)isTableExist:(Class)clazz database:(FMDatabase* )db {
    BOOL exist = NO;
    NSString* sql = [SMSQLGrammer sqlForTableExist:clazz];
    SMStorageDebug(@"SQL:%@", sql);
    FMResultSet* rs = [db executeQuery:sql];
    exist = [rs next];
    [rs close];
    return exist;
}

- (NSDictionary* )tableInfo:(Class)clazz database:(FMDatabase* )db {
    NSString* sql = [SMSQLGrammer sqlForTableInfo:clazz];
    FMResultSet* rs = [db executeQuery:sql];
    NSMutableDictionary* info = [NSMutableDictionary dictionary];
    
    while ([rs next]) {
        info[[rs stringForColumn:@"name"]] = [rs stringForColumn:@"type"];
    }
    [rs close];
    return [NSDictionary dictionaryWithDictionary:info];
}

- (BOOL)isExistForObject:(id)object database:(FMDatabase* )db {
    if ([[object class] sms_primaryKey]) {
        BOOL exist = NO;
        NSString* sql = [SMSQLGrammer sqlForCheck:object];
        FMResultSet* rs = [db executeQuery:sql];
        SMStorageDebug(@"SQL:%@", sql);
        if ([rs next]) {
            exist = YES;
        }
        
        [rs close];
        return exist;
    } else {
        return NO;
    }
}


- (void)updateTableInfo:(Class)clazz database:(FMDatabase* )db {
    static NSMutableDictionary* createRecord = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        createRecord = [NSMutableDictionary dictionary];
    });
    
    //检测是否更新过
    if (createRecord[NSStringFromClass(clazz)]) {
        return;
    }
    createRecord[NSStringFromClass(clazz)] = @(YES);
    
    if ([self isTableExist:clazz database:db]) { //alter
        NSArray* sqls = [SMSQLGrammer sqlForAlter:clazz exceptColumns:[self tableInfo:clazz database:db]];
        for (NSString* sql in sqls) {
            [db executeUpdate:sql];
            SMStorageDebug(@"SQL:%@", sql);
        }
    } else { //create
        NSString* sql = [SMSQLGrammer sqlForCreateTable:clazz];
        SMStorageDebug(@"SQL:%@", sql);
        [db executeUpdate:sql];
    }
}

- (void)readFromClass:(Class)clazz
            condition:(NSString* )condition
           completion:(void(^)(NSArray* objects))completion {
    [self inDatabase:^(FMDatabase *db) {
        if (![self isTableExist:clazz database:db]) {
            if (completion) completion(nil);
        } else {
            NSString* sql = [SMSQLGrammer sqlForQuery:clazz condition:condition];
            SMStorageDebug(@"SQL:%@", sql);
            FMResultSet* rs = [db executeQuery:sql];
            NSMutableArray* array = [NSMutableArray array];
            NSArray* columns = [[rs columnNameToIndexMap] allKeys];
            
            while ([rs next]) {
                NSObject* obj = [[clazz alloc] init];
                for (NSString* col in columns) {
                    NSString* var = [clazz sms_variableOfLowercaseVariable:col];
                    Class cls = [clazz sms_classOfVariable:var];
                    NSString *customClassName = [clazz sms_objectTypeOfVariable:var];
                    if (!cls && [NSClassFromString(customClassName) respondsToSelector:@selector(sms_objectForSQL:objectType:)]) {
                        cls = NSClassFromString(customClassName);
                    }
                    id value = [cls sms_objectForSQL:[rs stringForColumn:col] objectType:[clazz sms_objectTypeOfVariable:var]];
                    if (cls && value) {
                        [obj setValue:value forKey:var];
                    }
                }
                [array addObject:obj];
            }
            [rs close];
            if (completion) completion(array);
        }
    }];
}

- (void)deleteFromClass:(Class)clazz
              condition:(NSString* )condition
             completion:(void(^)())completion {
    [self inDatabase:^(FMDatabase *db) {
        if ([self isTableExist:clazz database:db]) {
            NSString* sql = [SMSQLGrammer sqlForDelete:clazz condition:condition];
            SMStorageDebug(@"SQL:%@", sql);
            [db executeUpdate:sql];
        }
        if (completion) completion();
    }];
}

- (BOOL)deleteObject:(NSObject* )object database:(FMDatabase* )db {
    if ([self isExistForObject:object database:db]) {
        NSString* sql = [SMSQLGrammer sqlForDelete:object];
        return [db executeUpdate:sql];
    } else {
        return YES;
    }
}

- (void)deleteObject:(NSObject* )object completion:(void(^)())completion {
    if ([object isKindOfClass:[NSArray class]]) {
        [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
            NSArray* objects = (NSArray* )object;
            for (NSObject* obj in objects) {
                [self deleteObject:obj database:db];
            }
            if (completion) completion();
        }];
    } else {
        [self inDatabase:^(FMDatabase *db) {
            [self deleteObject:object database:db];
            if (completion) completion();
        }];
    }
}

- (void)clearFromClass:(Class)clazz completion:(void(^)())completion {
    [self inDatabase:^(FMDatabase *db) {
        if ([self isTableExist:clazz database:db]) {
            NSString* sql = [SMSQLGrammer sqlForDeleteAll:clazz];
            SMStorageDebug(@"SQL:%@", sql);
            [db executeUpdate:sql];
        }
        if (completion) completion();
    }];
}

- (BOOL)writeObject:(NSObject* )object database:(FMDatabase* )db {
    if (![self isExistForObject:object database:db]) {
        NSString* sql = [SMSQLGrammer sqlForInsert:object];
        SMStorageDebug(@"SQL:%@", sql);
        return [db executeUpdate:sql];
    } else {
        NSString* sql = [SMSQLGrammer sqlForUpdate:object];
        SMStorageDebug(@"SQL:%@", sql);
        return [db executeUpdate:sql];
    }
}

- (void)writeObject:(NSObject* )object completion:(void(^)())completion {
    if ([object isKindOfClass:[NSArray class]]) {
        NSArray* objects = (NSArray*)object;
        [self inTransaction:^(FMDatabase *db, BOOL *rollback) {
            for (NSObject* obj in objects) {
                [self updateTableInfo:[obj class] database:db];
                if (![self writeObject:obj database:db]) {
                    *rollback = YES;
                    break;
                }
            }
            if (completion) {
                completion();
            }
        }];
    } else {
        [self inDatabase:^(FMDatabase *db) {
            [self updateTableInfo:[object class] database:db];
            [self writeObject:object database:db];
            if (completion) completion();
        }];
    }
}

@end

