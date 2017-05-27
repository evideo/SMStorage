//
//  Student.h
//  SMStorageExample
//
//  Created by StarNet on 3/29/17.
//  Copyright © 2017 smallmuou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMSQLGrammer.h"

@class Teacher;

@interface School : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *address;

@end

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

@property (nonatomic, strong) School *school;

@property (nonatomic, strong) NSDictionary *testDict;

@property (nonatomic, strong) Teacher *teacher;



@end

@interface Teacher:NSObject<NSCoding>

@property (nonatomic, strong) NSString *name;

@property (nonatomic, assign) NSInteger age;

@property (nonatomic, strong) NSString *address;

@end
