//
//  CompletedImageViewController.m
//  Assassins
//
//  Created by Paul Stavropoulos on 8/15/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "CompletedContractViewController.h"
#import "AssassinsService.h"
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

@end

@implementation CompletedContractViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.contractImage setImage:self.contract.image];
    
    // make sure to hide comments
    [self.commentView setHidden:YES];
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
        [self.bottomButtonContainer setHidden:YES];
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

- (IBAction)showComments:(id)sender {
    [self.commentView setHidden:NO];
}

- (IBAction)postComment:(id)sender {
}

- (IBAction)dismissCommentsView:(id)sender {
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
