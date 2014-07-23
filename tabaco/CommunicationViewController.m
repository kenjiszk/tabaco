//
//  CommunicationViewController.m
//  tabaco
//
//  Created by Kenji Suzuki on 2014/07/13.
//  Copyright (c) 2014年 jp.babyry. All rights reserved.
//

#import "CommunicationViewController.h"
#import "AppDelegate.h"

@interface CommunicationViewController ()

@end

@implementation CommunicationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.nadView = [[NADView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, 320, 50)];
    self.nadView.backgroundColor = [UIColor blackColor];
    [self.nadView setIsOutputLog:NO];
    [self.nadView setNendID:[Config getNendID] spotID:[Config getSpotID]];
    [self.nadView setDelegate:self];
    [self.nadView load];
    [self.view addSubview:self.nadView];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTapGestureRecognizer];
    
    _defaultFieldY = _communicationView.frame.origin.y;
    
    if ([_commentsArray count] > 0) {
        [_tableView reloadData];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[_commentsArray count]-1 inSection:0];
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    } else {
        _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        _hud.labelText = @"Wait a Moment...";
        //hud.margin = 0;
        //hud.labelFont = [UIFont fontWithName:@"HelveticaNeue-Thin" size:15];
    }
    
    [self reloadCommentMethod];
    
    _isTimerRunning = 0;
    _tm = [NSTimer
           scheduledTimerWithTimeInterval:10.0f
           target:self
           selector:@selector(reloadComment:)
           userInfo:nil
           repeats:YES
           ];
}

-(void)reloadComment:(NSTimer*)timer{
    [self reloadCommentMethod];
}

-(void)reloadCommentMethod
{
    if (_isTimerRunning != 1) {
        _isTimerRunning = 1;
        _queryLimit = 1000;
        
        PFQuery *commentQuery = [PFQuery queryWithClassName:@"Comments"];
        [commentQuery orderByDescending:@"updatedAt"];
        commentQuery.limit = _queryLimit;
        [commentQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            if(!error){
                [_hud hide:YES];
                _commentsArray = [[objects reverseObjectEnumerator] allObjects];
                [_tableView reloadData];
                
                CGPoint offset =  _tableView.contentOffset;
                NSLog(@"%f %f %f", _tableView.contentSize.height, offset.y, _tableView.contentSize.height - offset.y - _tableView.frame.size.height);
                if (_tableView.contentSize.height - offset.y - _tableView.frame.size.height < 100) {
                    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[_commentsArray count]-1
                                                                inSection:0];
                    [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                }
                _isTimerRunning = 0;
            }
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillDisappear:(BOOL)animated
{
    [_tm invalidate];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)sendButton:(id)sender {
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    NSLog(@"send comment");
    if (!_textView.text || ![_textView.text isEqualToString:@""]) {
        NSLog(@"upload comment %@", _textView.text);
        
        PFObject *commentObject = [PFObject objectWithClassName:@"Comments"];
        commentObject[@"commented_by"] = delegate.userId;
        commentObject[@"comment"] = _textView.text;
        
        _commentsArray = [_commentsArray arrayByAddingObject:commentObject];
        [_tableView reloadData];
        [self.view endEditing:YES];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[_commentsArray count]-1 inSection:0];
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        
        [commentObject saveInBackgroundWithBlock:^(BOOL succeed, NSError *error) {
            if(succeed) {
                PFQuery *commentQuery2 = [PFQuery queryWithClassName:@"Comments"];
                [commentQuery2 orderByDescending:@"updatedAt"];
                commentQuery2.limit = _queryLimit;
                [commentQuery2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
                    if(!error){
                        _commentsArray = [[objects reverseObjectEnumerator] allObjects];
                        [_tableView reloadData];
                        [self.view endEditing:YES];
                        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[_commentsArray count]-1 inSection:0];
                        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    }
                }];
            }
        }];
    }
    
    _textView.text = @"";
}

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Start observing
    if (!_keyboardObserving) {
        NSNotificationCenter *center;
        center = [NSNotificationCenter defaultCenter];
        [center addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [center addObserver:self selector:@selector(keybaordWillHide:) name:UIKeyboardWillHideNotification object:nil];
        _keyboardObserving = YES;
    }
}

-(void)hideKeyBoard:(id) sender
{
    [self.view endEditing:YES];
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    //NSLog(@"keyboardWillShow");
    // Get userInfo
    NSDictionary *userInfo;
    userInfo = [notification userInfo];
    
    // Calc overlap of keyboardFrame and textViewFrame
    CGRect keyboardFrame;
    CGRect textViewFrame;
    keyboardFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardFrame = [self.view.superview convertRect:keyboardFrame fromView:nil];
    textViewFrame = _communicationView.frame;
    float overlap;
    overlap = MAX(0.0f, CGRectGetMaxY(textViewFrame) - CGRectGetMinY(keyboardFrame));
    //NSLog(@"overlap %f", overlap);
    
    NSTimeInterval duration;
    UIViewAnimationCurve animationCurve;
    void (^animations)(void);
    duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    animations = ^(void) {
        CGRect frame = _communicationView.frame;
        frame.origin.y -= overlap;
        _communicationView.frame = frame;
    };
    [UIView animateWithDuration:duration delay:0.0 options:(animationCurve << 16) animations:animations completion:nil];
    
}

- (void)keybaordWillHide:(NSNotification*)notification
{
    NSLog(@"keyboardWillHide");
    // Get userInfo
    NSDictionary *userInfo;
    userInfo = [notification userInfo];
    
    CGRect textViewFrame;
    textViewFrame = self.view.frame;
    float overlap;
    //overlap = MAX(0.0f, CGRectGetMaxY(_defaultCommentViewRect) - CGRectGetMaxY(textViewFrame));
    NSLog(@"overlap %f", overlap);
    
    NSTimeInterval duration;
    UIViewAnimationCurve animationCurve;
    void (^animations)(void);
    duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    animationCurve = [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    animations = ^(void) {
        CGRect frame = _communicationView.frame;
        frame.origin.y = _defaultFieldY;
        _communicationView.frame = frame;
    };
    [UIView animateWithDuration:duration delay:0.0 options:(animationCurve << 16) animations:animations completion:nil];
}

// tableViewにいくつセクションがあるか。明記しない場合は1つ
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //NSLog(@"numberOfSectionsInTableView");
    return 1;
}

// section目のセクションにいくつ行があるかを返す
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_commentsArray count];
}

// indexPathの位置にあるセルを返す
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"cellForRowAtIndexPath");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = [NSString stringWithFormat:@"ID : %@\n%@", [_commentsArray objectAtIndex:indexPath.row][@"commented_by"], [_commentsArray objectAtIndex:indexPath.row][@"comment"]];
    
    return cell;
}

// セルの高さをtextの高さに合わせる
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"heightForRowAtIndexPath");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.numberOfLines = 0;
    // 調整のために改行いくつか入れる
    cell.textLabel.text = [NSString stringWithFormat:@"\n%@\n\n\n", [_commentsArray objectAtIndex:indexPath.row][@"comment"]];
    
    // get cell height
    CGSize bounds = CGSizeMake(tableView.frame.size.width, tableView.frame.size.height);
    CGSize size = [cell.textLabel.text
                   boundingRectWithSize:bounds
                   options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                   attributes:[NSDictionary dictionaryWithObject:cell.textLabel.font forKey:NSFontAttributeName]
                   context:nil].size;
    
    return size.height;
}

@end
