//
//  SMSQLGrammer.m
//  SMStorageExample
//
//  Created by StarNet on 3/29/17.
//  Copyright © 2017 smallmuou. All rights reserved.
//

#import "SMSQLGrammer.h"
#import "SMStorage.h"
#import <objc/runtime.h>

NSString* formateObjectType(const char* objcType) {
    if (!objcType || !strlen(objcType)) return nil;
    NSString* type = [NSString stringWithCString:objcType encoding:NSUTF8StringEncoding];
    
    switch (objcType[0]) {
        case '@':
            type = [type substringWithRange:NSMakeRange(2, strlen(objcType)-3)];
            break;
        case '{':
            type = [type substringWithRange:NSMakeRange(1, strchr(objcType, '=')-objcType-1)];
            break;
        default:
            break;
    }
    return type;
}


#define SMS_TYPEMAP(__rawType, __objcType, __sqliteType) __rawType:@[__objcType, __sqliteType]
#define SMS_ClassIndex   (0)
#define SMS_SQLTypeIndex (1)

@implementation NSObject (SMSQLGrammer)

+ (NSDictionary* )sms_typeMapper {
    return @{
             SMS_TYPEMAP(@"c",                   @"NSNumber",        @"INTEGER"),\
             SMS_TYPEMAP(@"i",                   @"NSNumber",        @"INTEGER"),\
             SMS_TYPEMAP(@"s",                   @"NSNumber",        @"INTEGER"),\
             SMS_TYPEMAP(@"l",                   @"NSNumber",        @"INTEGER"),\
             SMS_TYPEMAP(@"q",                   @"NSNumber",        @"INTEGER"),\
             SMS_TYPEMAP(@"C",                   @"NSNumber",        @"INTEGER"),\
             SMS_TYPEMAP(@"I",                   @"NSNumber",        @"INTEGER"),\
             SMS_TYPEMAP(@"S",                   @"NSNumber",        @"INTEGER"),\
             SMS_TYPEMAP(@"L",                   @"NSNumber",        @"INTEGER"),\
             SMS_TYPEMAP(@"Q",                   @"NSNumber",        @"INTEGER"),\
             SMS_TYPEMAP(@"f",                   @"NSNumber",        @"REAL"),\
             SMS_TYPEMAP(@"d",                   @"NSNumber",        @"REAL"),\
             SMS_TYPEMAP(@"B",                   @"NSNumber",        @"INTEGER"),\
             SMS_TYPEMAP(@"NSString",            @"NSString",        @"TEXT"),\
             SMS_TYPEMAP(@"NSMutableString",     @"NSMutableString", @"TEXT"),\
             SMS_TYPEMAP(@"NSDate",              @"NSDate",          @"REAL"),\
             SMS_TYPEMAP(@"NSNumber",            @"NSNumber",        @"REAL"),\
             SMS_TYPEMAP(@"CGPoint",             @"NSValue",         @"TEXT"),\
             SMS_TYPEMAP(@"CGSize",              @"NSValue",         @"TEXT"),\
             SMS_TYPEMAP(@"CGRect",              @"NSValue",         @"TEXT"),\
             SMS_TYPEMAP(@"CGVector",            @"NSValue",         @"TEXT"),\
             SMS_TYPEMAP(@"CGAffineTransform",   @"NSValue",         @"TEXT"),\
             SMS_TYPEMAP(@"UIEdgeInsets",        @"NSValue",         @"TEXT"),\
             SMS_TYPEMAP(@"UIOffset",            @"NSValue",         @"TEXT"),\
             SMS_TYPEMAP(@"NSRange",             @"NSValue",         @"TEXT"),\
             };
}

+ (BOOL)sms_hasVariable:(NSString* )variable {
    return variable.length?([self sms_variables][variable]?YES:NO):NO;
}

