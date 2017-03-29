//
//  SMStorage.h
//  SMStorageExample
//
//  Created by StarNet on 3/29/17.
//  Copyright © 2017 smallmuou. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG
#define __FILE_WITHOUT_PATH__ (strrchr(__FILE__, '/') ? strrchr(__FILE__, '/') + 1 : __FILE__)

#define SMStorageDebug(fmt, ...) \
do {\
NSLog(@"SMSTORAGE==> " fmt, ##__VA_ARGS__);\
} while(0);

#else
#define SMStorageDebug(fmt, ...);
#endif

@interface SMStorage : NSObject

+ (instancetype)defaultStorage;

- (void)readFromClass:(Class)clazz condition:(NSString* )condition completion:(void(^)(NSArray* objects))completion;
- (void)deleteFromClass:(Class)clazz condition:(NSString* )condition completion:(void(^)())completion;
- (void)deleteObject:(NSObject* )object completion:(void(^)())completion;
- (void)clearFromClass:(Class)clazz completion:(void(^)())completion;
- (void)writeObject:(NSObject* )object completion:(void(^)())completion;

@end

#pragma mark - NSObject (SMStorage)

@interface NSObject (SMStorage)

/**
 * get primary key.
 */
+ (NSString* )sms_primaryKey;

/**
 * If you want to ensure that the object uniqueness, you need assign a variable to be primary key.
 */
+ (void)sms_setPrimaryKey:(NSString* )variable;

/**
 * read objects from storage.
 *
 * @param condition the condition to filter object, the grammar same to sql, like follow:
 *  "where id=2 and name='rb'"
 *  "order by id desc"
 *  "limit 0, 100"
 */
+ (void)sms_read:(NSString* )condition completion:(void(^)(NSArray* objects))completion;

/**
 * delete object from storage
 *
 * @param condition the condition to filter object, the grammar same to sql
 */
+ (void)sms_delete:(NSString* )condition completion:(void(^)())completion;

/**
 * clean objects from storage
 */
+ (void)sms_clear:(void(^)())completion;

/**
 * write objects to storage
 */
- (void)sms_write:(void(^)())completion;


@end
