//
//  verifySnipeViewController.m
//  Assassins
//
//  Created by Paul Stavropoulos on 8/4/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "VerifySnipeViewController.h"
#import "AppDelegate.h"
#import "AssassinsService.h"
#import "CommentTableViewCell.h"
#import "ContractComment.h"

@interface VerifySnipeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *verifyLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmSnipeButton;
@property (weak, nonatomic) IBOutlet UIButton *declineSnipeButton;
@property (weak, nonatomic) IBOutlet UIView *verifyBackground;

@property (weak, nonatomic) IBOutlet UIButton *commentsButton;
@property (weak, nonatomic) IBOutlet UITextField *addCommentField;
@property (weak, nonatomic) IBOutlet UIButton *postComment;
@property (weak, nonatomic) IBOutlet UIButton *dismissCommentView;
@property (weak, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic) IBOutlet UITableView *commentViewTable;

@property(strong, nonatomic) NSMutableArray *commentsArray;
@property BOOL postOrNah;
@property BOOL keyboardOrNah;
@property BOOL isEditingOrNah;
@property float originalCommentViewLocation;


@end

@implementation VerifySnipeViewController

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    self.isSnipeChanged = NO;
    if (([segue.identifier isEqualToString:@"UnwindWithConfirmedSnipe"]) || ([segue.identifier isEqualToString:@"UnwindWithDeniedSnipe"]))
    {
        self.isSnipeChanged = YES;
    }
    
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    self.snipeImage.image = self.contract.image;
    
    // make sure to hide comment view
    [[self.commentView layer] setCornerRadius:5.0];
    [[self.commentView layer] setMasksToBounds:YES];
    [self.commentView setHidden:YES];
    
    // set table items
    self.commentViewTable.delegate = self;
    self.commentViewTable.dataSource = self;
    self.addCommentField.delegate = self;
    
    // get comments and set correct number
    self.commentsArray = [AssassinsService getCommentsWithContract:self.contract.contractId];
    [self.commentsButton setTitle:[NSString stringWithFormat:@"%lu comments", (unsigned long)[self.commentsArray count]] forState:UIControlStateNormal];
    
    // set responder for keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardFrameDidChange:)
                                                 name:UIKeyboardDidChangeFrameNotification object:nil];
    self.keyboardOrNah = NO;
    self.originalCommentViewLocation = self.commentView.frame.origin.y;
}


-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // set the verify snipe section
    if (([[PFUser currentUser].username isEqualToString:self.contract.targetName] || ([[PFUser currentUser].username isEqualToString: self.contract.assassinName])))
    {
        // user is the victim, and cannot take action
        [self.confirmSnipeButton setHidden:YES];
        [self.declineSnipeButton setHidden:YES];
        [self.verifyLabel setText: @"This snipe is pending"];
        self.verifyLabel.center = CGPointMake(self.verifyLabel.center.x, (2* self.verifyBackground.frame.origin.x + self.verifyBackground.frame.size.height)/2);
    }
    else
    {
        NSArray *spaceSplitter = [self.contract.targetName componentsSeparatedByString:@" "];
        NSString *firstName = spaceSplitter[0];
        [self.verifyLabel setText:[NSString stringWithFormat:@"Is this a valid snipe of %@?", firstName]];
    }
}

- (IBAction)confirmedSnipe:(id)sender {
    
    // [AssassinsService confirmAssassination:self.contract.contractId];
    // do nothing, and segue back, breh!
    // [self removePendingSnipe];
}


- (IBAction)declinedSnipe:(id)sender {
    [AssassinsService declineAssassination:self.contract.contractId withGameId:self.contract.gameId];
    [self removePendingSnipe];
}

- (void)removePendingSnipe
{
    // AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // appDelegate.numberPendingSnipe -= 1;
    
    // make call to remove pending snipe from zeh sehvah?
    // [AssassinsService removeSnipeToVerify:self.contract.contractId];
}

