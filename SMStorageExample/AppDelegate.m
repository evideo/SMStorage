//
//  AppDelegate.m
//  SMStorageExample
//
//  Created by StarNet on 3/28/17.
//  Copyright © 2017 smallmuou. All rights reserved.
//

#import "AppDelegate.h"
#import "SMStorage.h"
#import "Student.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    [Student sms_clear:nil];
    [Student sms_setPrimaryKey:@"code"];
    
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i < 10000; i ++) {
        Student* stu = [[Student alloc] init];
        stu.code = [NSString stringWithFormat:@"%d", i+1];
        stu.name = @"xu";
        stu.age = 12;
        stu.schoolName = @"No. 22";
        stu.testDict = @{@"1":@"11"};
        stu.school = [School new];
        stu.school.name = @"FZU";
        stu.school.address = @"Fuzhou, FuJian, CN";
        Teacher *teacher = [Teacher new];
        teacher.name = @"Warren";
        teacher.age = 44;
        teacher.address = @"CA, USA";
        stu.teacher = teacher;
        [array addObject:stu];
    }
    NSDate *time1 = [NSDate date];
    [[SMStorage defaultStorage] writeObject:array completion:^{
        double timeCost = [[NSDate date] timeIntervalSinceDate:time1];
        NSLog(@"write time cost:%f s", timeCost);
        NSDate *time2 = [NSDate date];
        [Student sms_read:nil completion:^(NSArray *objects) {
            double timeCost2 = [[NSDate date] timeIntervalSinceDate:time2];
            NSLog(@"read time cost:%f s", timeCost2);
            for (Student *item in objects) {
                NSLog(@"%@", item);
                
            }
        }];
    }];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
