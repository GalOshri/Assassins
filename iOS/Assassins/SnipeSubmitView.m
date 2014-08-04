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

    
    
   // self.snipeImageView = CGAffineTransformMakeTranslation(0, (screenBounds.height - camViewHeight) / 2.0);
    //picker.cameraViewTransform = CGAffineTransformScale(picker.cameraViewTransform, scale, scale);
    
    //set touch events for snipeImageView
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickEventOnImage:)];
    [tapRecognizer setNumberOfTapsRequired:1];
    [tapRecognizer setDelegate:self];
    
    [self.snipeImageView addGestureRecognizer:tapRecognizer];
    [self.commentField setHidden:YES];
    
}


- (UIStatusBarStyle)preferredStatusBarStyle {
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

#pragma mark - Submit Assassination
- (IBAction)submitAssassination:(UIButton *)sender {
    [AssassinsService submitAssassination:self.snipeImage];
}

#pragma mark - HUD
- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD hides
    [self.HUD removeFromSuperview];
    self.HUD = nil;
}

@end
