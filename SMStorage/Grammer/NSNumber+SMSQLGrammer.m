//
//  NSNumber+SMSQLGrammer.m
//  SMStorageExample
//
//  Created by StarNet on 3/29/17.
//  Copyright © 2017 smallmuou. All rights reserved.
//

#import "NSNumber+SMSQLGrammer.h"

@implementation NSNumber (SMSQLGrammer)
+ (instancetype)sms_objectForSQL:(NSString* )sql objectType:(NSString* )type {
    NSNumberFormatter *fmt = [[NSNumberFormatter alloc] init];
    return [fmt numberFromString:sql];
}

- (NSString* )sms_sqlValue {
    return [self stringValue];
}

@end
