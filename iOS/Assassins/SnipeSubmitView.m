//
//  SnipeSubmitView.m
//  Assassins
//
//  Created by Gal Oshri on 7/24/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "SnipeSubmitView.h"
#import "AssassinsService.h"

@interface SnipeSubmitView ()
@property (weak, nonatomic) IBOutlet UITextField *commentField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *snipeToggle;
@property BOOL isSnipeMode;



@end

@implementation SnipeSubmitView





/*
 #pragma mark - Navigation
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.snipeImageView.image = self.snipeImage;
    [self.commentField setHidden:YES];
    self.isSnipeMode = YES;
    
    //set touch events for snipeImageView
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


- (IBAction)dragCommentField:(UITextField *)textField forEvent: (UIEvent *)event {
    
    
    CGPoint point = [[[event allTouches] anyObject] locationInView:self.snipeImageView];
    textField.center = CGPointMake(textField.center.x, point.y);
}

- (IBAction)snipeToggleValueChanged:(id)sender {
    
    //switch statement to change BOOL isSnipeMode
    switch (self.snipeToggle.selectedSegmentIndex) {
        // Nearby places
        case 0:
            self.isSnipeMode = YES;
            break;
        // Favorites
        case 1:
            self.isSnipeMode = NO;
            break;
        default:
            break;
    }
    
}

#pragma mark - Submit Assassination
- (IBAction)submitAssassination:(UIButton *)sender {
    if (self.isSnipeMode) {
        [AssassinsService submitAssassination:self.snipeImage withMode:self.isSnipeMode withComment:self.commentField.text withCommentLocation:self.commentField.frame.origin.y];
        [self performSegueWithIdentifier:@"SnipeSubmitViewToGameView" sender:self];
    }
    
    else {
        // show UI alert for now
        UIAlertView *usernameAlert = [[UIAlertView alloc] initWithTitle:@"The Best Defense is a Strong Offense" message:@"This Feature is Coming Soon!" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:nil];
        usernameAlert.alertViewStyle = UIAlertViewStyleDefault;
        [usernameAlert show];
    }
}


@end
