//
//  CommunicationViewController.h
//  tabaco
//
//  Created by Kenji Suzuki on 2014/07/13.
//  Copyright (c) 2014年 jp.babyry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "NADView.h"
#import "Config.h"
#import "MBProgressHUD.h"

@interface CommunicationViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, NADViewDelegate>

@property (nonatomic, retain) NADView * nadView;

@property (strong, nonatomic) IBOutlet UIView *communicationView;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UITextView *textView;
//@property (strong, nonatomic) IBOutlet UITextField *textField;
- (IBAction)sendButton:(id)sender;
- (IBAction)backButton:(id)sender;

@property BOOL keyboardObserving;
@property int defaultFieldY;

@property NSArray *commentsArray;

@property int queryLimit;

@property NSTimer *tm;

@property MBProgressHUD *hud;

@property int isTimerRunning;

@end
