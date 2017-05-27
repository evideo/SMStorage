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

- (NSString *)description {
    return [NSString stringWithFormat:@"name:%@ address:%@", self.name, self.address];
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
    return [NSString stringWithFormat:@"code=%@, name=%@, age=%d, school=%@, test=%@, flag=%f teacher=%@", self.code, self.name, self.age, self.school, _test, flag, self.teacher];
}
@end

@implementation Teacher

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.address forKey:@"address"];
    [aCoder encodeInteger:self.age forKey:@"age"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self.name = [aDecoder decodeObjectForKey:@"name"];
    self.age = [aDecoder decodeIntegerForKey:@"age"];
    self.address = [aDecoder decodeObjectForKey:@"address"];
    return self;
}

- (NSString *)sms_sqlValue {
    //json
//    return  [[self JSONString] sms_sqlValue];
    //Base64
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSString *base64Str = [data base64EncodedStringWithOptions:0];
    return [base64Str sms_sqlValue];
}

+ (instancetype)sms_objectForSQL:(NSString *)sql objectType:(NSString *)type {
    //json
//    NSData *data1 = [sql dataUsingEncoding:NSUTF8StringEncoding];
//    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data1 options:NSJSONReadingMutableContainers error:nil];
//    return [Teacher objectOfClass:NSStringFromClass([Teacher class]) fromJSON:json];
    //base64
    NSData *data = [[NSData alloc] initWithBase64EncodedString:sql options:0];
    Teacher *teacher = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return teacher;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"(name:%@ age:%ld, address:%@)", self.name, self.age, self.address];
}

@end
