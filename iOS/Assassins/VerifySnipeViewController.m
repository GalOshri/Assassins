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

@interface VerifySnipeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *commentField;
@property (weak, nonatomic) IBOutlet UILabel *verifyLabel;
@property (weak, nonatomic) IBOutlet UIButton *confirmSnipeButton;
@property (weak, nonatomic) IBOutlet UIButton *declineSnipeButton;
@property (weak, nonatomic) IBOutlet UIView *verifyBackground;

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
}


-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // set commentField
    if (![self.contract.comment isEqualToString:@""])
    {
        [self.commentField setHidden:NO];
        [self.commentField setText:self.contract.comment];
        self.commentField.textAlignment = NSTextAlignmentCenter;
        self.commentField.frame = CGRectMake(0,self.contract.commentYCoord, self.commentField.frame.size.width, self.commentField.frame.size.height);
    }
    
    // set the verify snipe section
    if (([[PFUser currentUser].username isEqualToString:self.contract.targetName] || ([[PFUser currentUser].username isEqualToString: self.contract.assassinName]))) {
        
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
    //do nothing, and segue back, breh!
    [self removePendingSnipe];
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
    [AssassinsService removeSnipeToVerify:self.contract.contractId];
}

@end
