//
//  Entity.h
//  tabaco
//
//  Created by kenjiszk on 2014/05/24.
//  Copyright (c) 2014年 jp.babyry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Entity : NSManagedObject

@property (nonatomic, retain) NSNumber * last_modified;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) NSNumber * today_tax;
@property (nonatomic, retain) NSNumber * total_tax;

@end
