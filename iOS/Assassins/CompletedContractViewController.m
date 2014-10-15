//
//  CompletedImageViewController.m
//  Assassins
//
//  Created by Paul Stavropoulos on 8/15/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "CompletedContractViewController.h"
#import "CommentTableViewCell.h"
#import "AssassinsService.h"
#import "ContractComment.h"
#import <Parse/Parse.h>

@interface CompletedContractViewController ()
@property (weak, nonatomic) IBOutlet UIButton *markAsInvalid;
@property (weak, nonatomic) IBOutlet UIView *bottomButtonContainer;

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

@implementation CompletedContractViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.contractImage setImage:self.contract.image];
    
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
    
    // set commentField
    if (![self.contract.comment isEqualToString:@""])
    {
        [self.contractComment setHidden:NO];
        [self.contractComment setText:self.contract.comment];
        self.contractComment.textAlignment = NSTextAlignmentCenter;
        self.contractComment.frame = CGRectMake(0,self.contract.commentYCoord, self.contractComment.frame.size.width, self.contractComment.frame.size.height);
        self.contractComment.userInteractionEnabled = NO;
    }
    
    // only show invalid snipe if it is a contract you are target
    if (![[PFUser currentUser].username isEqualToString:self.contract.targetName]) {
        [self.markAsInvalid setHidden:YES];
    }
    
    // you are part of the game, the contract is in a pending state, and you need to validate/invalidate it
    if ([self.contract.state isEqualToString:@"Pending"])
    {
        
    }
}

- (IBAction)initiateReviewProcess:(id)sender {
    // verify with alert
    UIAlertView *areYouSure = [[UIAlertView alloc] initWithTitle:@"Mark as invalid snipe?" message:@"By selecting 'OK', this snipe will be marked as invalid and will be voted on by game members to determine its validity." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    
    [areYouSure show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString:@"Mark as invalid snipe?"])
    {
        if (buttonIndex == 1) {
            // call AssassinsService method
            [AssassinsService startPendingContractProcess:self.contract withGame:self.game];
        }
    }

}

- (IBAction)showComments:(id)sender
{
    [self.commentView setHidden:NO];
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
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
        [self.view addGestureRecognizer:tapRecognizer];
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
