//
//  Student.h
//  SMStorageExample
//
//  Created by StarNet on 3/29/17.
//  Copyright © 2017 smallmuou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface People : NSObject

@property (nonatomic, strong) NSString*  name;
@property (nonatomic, assign) int age;

@end


@interface Student : People {
    NSString* _test;
    double flag;
}

+ (instancetype)student;

@property (nonatomic, strong) NSString* code;
@property (nonatomic, strong) NSString* schoolName;

@end
