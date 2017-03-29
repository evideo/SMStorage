//
//  NSDate+SMSQLGrammer.m
//  SMStorageExample
//
//  Created by StarNet on 3/29/17.
//  Copyright © 2017 smallmuou. All rights reserved.
//

#import "NSDate+SMSQLGrammer.h"

@implementation NSDate (SMSQLGrammer)
+ (instancetype)sms_objectForSQL:(NSString* )sql objectType:(NSString* )type {
    return [NSDate dateWithTimeIntervalSince1970:[sql doubleValue]];
}

- (NSString* )sms_sqlValue {
    return [NSString stringWithFormat:@"%f", [self timeIntervalSince1970]];
}
@end
