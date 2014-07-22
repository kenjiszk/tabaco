//
//  ViewController.m
//  tabaco
//
//  Created by kenjiszk on 2014/05/24.
//  Copyright (c) 2014年 jp.babyry. All rights reserved.
//

#import "ViewController.h"
#import "EntityDAO.h"
#import "Entity.h"
#import <Parse/Parse.h>
#import "CommunicationViewController.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIButton *smokeButton;
@property (strong, nonatomic) IBOutlet UILabel *centerCircle;
@property (strong, nonatomic) IBOutlet UIButton *taxButton;
@property (strong, nonatomic) IBOutlet UILabel *todayTaxLabel;
@property (strong, nonatomic) IBOutlet UILabel *todayRanking;
@property (strong, nonatomic) IBOutlet UILabel *totalTaxLabel;
@property (strong, nonatomic) IBOutlet UILabel *totalRanking;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.nadView = [[NADView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, 320, 50)];
    self.nadView.backgroundColor = [UIColor blackColor];
    [self.nadView setIsOutputLog:NO];
    [self.nadView setNendID:[Config getNendID] spotID:[Config getSpotID]];
    [self.nadView setDelegate:self];
    [self.nadView load];
    [self.view addSubview:self.nadView]; 
    
    self.centerCircle.layer.cornerRadius = 120.0f;
    self.smokeButton.layer.cornerRadius= 25.0f;
    [self.taxButton addTarget:self action:@selector(showTaxAlert:) forControlEvents:UIControlEventTouchDown];
    [self.smokeButton addTarget:self action:@selector(smokeTabaco:) forControlEvents:UIControlEventTouchDown];
    
    [self updateLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    // コメント掲示板用のデータ先読み in background
    _queryLimit = 1000;
    PFQuery *commentQuery = [PFQuery queryWithClassName:@"Comments"];
    [commentQuery orderByDescending:@"updatedAt"];
    commentQuery.limit = _queryLimit;
    [commentQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if(!error){
            NSLog(@"successfuly got comment data in background.");
            _commentsArray = [[objects reverseObjectEnumerator] allObjects];
        }
    }];
}

- (void)showTaxAlert:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc]
                            initWithTitle:@"タバコ税って何%?"
                            message:@"タバコ税は64.36%！\n\n内訳は、\n国タバコ税が24.7%、\n地方タバコ税が28.5%、\nタバコ特別税が3.8%、\n消費税が7.4%。\n\n1箱430円だと276.73円!!\n1本13.8365円!!!"
                            delegate:self
                            cancelButtonTitle:nil
                            otherButtonTitles:@"OK", nil];
    alert.alertViewStyle = UIAlertViewStyleDefault;
    [alert show];
}

- (void)smokeTabaco:(id)sender
{
    if (![self.smokeButton.currentTitle isEqual: @"タバコミュニケーション"] ) {
        [self.smokeButton setTitle:@"タバコミュニケーション" forState:UIControlStateNormal];

        // 現在時刻をyyyymmddで取得
        // coredateに保存しているデータが異なっていたら(日付が変わっていたら)更新
        
        // 現在時刻取得
        NSDate *nowdate = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyyMMdd"];
        NSString *today_str = [formatter stringFromDate:nowdate];
        int tmp = [today_str intValue];
        NSNumber *today_num = [NSNumber numberWithInt:tmp];

        // CoreDataから時間取得
        EntityDAO *dao = [[EntityDAO alloc]init];
        NSNumber *last_modified = [dao getEntity:@"last_modified"];
        NSLog(@"%@ : %@", last_modified, today_num);
        AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        if([last_modified isEqualToNumber:today_num]) {
            NSLog(@"not reset today");
            delegate.todayTax = [NSNumber numberWithDouble:[delegate.todayTax doubleValue] + [delegate.tabacoRate doubleValue]];
            delegate.totalTax = [NSNumber numberWithDouble:[delegate.totalTax doubleValue] + [delegate.tabacoRate doubleValue]];
        } else {
            NSLog(@"reset today");
            delegate.todayTax = [NSNumber numberWithDouble:[delegate.tabacoRate doubleValue]];
            delegate.totalTax = [NSNumber numberWithDouble:[delegate.totalTax doubleValue] + [delegate.tabacoRate doubleValue]];
            [dao setEntity:@"last_modified" value:today_num];
        }

        // ラベル更新
        [self updateLabel];
        
        //データをParseと同期
        if (!delegate.userId){
            delegate.userId = [dao getEntity:@"user_id"];
            NSLog(@"updated as %@", delegate.userId);
        }
        [self syncTaxData:delegate.userId today_tax:delegate.todayTax total_tax:delegate.totalTax];
        
        // タイマーセット
        [NSTimer scheduledTimerWithTimeInterval:180.0f // 3分間はスリープ
                    target:self
                    selector:@selector(resetSmokeButton:)
                    userInfo:nil
                    repeats:NO
        ];
    } else {
        CommunicationViewController * communicationViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"CommunicationViewController"];
        communicationViewController.commentsArray = _commentsArray;
        [self presentViewController:communicationViewController animated:true completion:nil];
    }
}

- (void) resetSmokeButton:(NSTimer*)timer{
    [self.smokeButton setTitle:@"タバコを吸う" forState:UIControlStateNormal];
}

- (void) syncTaxData:(NSNumber*)user_id today_tax:(NSNumber*)today_tax total_tax:(NSNumber*)total_tax
{
    NSLog(@"sync data user_id : %@, %@, %@", user_id, today_tax, total_tax);
    
    // Update CoreData
    EntityDAO *dao = [[EntityDAO alloc]init];
    [dao setEntity:@"today_tax" value:today_tax];
    [dao setEntity:@"total_tax" value:total_tax];
    NSLog(@"updated as : %@, %@", [dao getEntity:@"today_tax"], [dao getEntity:@"total_tax"]);
    
    // Update Parse
    PFQuery *query = [PFQuery queryWithClassName:@"UserClass"];
    [query whereKey:@"user_id" equalTo:user_id];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d scores.", objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                object[@"today_tax"] = today_tax;
                object[@"total_tax"] = total_tax;
                [object saveInBackground];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (void) updateLabel
{
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    
    NSString *todayTax_string = [NSString stringWithFormat:@"¥%.2f", [delegate.todayTax doubleValue]];
    [_todayTaxLabel setText:todayTax_string];
    NSString *totalTax_string = [NSString stringWithFormat:@"¥%.0f", [delegate.totalTax doubleValue]];
    [_totalTaxLabel setText:totalTax_string];
    
    NSLog(@"rate %@", delegate.tabacoRate);
    NSLog(@"today %@", delegate.todayTax);
    NSLog(@"total %@", delegate.totalTax);
    
    PFQuery *query1 = [PFQuery queryWithClassName:@"UserClass"];
    [query1 whereKey:@"today_tax" greaterThan:delegate.todayTax];
    [query1 countObjectsInBackgroundWithBlock:^(int count, NSError *error){
        if(!error){
            NSString *todayRanking = [NSString stringWithFormat:@"納税ランキング%d位", count + 1];
            [_todayRanking setText:todayRanking];
        }
    }];
    
    PFQuery *query2 = [PFQuery queryWithClassName:@"UserClass"];
    [query2 whereKey:@"total_tax" greaterThan:delegate.totalTax];
    [query2 countObjectsInBackgroundWithBlock:^(int count, NSError *error){
        if(!error){
            NSString *totalRanking = [NSString stringWithFormat:@"納税ランキング%d位", count + 1];
            [_totalRanking setText:totalRanking];
        }
    }];
}

@end