- (IBAction)showComments:(id)sender
{
    if ([self.commentView isHidden])
    {
        // show comments, and create way to dismiss by tap on img
        [self.commentView setHidden:NO];
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissCommentsView:)];
        [tapRecognizer setNumberOfTapsRequired:1];
        [tapRecognizer setDelegate:self];
        [self.snipeImage addGestureRecognizer:tapRecognizer];
    }
    else
        [self.commentView setHidden:YES];
}

- (IBAction)postComment:(id)sender
{
    // call assassins service to add to the database
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        self.postOrNah = [AssassinsService addComment:self.addCommentField.text withContractId:self.contract.contractId];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            if (self.postOrNah)
            {
                // Add code here to update the UI/send notifications based on the results of the background processing
                // append this to commentsArray and add to table
                ContractComment *newComment = [[ContractComment alloc] init];
                newComment.commentText = self.addCommentField.text;
                newComment.commentCreator = [PFUser currentUser].username;
                newComment.dateCreated = [NSDate date];
                
                NSLog(@"new date is %@", newComment.dateCreated);
                
                // reset table, empty text box, incrmeent number of comment button
                self.addCommentField.text = @"";
                [self.commentsArray addObject:newComment];
                [self.commentsButton setTitle:[NSString stringWithFormat:@"%lu comments", (unsigned long)[self.commentsArray count]] forState:UIControlStateNormal];
                [self.commentViewTable reloadData];
                
            }
        });
    });
    
}

- (IBAction)dismissCommentsView:(id)sender
{
    [self.commentView setHidden:YES];
    
    if ([sender isMemberOfClass:[UITapGestureRecognizer class]])
    {
        // remove gesture
        UITapGestureRecognizer *gestureRecognizer = sender;
        [self.snipeImage removeGestureRecognizer:gestureRecognizer];
        [self.view endEditing:YES];
    }

    
    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.commentsArray count];
}

- (CommentTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // set datasource
    CommentTableViewCell *cell = (CommentTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"cellComment" forIndexPath:indexPath];
    
    // set comment
    ContractComment *currentComment = [self.commentsArray objectAtIndex:indexPath.row];
    
    // set items in cell
    cell.nameLabel.text = currentComment.commentCreator;
    cell.commentTextView.text = currentComment.commentText;
    
    // date string manipulation
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"hh:mm a MMM-dd" options:0 locale:[NSLocale currentLocale]]];
    NSString *theTime = [dateFormatter stringFromDate:currentComment.dateCreated];
    
    cell.commentDate.text = theTime;
    
    return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    [self.addCommentField resignFirstResponder];
    return YES;
}

- (void)keyboardFrameDidChange:(NSNotification*)notification
{
    self.keyboardOrNah = !self.keyboardOrNah;
    
    NSDictionary* info = [notification userInfo];
    CGRect kKeyBoardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    // if there is now a keyboard
    if (self.keyboardOrNah)
    {
        [UIView animateWithDuration:0.5 animations:^{
            [self.commentView setFrame:CGRectMake(self.commentView.frame.origin.x, kKeyBoardFrame.origin.y-self.commentView.frame.size.height - 10, self.commentView.frame.size.width, self.commentView.frame.size.height)];
        }];
        
        self.isEditingOrNah = YES;
        
        //call selector to dismiss keyboard code if it is present
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchEventOnView:)];
        [tapRecognizer setNumberOfTapsRequired:1];
        [tapRecognizer setDelegate:self];
        [self.commentView addGestureRecognizer:tapRecognizer];
    }
    // if there is no longer a keyboard, move back to original location
    else
    {
        [UIView animateWithDuration:0.5 animations:^{
            [self.commentView setFrame:CGRectMake(self.commentView.frame.origin.x, self.originalCommentViewLocation, self.commentView.frame.size.width, self.commentView.frame.size.height)];
        }];
    }
}

- (void)touchEventOnView: (id) sender
{
    if (self.isEditingOrNah) {
        self.isEditingOrNah = NO;
        
        [self.view endEditing:YES];
        
        // remove gesture
        UITapGestureRecognizer *gestureRecognizer = sender;
        [self.view removeGestureRecognizer:gestureRecognizer];
    }
}

@end
