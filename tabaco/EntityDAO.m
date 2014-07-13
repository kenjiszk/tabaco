//
//  EntityDAO.m
//  tabaco
//
//  Created by kenjiszk on 2014/05/24.
//  Copyright (c) 2014年 jp.babyry. All rights reserved.
//

#import "EntityDAO.h"
#import "AppDelegate.h"
#import "Entity.h"
#import <CoreData/CoreData.h>

@implementation EntityDAO

- (void)setEntity:(NSString *) key value:(NSNumber *) value
{
    // UIApplicationクラスは、アプリケーション全体を管理するクラスで、１アプリケーションには必ず１つのUIApplicationが存在します。
    // sharedApplication クラスメソッドを呼び出すことでインスタンスを取得することができます。
    // ManagedObject データを表すObject
    // ManagedObjectContext オブジェクトの集合体を管理、オブジェクトの挿入/更新/削除
    // PersistentStoreCooridator オブジェクトの永続化、永続ストアへマッピング
    // FetchdResultsController オブジェクトの変更を監視 TableViewの表示と整合性を保つ
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];

    // NSFetchRequestのインスタンスは、永続ストアからデータを取得ために使用する検索基準を記述します。
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entityDes = [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entityDes];
    
    // NSPredicate は、NSArray で要素をフィルターするための条件を表したり、Core Data で取ってくるデータの条件を表すためのクラスです。
    // 今回はデータは一つなので絞り込みなどはしない
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"last_modified = %@", last_modified];
    //[fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *result = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(nil != error){
        NSLog(@"EntityDAO#setEntityList error %@, %@", error, [error userInfo]);
    }
    
    int resultCnt = [result count];
    if(0 == resultCnt){
        Entity *item = [NSEntityDescription insertNewObjectForEntityForName:@"Entity" inManagedObjectContext:managedObjectContext];
        if ([key isEqualToString:@"last_modified"]) {
            item.last_modified = value;
        } else if ([key isEqualToString:@"user_id"]) {
            item.user_id = value;
        }
    } else {
        Entity *item = [result objectAtIndex:0];
        if ([key isEqualToString:@"last_modified"]) {
            item.last_modified = value;
        } else if ([key isEqualToString:@"user_id"]) {
            item.user_id = value;
        } else if ([key isEqualToString:@"today_tax"]) {
            item.today_tax = value;
        } else if ([key isEqualToString:@"total_tax"]) {
            item.total_tax = value;
        }
    }
    
    BOOL ret = [managedObjectContext save:&error];
    if(!ret){
        NSLog(@"EntityDAO#setEntityList error %@, %@", error, [error userInfo]);
    }
}

- (NSNumber *)getEntity:(NSString *) key
{
    AppDelegate *appDeletage = [[UIApplication sharedApplication]delegate];
    NSManagedObjectContext *managedObjectContext = [appDeletage managedObjectContext];
     
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entityDes;

    entityDes = [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entityDes];
     
    NSSortDescriptor *sortDes = [[NSSortDescriptor alloc]initWithKey:@"last_modified" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc]initWithObjects:sortDes, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
     
    NSError *error = nil;
    NSArray *itemList = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(nil != error){
        NSLog(@"EntityDAO#getSampleEntityItemList error %@, %@", error, [error userInfo]);
    }
    
    if([itemList count] == 0) {
        NSLog(@"no itemList.");
        return [NSNumber numberWithInt:0];
    } else if ([key isEqualToString:@"last_modified"]) {
        Entity *item = itemList[0];
        return item.last_modified;
    } else if ([key isEqualToString:@"user_id"]) {
        Entity *item = itemList[0];
        return item.user_id;
    } else if ([key isEqualToString:@"today_tax"]) {
        Entity *item = itemList[0];
        return item.today_tax;
    } else if ([key isEqualToString:@"total_tax"]) {
        Entity *item = itemList[0];
        return item.total_tax;
    } else {
        NSLog(@"else.");
        return [NSNumber numberWithInt:0];
    }
}

@end

