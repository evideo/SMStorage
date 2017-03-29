//
//  NSValue+SMSQLGrammer.m
//  SMStorageExample
//
//  Created by StarNet on 3/29/17.
//  Copyright © 2017 smallmuou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSValue+SMSQLGrammer.h"
#import "SMSQLGrammer.h"

@implementation NSValue (SMSQLGrammer)
+ (instancetype)sms_objectForSQL:(NSString* )sql objectType:(NSString* )type {
    if ([type isEqualToString:@"CGPoint"]) {
        return [NSValue valueWithCGPoint:CGPointFromString(sql)];
    } else if ([type isEqualToString:@"CGSize"]) {
        return [NSValue valueWithCGSize:CGSizeFromString(sql)];
    } else if ([type isEqualToString:@"CGRect"]) {
        return [NSValue valueWithCGRect:CGRectFromString(sql)];
    } else if ([type isEqualToString:@"CGVector"]) {
        return [NSValue valueWithCGVector:CGVectorFromString(sql)];
    } else if ([type isEqualToString:@"CGAffineTransform"]) {
        return [NSValue valueWithCGAffineTransform:CGAffineTransformFromString(sql)];
    } else if ([type isEqualToString:@"UIEdgeInsets"]) {
        return [NSValue valueWithUIEdgeInsets:UIEdgeInsetsFromString(sql)];
    } else if ([type isEqualToString:@"UIOffset"]) {
        return [NSValue valueWithUIOffset:UIOffsetFromString(sql)];
    } else if ([type isEqualToString:@"NSRange"]) {
        return [NSValue valueWithRange:NSRangeFromString(sql)];
    }
    return nil;
}

- (NSString* )sms_sqlValue {
    NSString* type = formateObjectType([self objCType]);
    
    if ([type isEqualToString:@"CGPoint"]) {
        return [NSStringFromCGPoint([self CGPointValue]) sms_sqlValue];
    } else if ([type isEqualToString:@"CGSize"]) {
        return [NSStringFromCGSize([self CGSizeValue]) sms_sqlValue];
    } else if ([type isEqualToString:@"CGRect"]) {
        return [NSStringFromCGRect([self CGRectValue]) sms_sqlValue];
    } else if ([type isEqualToString:@"CGVector"]) {
        return [NSStringFromCGVector([self CGVectorValue]) sms_sqlValue];
    } else if ([type isEqualToString:@"CGAffineTransform"]) {
        return [NSStringFromCGAffineTransform([self CGAffineTransformValue]) sms_sqlValue];
    } else if ([type isEqualToString:@"UIEdgeInsets"]) {
        return [NSStringFromUIEdgeInsets([self UIEdgeInsetsValue]) sms_sqlValue];
    } else if ([type isEqualToString:@"UIOffset"]) {
        return [NSStringFromUIOffset([self UIOffsetValue]) sms_sqlValue];
    } else if ([type isEqualToString:@"NSRange"]) {
        return [NSStringFromRange([self rangeValue]) sms_sqlValue];
    }
    
    return nil;}
@end
