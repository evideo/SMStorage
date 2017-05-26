//
//  Student.m
//  SMStorageExample
//
//  Created by StarNet on 3/29/17.
//  Copyright © 2017 smallmuou. All rights reserved.
//

#import "Student.h"
#import "NSObject+ObjectMap.h"


@implementation School


+ (instancetype)sms_objectForSQL:(NSString* )sql objectType:(NSString* )type {
    NSData *data = [sql dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    School *school = [School objectOfClass:NSStringFromClass([School class]) fromJSON:json];
    return school;
}

- (NSString* )sms_sqlValue {
    NSString *string = [self JSONString];
    return [NSString stringWithFormat:@"'%@'", [string stringByReplacingOccurrencesOfString:@"'" withString:@"''"]];
}

@end

@implementation People

@end

@implementation Student

- (instancetype)init
{
    self = [super init];
    if (self) {
        _test = @"llllll";
        flag = 3.0;
    }
    return self;
}

+ (instancetype)student {
    return [[Student alloc] init];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"code=%@, name=%@, age=%d, school=%@, test=%@, flag=%f", self.code, self.name, self.age, self.schoolName, _test, flag];
}
@end
