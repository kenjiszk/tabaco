//
//  ViewController.h
//  tabaco
//
//  Created by kenjiszk on 2014/05/24.
//  Copyright (c) 2014年 jp.babyry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "NADView.h"
#import "Config.h"

@interface ViewController : UIViewController<NADViewDelegate>
{
}

@property (nonatomic, retain) NADView * nadView;

@property NSArray *commentsArray;
@property int queryLimit;

@end
