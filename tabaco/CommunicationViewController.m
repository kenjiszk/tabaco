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
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    UITapGestureRecognizer *singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard:)];
    singleTapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:singleTapGestureRecognizer];
    
    _defaultFieldY = _communicationView.frame.origin.y;
    
    PFQuery *commentQuery = [PFQuery queryWithClassName:@"Comments"];
    [commentQuery orderByAscending:@"updatedAt"];
    [commentQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if(!error){
            _commentsArray = objects;
            [_tableView reloadData];
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[_commentsArray count]-1 inSection:0];
            [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (!_textField.text || ![_textField.text isEqualToString:@""])
    NSLog(@"upload comment %@", _textField.text);
    
    PFObject *commentObject = [PFObject objectWithClassName:@"Comments"];
    commentObject[@"commented_by"] = delegate.userId;
    commentObject[@"comment"] = _textField.text;
    [commentObject saveInBackgroundWithBlock:^(BOOL succeed, NSError *error) {
        if(succeed) {
            PFQuery *commentQuery2 = [PFQuery queryWithClassName:@"Comments"];
            [commentQuery2 orderByAscending:@"updatedAt"];
            [commentQuery2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
                if(!error){
                    _commentsArray = objects;
                    [_tableView reloadData];
                    [self.view endEditing:YES];
                    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:[_commentsArray count]-1 inSection:0];
                    [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                }
            }];
        }
    }];
    
    _textField.text = @"";
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
    NSLog(@"cellForRowAtIndexPath");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = [NSString stringWithFormat:@"%@のコメント\n%@", [_commentsArray objectAtIndex:indexPath.row][@"commented_by"], [_commentsArray objectAtIndex:indexPath.row][@"comment"]];
    
    return cell;
}

// セルの高さをtextの高さに合わせる
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"heightForRowAtIndexPath");
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.numberOfLines = 0;
    // 調整のために改行いくつか入れる
    cell.textLabel.text = [NSString stringWithFormat:@"\n%@\n\n", [_commentsArray objectAtIndex:indexPath.row][@"comment"]];
    
    // get cell height
    CGSize bounds = CGSizeMake(tableView.frame.size.width, tableView.frame.size.height);
    CGSize size = [cell.textLabel.text sizeWithFont:cell.textLabel.font constrainedToSize:bounds lineBreakMode:NSLineBreakByClipping];
    CGSize detailSize = [cell.detailTextLabel.text sizeWithFont: cell.detailTextLabel.font constrainedToSize: bounds lineBreakMode: NSLineBreakByCharWrapping];
    
    return size.height + detailSize.height;
}

@end