// variables:type
static NSMutableDictionary* variablesCache;
+ (NSDictionary* )sms_variables {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        variablesCache = [NSMutableDictionary dictionary];
    });
    
    NSMutableDictionary* variables;
    
    //check cache
    NSString* key = NSStringFromClass([self class]);
    variables = variablesCache[key];
    if (variables) return variables;
    
    //generate
    variables = [NSMutableDictionary dictionary];
    
    unsigned int numIvars = 0;
    Class clazz = [self class];
    
    do {
        Ivar * ivars = class_copyIvarList(clazz, &numIvars);
        if (ivars) {
            for(int i = 0; i < numIvars; i++) {
                Ivar thisIvar = ivars[i];
                const char *type = ivar_getTypeEncoding(thisIvar);
                NSString* akey = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
                if ([akey hasPrefix:@"_"]) {
                    akey = [akey substringFromIndex:1];
                }
                
                NSString* objectType = formateObjectType(type);
                variables[akey] = objectType;
            }
            free(ivars);
        }
        
        clazz = class_getSuperclass(clazz);
    } while(clazz && strcmp(object_getClassName(clazz), "NSObject"));
    
    variablesCache[key] = variables;
    NSLog(@"variable: %@", variables);
    return variables;
}

static NSMutableDictionary* lowercaseVariablesCache;
//lowercase var: var
+ (NSDictionary* )sms_lowercaseVariables {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lowercaseVariablesCache = [NSMutableDictionary dictionary];
    });
    
    NSString* key = NSStringFromClass([self class]);
    if (lowercaseVariablesCache[key]) {
        return lowercaseVariablesCache[key];
    }
    
    NSMutableDictionary* map = [NSMutableDictionary dictionary];
    for (NSString* var in [self sms_variables]) {
        map[[var lowercaseString]] = var;
    }
    
    lowercaseVariablesCache[key] = map;
    return map;
}

+ (NSString* )sms_tableName {
    return NSStringFromClass([self class]);
}

+ (Class)sms_classOfVariable:(NSString* )variable {
    NSString* name = [self sms_typeMapper][[self sms_variables][variable]][SMS_ClassIndex];
    return NSClassFromString(name);
}

+ (NSString* )sms_variableOfLowercaseVariable:(NSString* )variable {
    return [self sms_lowercaseVariables][variable];
}

+ (NSString* )sms_sqlTypeOfVariable:(NSString* )variable {
    return [self sms_typeMapper][[self sms_variables][variable]][SMS_SQLTypeIndex];
}

+ (NSString* )sms_objectTypeOfVariable:(NSString* )variable {
    return [self sms_variables][variable];
}

+ (instancetype)sms_objectForSQL:(NSString* )sql objectType:(NSString* )type {
    return nil;
}

- (NSString* )sms_sqlValue {
    return nil;
}

@end

#pragma mark - SMSQLGrammer
@implementation SMSQLGrammer

+ (NSString* )sqlForTableExist:(Class)clazz {
    return [NSString stringWithFormat:@"SELECT 1 FROM sqlite_master where type='table' and name='%@'", [clazz sms_tableName]];
}

+ (NSString* )sqlForTableInfo:(Class)clazz {
    return [NSString stringWithFormat:@"PRAGMA table_info(%@)", [clazz sms_tableName]];
}

+ (NSString* )sqlForCreateTable:(Class)clazz {
    NSString* tableName = [clazz sms_tableName];
    NSString* primaryKey = [clazz sms_primaryKey];
    
    //append variable to sql
    NSMutableString* columns = [NSMutableString string];
    BOOL beAssignPrimaryKey = YES;
    
    NSDictionary* variables = [clazz sms_variables];
    NSDictionary* typeMapper = [clazz sms_typeMapper];
    
    BOOL first = YES;
    for (NSString* var in [variables allKeys]) {
        NSArray* map = typeMapper[variables[var]];
        if (!map) continue;
        
        if (!first) [columns appendString:@","];
        first = NO;
        
        NSString* sqlType = map[SMS_SQLTypeIndex];
        [columns appendFormat:@"%@ %@", var, sqlType];
        if (beAssignPrimaryKey && [primaryKey isEqualToString:var]) {
            [columns appendFormat:@" PRIMARY KEY"];
            beAssignPrimaryKey = NO;
        }
        
        if ([sqlType isEqualToString:@"INTEGER"]) {
            [columns appendFormat:@" DEFAULT 0"];
        } else if ([sqlType isEqualToString:@"REAL"]) {
            [columns appendFormat:@" DEFAULT 0.0"];
        }
    }
    
    return [NSString stringWithFormat:@"CREATE TABLE %@(%@)", tableName, columns];
}

