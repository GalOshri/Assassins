//
//  SnipeSubmitView.m
//  Assassins
//
//  Created by Gal Oshri on 7/24/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "SnipeSubmitView.h"
#import "AssassinsService.h"
#import "GameTableViewController.h"

@interface SnipeSubmitView ()

@property (weak, nonatomic) IBOutlet UITextField *commentField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *snipeImageHeightConstraint;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *snipeImageWidthConstraint;

@property (strong, nonatomic) NSMutableArray *submitContracts;


@end

@implementation SnipeSubmitView


 #pragma mark - Navigation
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     if ([segue.identifier isEqualToString:@"UnwindToCameraAfterSnipe"])
     {
         
     }
 }

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.snipeImageView.image = self.snipeImage;
    //self.snipeImageHeightConstraint.constant = self.snipeImage.size.height;
    //self.snipeImageWidthConstraint.constant = self.snipeImage.size.width;
    [self.view layoutIfNeeded];
    //NSLog(@"width:%f, height:%f, screen widht:%f, screen height: %f with x coord:%f", self.snipeImage.size.width, self.snipeImage.size.height,self.view.frame.size.width, self.view.frame.size.height, self.snipeImageView.frame.origin.y);
    
    [self.commentField setHidden:YES];
    
    // set touch events for snipeImageView
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickEventOnImage:)];
    [tapRecognizer setNumberOfTapsRequired:1];
    [tapRecognizer setDelegate:self];
    [self.snipeImageView addGestureRecognizer:tapRecognizer];
    
    [self.activityIndicator setHidden:YES];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


#pragma mark - Commenting on image
- (void) clickEventOnImage:(UITapGestureRecognizer *)sender {
    //deal with showing/hiding textField
    
    if (self.commentField.hidden == YES) {
        [self.commentField setHidden:NO];
        [self.commentField becomeFirstResponder];
    }
    
    else if (self.commentField.hidden == NO && [self.commentField.text isEqualToString:@""]) {
        [self.commentField setHidden:YES];
        [[self view] endEditing:YES];
    }
    
    else {
        if ([self.commentField isFirstResponder]) {
            [[self view] endEditing:YES];
            self.commentField.textAlignment = NSTextAlignmentCenter;
        }
        
        else {
            [self.commentField becomeFirstResponder];
            self.commentField.textAlignment = NSTextAlignmentLeft;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
    
}


- (IBAction)dragCommentField:(UITextField *)textField forEvent:(UIEvent *)event {
    
    CGPoint point = [[[event allTouches] anyObject] locationInView:self.snipeImageView];
    
    if(point.y >= 40.0 && point.y <= self.view.frame.size.height - 140.0)
        textField.center = CGPointMake(textField.center.x, point.y);
}

#pragma mark - Submit Assassination
- (IBAction)submitAssassination:(UIButton *)sender {
    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // grab list of related contracts
        if (!self.submitContracts)
            self.submitContracts = [AssassinsService getContractArray];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            [self presentGameSubmissionOptions];
        });
    });
}

- (void)presentGameSubmissionOptions
{
    if ([self.submitContracts count] == 0) {
        UIAlertView *noContract = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"You are currently not in a game, and cannot snipe snipe a target. Create a game with friends to play!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [noContract show];
    }
    
    else if ([self.submitContracts count] > 1)
    {
        UIActionSheet *pickContract = [[UIActionSheet alloc] initWithTitle:@"This is a snipe of:" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
       
        //show alert to pick which contract to submit snipe to
        for (Contract *contract in self.submitContracts)
        {
            NSArray *nameArray = [contract.targetName componentsSeparatedByString:@" "];
            NSString *firstName = nameArray[0];
            [pickContract addButtonWithTitle:[NSString stringWithFormat:@"%@ in \"%@\"", firstName, contract.gameName]];
        }
        
        // make scrollable
        [pickContract showInView:self.view];
    }
    
    else
    {
        // only 1 contract!
        Contract *selectedContract = self.submitContracts[0];
        
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [AssassinsService submitAssassination:self.snipeImage withMode:YES withComment:self.commentField.text withCommentLocation:self.commentField.frame.origin.y withContract:selectedContract];
        });
        
        [self performSegueWithIdentifier:@"UnwindToCameraAfterSnipe" sender:self];
    }
    
    [self.activityIndicator setHidden:YES];
    [self.activityIndicator stopAnimating];

}

# pragma mark - action sheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([actionSheet.title isEqualToString:@"Oops!"])
        [self performSegueWithIdentifier:@"UnwindToCameraAfterSnipe" sender:self];
    
    else if ([actionSheet.title isEqualToString:@"This is a snipe of:"])
    {
        if (buttonIndex - 1 >= 0)
        {
            // grab correct contract id and selected game Id
            Contract *selectedContract = self.submitContracts[buttonIndex-1];
            self.selectedGameId = selectedContract.gameId;
            
            dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [AssassinsService submitAssassination:self.snipeImage withMode:YES withComment:self.commentField.text withCommentLocation:self.commentField.frame.origin.y withContract:selectedContract];
            });
            
            
            [self performSegueWithIdentifier:@"UnwindToCameraAfterSnipe" sender:self];
        }
    }
}


@end
