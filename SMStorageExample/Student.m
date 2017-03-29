//
//  Student.m
//  SMStorageExample
//
//  Created by StarNet on 3/29/17.
//  Copyright © 2017 smallmuou. All rights reserved.
//

#import "Student.h"

@implementation Student

- (NSString *)description
{
    return [NSString stringWithFormat:@"code=%@, name=%@, age=%d, school=%@", self.code, self.name, self.age, self.schoolName];
}
@end
