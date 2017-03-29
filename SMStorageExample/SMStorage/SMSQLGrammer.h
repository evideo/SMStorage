//
//  SMSQLGrammer.h
//  SMStorageExample
//
//  Created by StarNet on 3/29/17.
//  Copyright © 2017 smallmuou. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString* formateObjectType(const char* objcType);

#pragma mark - NSObject (SMSQLGrammer)

@interface NSObject (SMSQLGrammer)

+ (BOOL)sms_hasVariable:(NSString* )variable;

+ (NSString* )sms_tableName;

+ (Class)sms_classOfVariable:(NSString* )variable;

+ (NSString* )sms_variableOfLowercaseVariable:(NSString* )variable;

+ (NSString* )sms_sqlTypeOfVariable:(NSString* )variable;


+ (NSString* )sms_objectTypeOfVariable:(NSString* )variable;

+ (instancetype)sms_objectForSQL:(NSString* )sql objectType:(NSString* )type;

- (NSString* )sms_sqlValue;

@end

#pragma mark - SMSQLGrammer

@interface SMSQLGrammer : NSObject
+ (NSString* )sqlForTableExist:(Class)clazz;
+ (NSString* )sqlForTableInfo:(Class)clazz;
+ (NSString* )sqlForCreateTable:(Class)clazz;
+ (NSArray* )sqlForAlter:(Class)clazz exceptColumns:(NSDictionary* )exceptColumns;
+ (NSString* )sqlForInsert:(NSObject* )object;
+ (NSString* )sqlForCheck:(NSObject* )object;
+ (NSString* )sqlForUpdate:(NSObject* )object;
+ (NSString* )sqlForDelete:(NSObject* )object;
+ (NSString* )sqlForDeleteAll:(Class)clazz;
+ (NSString* )sqlForDelete:(Class)clazz condition:(NSString* )condition;
+ (NSString* )sqlForQuery:(Class)clazz condition:(NSString* )condition;
+ (NSString* )sqlForCount:(Class)clazz condition:(NSString* )condition;

@end