// only support add
+ (NSArray* )sqlForAlter:(Class)clazz exceptColumns:(NSDictionary* )exceptColumns {
    NSDictionary* variables = [clazz sms_variables];
    NSDictionary* typeMapper = [clazz sms_typeMapper];
    NSMutableArray* array = [NSMutableArray array];
    NSString* tableName = [clazz sms_tableName];
    
    for (NSString* var in [variables allKeys]) {
        NSArray* map = typeMapper[variables[var]];
        if (!map) continue;
        if (!exceptColumns[var]) {
            [array addObject:[NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ %@", tableName, var, map[SMS_SQLTypeIndex]]];
        }
    }
    
    return [NSArray arrayWithArray:array];
}

+ (NSString* )sqlForInsert:(NSObject* )object {
    NSString* tableName = [[object class] sms_tableName];
    NSMutableString* columns = [NSMutableString string];
    NSMutableString* values = [NSMutableString string];
    NSDictionary* typeMapper = [[object class] sms_typeMapper];
    
    NSDictionary* varables = [[object class] sms_variables];
    BOOL first = YES;
    for (NSString* var in [varables allKeys]) {
        NSArray* map = typeMapper[varables[var]];
        if (!map) continue;
        
        NSString* value = [[object valueForKey:var] sms_sqlValue];
        if (value) {
            if (!first) {
                [columns appendString:@","];
                [values appendString:@","];
            }
            first = NO;
            [columns appendString:var];
            [values appendString:value?value:@""];
        }
    }
    
    return [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)", tableName, columns, values];
}

//need primary key
+ (NSString* )sqlForCheck:(NSObject* )object {
    NSString* tableName = [[object class] sms_tableName];
    NSString* primaryKey = [[object class] sms_primaryKey];
    if (primaryKey) {
        NSString* value = [[object valueForKey:primaryKey] sms_sqlValue];
        return [NSString stringWithFormat:@"SELECT 1 FROM %@ WHERE %@=%@", tableName, primaryKey, value];
    }
    return nil;
}

//need primary key
+ (NSString* )sqlForUpdate:(NSObject* )object {
    NSString* tableName = [[object class] sms_tableName];
    NSMutableString* updateString = [NSMutableString string];
    NSDictionary* typeMapper = [[object class] sms_typeMapper];
    NSString* primaryKey = [[object class] sms_primaryKey];
    
    if (primaryKey) {
        NSDictionary* variables = [[object class] sms_variables];
        BOOL first = YES;
        
        for (NSString* var in [variables allKeys]) {
            NSArray* map = typeMapper[variables[var]];
            if (!map) continue;
            
            NSString* value = [[(NSObject*)object valueForKey:var] sms_sqlValue];
            if (value) {
                if (!first) {
                    [updateString appendString:@","];
                }
                first = NO;
                [updateString appendString:[NSString stringWithFormat:@"%@=%@", var, value]];
            }
        }
        
        return [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@=%@", tableName, updateString, primaryKey, [[object valueForKey:primaryKey] sms_sqlValue]];
    } else {
        return nil;
    }
}

+ (NSString* )sqlForDelete:(NSObject* )object {
    NSString* primaryKey = [[object class] sms_primaryKey];
    if (primaryKey) {
        NSString* tableName = [[object class] sms_tableName];
        return [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = %@", tableName, primaryKey, [[(NSObject*)object valueForKey:primaryKey] sms_sqlValue]];
    } else {
        return nil;
    }
}

+ (NSString* )sqlForDeleteAll:(Class)clazz {
    return [NSString stringWithFormat:@"DELETE FROM %@", [clazz sms_tableName]];
}

+ (NSString* )sqlForDelete:(Class)clazz condition:(NSString* )condition {
    if (!condition.length) {
        return [NSString stringWithFormat:@"DELETE FROM %@", [clazz sms_tableName]];
    } else {
        return [NSString stringWithFormat:@"DELETE FROM %@ %@", [clazz sms_tableName], condition];
    }
}

+ (NSString* )sqlForQuery:(Class)clazz condition:(NSString* )condition {
    if (!condition.length) {
        return [NSString stringWithFormat:@"SELECT * FROM %@", [clazz sms_tableName]];
    } else {
        return [NSString stringWithFormat:@"SELECT * FROM %@ %@", [clazz sms_tableName], condition];
    }
}

+ (NSString* )sqlForCount:(Class)clazz condition:(NSString* )condition {
    if (!condition.length) {
        return [NSString stringWithFormat:@"SELECT count(1) FROM %@", [clazz sms_tableName]];
    } else {
        return [NSString stringWithFormat:@"SELECT count(1) FROM %@ %@", [clazz sms_tableName], condition];
    }
}


@end
