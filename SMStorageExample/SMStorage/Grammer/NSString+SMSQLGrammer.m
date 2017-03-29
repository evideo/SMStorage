//
//  NSString+SMSQLGrammer.m
//  SMStorageExample
//
//  Created by StarNet on 3/29/17.
//  Copyright © 2017 smallmuou. All rights reserved.
//

#import "NSString+SMSQLGrammer.h"

@implementation NSString (SMSQLGrammer)
+ (instancetype)sms_objectForSQL:(NSString* )sql objectType:(NSString* )type {
    return sql?[NSString stringWithString:sql]:nil;
}

- (NSString* )sms_sqlValue {
    return [NSString stringWithFormat:@"'%@'", [self stringByReplacingOccurrencesOfString:@"'" withString:@"''"]];
}

@end
