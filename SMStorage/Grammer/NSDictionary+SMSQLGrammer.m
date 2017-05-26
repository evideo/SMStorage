//
//  NSDictionary+SMSQLGrammer.m
//  SMStorageExample
//
//  Created by ashoka on 25/05/2017.
//  Copyright © 2017 smallmuou. All rights reserved.
//

#import "NSDictionary+SMSQLGrammer.h"

@implementation NSDictionary (SMSQLGrammer)

+ (instancetype)sms_objectForSQL:(NSString* )sql objectType:(NSString* )type {
    NSData *data = [sql dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    return json;
}

- (NSString* )sms_sqlValue {
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [NSString stringWithFormat:@"'%@'", [jsonStr stringByReplacingOccurrencesOfString:@"'" withString:@"''"]];
}

@end
