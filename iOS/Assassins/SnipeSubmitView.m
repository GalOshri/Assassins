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
@property (strong, nonatomic) NSArray *submitContracts;

@end

@implementation SnipeSubmitView


 #pragma mark - Navigation
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     if ([segue.identifier isEqualToString:@"SegueAfterSnipeSubmit"]) {
         if ([segue.destinationViewController isKindOfClass:[GameTableViewController class]])
         {
             GameTableViewController *gtvc = (GameTableViewController *)segue.destinationViewController;
             Game *game = [AssassinsService getGameWithId:@"Jr9NNIwOiO"];
             gtvc.game = game;
         }
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

    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
        
        //show alert to pick which contract to submit snipe to
        NSMutableArray *names = [[NSMutableArray alloc] init];
        for (Contract *contract in self.submitContracts)
            [names addObject:contract.targetName];
        
        UIAlertView *pickContract = [[UIAlertView alloc] initWithTitle:@"Whom did you snipe?" message:@"" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:nil];
        for (NSString *name in names)
            [pickContract addButtonWithTitle:name];
        
        [pickContract show];
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
    if ([alertView.title isEqualToString:@"Whom did you snipe?"])
    {
        // grab correct contract id
        Contract *selectedContract = self.submitContracts[buttonIndex];
        
        [AssassinsService submitAssassination:self.snipeImage withMode:YES withComment:self.commentField.text withCommentLocation:self.commentField.frame.origin.y withContractId:selectedContract.contractId];
    }
}


@end
