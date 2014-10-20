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
@property (weak, nonatomic) IBOutlet UISegmentedControl *snipeToggle;
@property (strong, nonatomic) NSMutableArray *submitContracts;


@end

@implementation SnipeSubmitView


 #pragma mark - Navigation
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     if ([segue.identifier isEqualToString:@"UnwindToCameraAfterSnipe"])
     {
         /* if ([segue.destinationViewController isKindOfClass:[ViewController class]])
         {
             
         } */
         //self.isSnipeSubmitted = NO; // NOPENDING
     }
     
 }

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.snipeImageView.image = self.snipeImage;
    [self.commentField setHidden:YES];
    
    // set touch events for snipeImageView
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickEventOnImage:)];
    [tapRecognizer setNumberOfTapsRequired:1];
    [tapRecognizer setDelegate:self];
    [self.snipeImageView addGestureRecognizer:tapRecognizer];
    
    //self.isSnipeSubmitted = NO;
    
    

    
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
    textField.center = CGPointMake(textField.center.x, point.y);
}

#pragma mark - Submit Assassination

- (IBAction)submitAssassination:(UIButton *)sender {
    if ([self.snipeToggle selectedSegmentIndex] == 0)
    {
        // grab list of related contracts
        self.submitContracts = [AssassinsService getContractArray];
        
        if ([self.submitContracts count] == 0) {
            UIAlertView *noContract = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"You are currently not in a game, and have no target. Create a game with friends to play!" delegate:self cancelButtonTitle:@"ok, shya breh!" otherButtonTitles:nil];
            
            [noContract show];
        }
        
        else if ([self.submitContracts count] > 1)
        {
            UIAlertView *pickContract = [[UIAlertView alloc] initWithTitle:@"Whom did you snipe?" message:@"" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:nil];
           
            //show alert to pick which contract to submit snipe to
            for (Contract *contract in self.submitContracts)
            {
                NSArray *nameArray = [contract.targetName componentsSeparatedByString:@" "];
                NSString *firstName = nameArray[0];
                
                [pickContract addButtonWithTitle:[NSString stringWithFormat:@"%@ in game: %@", firstName, contract.gameName]];
            }
            
            [pickContract show];
        }
        
        else
        {
            // only 1 contract!
            Contract *selectedContract = self.submitContracts[0];
            [AssassinsService submitAssassination:self.snipeImage withMode:YES withComment:self.commentField.text withCommentLocation:self.commentField.frame.origin.y withContract:selectedContract];
            
            [self performSegueWithIdentifier:@"UnwindToCameraAfterSnipe" sender:self];
        }
            
    }
    
    else
    {
        // show UI alert for now
        UIAlertView *defenseAlert = [[UIAlertView alloc] initWithTitle:@"The best defense is a strong offense" message:@"This feature is coming soon!" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:nil];
        defenseAlert.alertViewStyle = UIAlertViewStyleDefault;
        [defenseAlert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.title isEqualToString:@"Oops!"])
        [self performSegueWithIdentifier:@"UnwindToCameraAfterSnipe" sender:self];
    
    else if ([alertView.title isEqualToString:@"Whom did you snipe?"])
    {
        if (buttonIndex - 1 >= 0)
        {
            // grab correct contract id and selected game Id
            Contract *selectedContract = self.submitContracts[buttonIndex-1];
            self.selectedGameId = selectedContract.gameId;
            [AssassinsService submitAssassination:self.snipeImage withMode:YES withComment:self.commentField.text withCommentLocation:self.commentField.frame.origin.y withContract:selectedContract];
            
            
            [self performSegueWithIdentifier:@"UnwindToCameraAfterSnipe" sender:self];
            
            /*
            // perform segue
            UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            GameTableViewController* gtvc = [mainstoryboard instantiateViewControllerWithIdentifier:@"gameTableView"];
            
            Game *game = [AssassinsService getGameWithId:self.selectedGameId];
            gtvc.game = game;
            
            [gtvc setModalPresentationStyle:UIModalPresentationFullScreen];
            [self presentViewController:gtvc animated:YES completion:nil];
             */
        }
    }
}


@end
