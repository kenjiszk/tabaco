//
//  EntityDAO.h
//  tabaco
//
//  Created by kenjiszk on 2014/05/24.
//  Copyright (c) 2014年 jp.babyry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EntityDAO : NSObject
{
}

- (void)setEntity:(NSString *) key value:(NSNumber *) value;
- (NSNumber *)getEntity:(NSString *) key;

@end
