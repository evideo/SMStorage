//
//  Student.m
//  SMStorageExample
//
//  Created by StarNet on 3/29/17.
//  Copyright © 2017 smallmuou. All rights reserved.
//

#import "Student.h"


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
