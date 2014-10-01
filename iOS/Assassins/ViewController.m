//
//  ViewController.m
//  Assassins
//
//  Created by Gal Oshri on 7/21/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "ViewController.h"
#import "SnipeSubmitView.h"
#import "AssassinsLogInView.h"
#import "AssassinsSignUpView.h"
#import "UIImage+Resize.h"
#import "VerifySnipeViewController.h"
#import "GameTableViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "AppDelegate.h"
#import "AssassinsService.h"
#import "UserTableViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *flashImage;
@property UIImagePickerController *picker;
@property (weak, nonatomic) IBOutlet UIButton *flipCamera;
@property (weak, nonatomic) IBOutlet UIButton *snipeNotificationButton;
@property BOOL flashMode;
@property BOOL sendToPendingSnipe;



@end

@implementation ViewController

UIImagePickerController *picker;
CGFloat cameraAspectRatio = 4.0f/3.0f;
CGFloat scale;

- (IBAction)unwindToCamera:(UIStoryboardSegue *)segue {
    
    if ([segue.identifier isEqualToString:@"UnwindToCameraAfterSnipe"])
    {
        if ([segue.sourceViewController isKindOfClass:[SnipeSubmitView class]])
        {
            SnipeSubmitView *ssv = (SnipeSubmitView *)segue.sourceViewController;
            self.goToGameId = ssv.selectedGameId;
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SnipeSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[SnipeSubmitView class]])
        {
            SnipeSubmitView *ssv = (SnipeSubmitView *)segue.destinationViewController;
            UIImage *chosenImage = (UIImage *)sender;
            
            
            //###### apply cropping to image ##### //
            
            // scale image to be correct size
            CGSize size = CGSizeMake(self.view.frame.size.height * 1/cameraAspectRatio, self.view.frame.size.height);
            UIImage *resizedImage = [chosenImage resizedImage:size interpolationQuality:kCGInterpolationDefault];
            
            // crop image correctly
            CGRect clippedRect = CGRectMake(resizedImage.size.width/2 - self.view.frame.size.width/2, 0, self.view.frame.size.width, self.view.frame.size.height);
            CGImageRef imageRef = CGImageCreateWithImageInRect([resizedImage CGImage], clippedRect);
            UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
            CGImageRelease(imageRef);
            
            ssv.snipeImage = (UIImage *) croppedImage;
        }
    }
    
    if ([segue.identifier isEqualToString:@"SegueToUserView"])
    {
        if ([segue.destinationViewController isKindOfClass:[UserTableViewController class]])
        {
            if (self.goToGameId != nil)
            {
            
                UserTableViewController *utvc = (UserTableViewController *)segue.destinationViewController;
                
                Game *selectedGame = [AssassinsService getGameWithId:self.goToGameId];
                self.goToGameId = nil;
                utvc.goToGame = selectedGame;
            }
            
            if (self.sendToPendingSnipe) {
                UserTableViewController *utvc = (UserTableViewController *)segue.destinationViewController;
                utvc.goToPendingNotifcations = self.sendToPendingSnipe;
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set up the camera
    picker  = [[UIImagePickerController alloc] init];
    [picker setDelegate:self];
    [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [picker setMediaTypes:@[@"public.image"]]; //specify image (not video)
    [picker setShowsCameraControls:NO]; //hide default camera controls
    [picker setNavigationBarHidden:YES];
    [picker setToolbarHidden:YES];
    [picker setAllowsEditing:NO];
    picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    self.flashMode = NO;
    
    //math to resize to size of phone
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    BOOL landscape = (orientation == UIInterfaceOrientationPortrait);
    
    if (landscape)
    {
        CGSize screenBounds = [UIScreen mainScreen].bounds.size;
        cameraAspectRatio = 4.0f/3.0f;
        CGFloat camViewHeight = screenBounds.width * cameraAspectRatio;
        scale = screenBounds.height / camViewHeight;
        
        picker.cameraViewTransform = CGAffineTransformMakeTranslation(0, (screenBounds.height - camViewHeight) / 2.0);
        picker.cameraViewTransform = CGAffineTransformScale(picker.cameraViewTransform, scale, scale);
        
        [self.view addSubview:picker.view];
        [self.view sendSubviewToBack:picker.view];
    }
    
    // snipe NotificationButton set
    [[self.snipeNotificationButton layer] setCornerRadius:5];
    [[self.snipeNotificationButton layer] setMasksToBounds:YES];
    
    [[PFUser currentUser] refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        // noop
    }];

}

- (void)viewDidAppear:(BOOL)animated
{
    
    
    [super viewDidAppear:animated];
    
    self.sendToPendingSnipe = NO;
    
    // Log in / sign up if no user signed in
    if (![PFUser currentUser])
    {
        [self showLogInAndSignUpView];
    }
    
    if (self.goToGameId)
    {
        self.sendToPendingSnipe = YES;
        [self performSegueWithIdentifier:@"SegueToUserView" sender:self]; // NOPENDING
    }
    
    // check to see if have snipe pending
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.numberPendingSnipe = [AssassinsService getNumberOfPendingSnipes];
    
    
     if (appDelegate.numberPendingSnipe > 0)
    {
        [self.snipeNotificationButton setHidden:NO];
        NSTimer *pendingNotificationTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(pendingNotificationAnimation) userInfo:nil repeats:YES];
    }
}

- (void)showLogInAndSignUpView
{
    // Create the log in view controller
    AssassinsLogInView *logInViewController = [[AssassinsLogInView alloc] init];
    [logInViewController setDelegate:self]; // Set ourselves as the delegate
    [logInViewController setFacebookPermissions:[NSArray arrayWithObjects:@"friends_about_me", @"publish_actions", @"user_friends", nil]];
    //[logInViewController setFields: PFLogInFieldsDefault | PFLogInFieldsTwitter | PFLogInFieldsFacebook | PFLogInFieldsDismissButton];
    [logInViewController setFields: PFLogInFieldsFacebook];
    
    // Create the sign up view controller
    AssassinsSignUpView *signUpViewController = [[AssassinsSignUpView alloc] init];
    [signUpViewController setDelegate:self]; // Set ourselves as the delegate
    
    // Assign our sign up controller to be displayed from the login controller
    [logInViewController setSignUpController:signUpViewController];
    
    // Present the log in view controller
    [self presentViewController:logInViewController animated:YES completion:NULL];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Picture Methods

- (IBAction)takePicture:(UIButton *)sender {
    [picker takePicture];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    if (picker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
        chosenImage = [UIImage imageWithCGImage:chosenImage.CGImage scale:chosenImage.scale orientation:UIImageOrientationLeftMirrored];

    [self performSegueWithIdentifier:@"SnipeSegue" sender:chosenImage];
}
/*
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}
*/
- (IBAction)toggleFlash:(UIButton *)sender
{
    if (self.flashMode)
    {
        [picker setCameraFlashMode: UIImagePickerControllerCameraFlashModeOff];
        [sender setImage:[UIImage imageNamed:  @"noFlash.png"] forState:UIControlStateNormal];
        self.flashMode = NO;
    }
    else
    {
        [picker setCameraFlashMode: UIImagePickerControllerCameraFlashModeOn];
        [sender setImage:[UIImage imageNamed: @"flash.png"] forState:UIControlStateNormal];
        self.flashMode = YES;
    }
}

- (IBAction)flipCamera:(id)sender {
    if (picker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
        [picker setCameraDevice:UIImagePickerControllerCameraDeviceRear];
    else
        [picker setCameraDevice:UIImagePickerControllerCameraDeviceFront];
}

- (void)pendingNotificationAnimation
{
    // animate
    if (self.snipeNotificationButton.alpha == 1.0)
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.snipeNotificationButton.alpha = 0.5;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.snipeNotificationButton.alpha = 1.0;
        }];
    }
}

- (IBAction)segueToUserToPendingContracts:(id)sender
{
    self.sendToPendingSnipe = YES;
    [self performSegueWithIdentifier:@"SegueToUserView" sender:self];
}

#pragma mark - User Identity Views
// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information"
                                message:@"Make sure you fill out all of the information!"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation[@"user"] == nil)
    {
        currentInstallation[@"user"] = [PFUser currentUser];
        [currentInstallation saveInBackground];
    }
    PFUser *currentUser = [PFUser currentUser];
    if ([PFFacebookUtils isLinkedWithUser:currentUser])
    {
        if (currentUser[@"facebookId"] == nil)
        {
            // Create request for user's Facebook data
            FBRequest *request = [FBRequest requestForMe];
            
            // Send request to Facebook
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    // result is a dictionary with the user's Facebook data
                    NSDictionary *userData = (NSDictionary *)result;
                    
                    currentUser[@"facebookId"] = userData[@"id"];
                    currentUser[@"username"] = userData[@"name"];
                    currentUser[@"lifetimeSnipes"] = [NSNumber numberWithInt:0];
                    currentUser[@"lifetimeGames"] = [NSNumber numberWithInt:0];
                    currentUser[@"snipesToVerify"] = [NSArray arrayWithObjects:nil];
                    [currentUser save];

                }
                else
                    NSLog(@"facebook request error: %@", error);
            }];
        }
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
    NSLog(@"%@", error);
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
