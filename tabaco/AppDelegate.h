//
//  AppDelegate.h
//  tabaco
//
//  Created by kenjiszk on 2014/05/24.
//  Copyright (c) 2014年 jp.babyry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
}

@property (strong, nonatomic) NSNumber *userId;
@property (strong, nonatomic) NSNumber *tabacoRate;
@property (strong, nonatomic) NSNumber *todayTax;
@property (strong, nonatomic) NSNumber *totalTax;
@property (strong, nonatomic) NSNumber *todayRankingNum;
@property (strong, nonatomic) NSNumber *totalRankingNum;

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
