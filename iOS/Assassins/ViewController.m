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

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *flashImage;
@property UIImagePickerController *picker;
@property BOOL flashOn;
@property (weak, nonatomic) IBOutlet UIButton *flipCamera;

@end

@implementation ViewController

UIImagePickerController *picker;
UIImagePickerController *picker;
CGFloat cameraAspectRatio = 4.0f/3.0f;
CGFloat scale;

- (IBAction)unwindToCamera:(UIStoryboardSegue *)segue {
    
    
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
    
    if ([segue.identifier isEqualToString:@"SegueToGameView"])
    {
        if ([segue.destinationViewController isKindOfClass:[GameTableViewController class]])
        {
            GameTableViewController *gtvc = (GameTableViewController *)segue.destinationViewController;
            gtvc.gameId = @"Jr9NNIwOiO";
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    picker  = [[UIImagePickerController alloc] init];
    [picker setDelegate:self];
    [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [picker setMediaTypes:@[@"public.image"]]; //specify image (not video)
    [picker setShowsCameraControls:NO]; //hide default camera controls
    [picker setNavigationBarHidden:YES];
    [picker setToolbarHidden:YES];
    [picker setAllowsEditing:NO];
    picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    self.flashOn = NO;
    
    //math to resize to size of phone
    CGSize screenBounds = [UIScreen mainScreen].bounds.size;
    cameraAspectRatio = 4.0f/3.0f;
    CGFloat camViewHeight = screenBounds.width * cameraAspectRatio;
    scale = screenBounds.height / camViewHeight;
    
    
    picker.cameraViewTransform = CGAffineTransformMakeTranslation(0, (screenBounds.height - camViewHeight) / 2.0);
    picker.cameraViewTransform = CGAffineTransformScale(picker.cameraViewTransform, scale, scale);

    
    [self.view addSubview:picker.view];
    [self.view sendSubviewToBack:picker.view];
     
    
    
    // CODE TO START THE GAME. RUN ONLY ONCE.
    
    /*PFQuery *query = [PFUser query];
    NSArray *users = [query findObjects];
    PFObject *game = [PFObject objectWithClassName:@"Game"];
    PFObject *contract1 = [PFObject objectWithClassName:@"Contract"];
    contract1[@"assassin"] = users[0];
    contract1[@"target"] = users[1];
    contract1[@"state"] = @"Active";
    
    PFObject *contract2 = [PFObject objectWithClassName:@"Contract"];
    contract2[@"assassin"] = users[1];
    contract2[@"target"] = users[0];
    contract2[@"state"] = @"Active";
    
    [contract1 save];
    [contract2 save];
    game[@"contracts"] = @[contract1, contract2];
    game[@"players"] = users;
    [game saveInBackground];*/
    
    // CODE TO HARDCODE THE GAMEID
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    [userData setObject:@"Jr9NNIwOiO" forKey:@"gameId"];
    if ([[PFUser currentUser].objectId isEqualToString:@"vNBEO89EaJ"])
        [userData setObject:@"EJyZKoN3pT" forKey:@"contractId"];
    else if ([[PFUser currentUser].objectId isEqualToString:@"t7lyXvXLiK"])
        [userData setObject:@"VDV0s2rv4k" forKey:@"contractId"];
    [userData synchronize];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Log in / sign up if no user signed in
    if (![PFUser currentUser])
    {
        [self showLogInAndSignUpView];
    }
    else
    {
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        if (currentInstallation[@"user"] == nil)
        {
            currentInstallation[@"user"] = [PFUser currentUser];
            [currentInstallation saveInBackground];
        }
        
    }
}

- (void)showLogInAndSignUpView
{
    // Create the log in view controller
    AssassinsLogInView *logInViewController = [[AssassinsLogInView alloc] init];
    [logInViewController setDelegate:self]; // Set ourselves as the delegate
    [logInViewController setFacebookPermissions:[NSArray arrayWithObjects:@"friends_about_me", @"publish_actions", nil]];
    [logInViewController setFields: PFLogInFieldsDefault | PFLogInFieldsTwitter | PFLogInFieldsFacebook | PFLogInFieldsDismissButton];
    
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

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}



- (IBAction)toggleFlash:(UIButton *)sender {
    
    if (self.flashOn == YES)
    {
        picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        [sender setImage:[UIImage imageNamed:  @"noFlash.png"] forState:UIControlStateNormal];
        self.flashOn = NO;
    }
    
    else
    {
        picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
        [sender setImage:[UIImage imageNamed: @"flash.png"] forState:UIControlStateNormal];
        self.flashOn = YES;
    }

}

- (IBAction)flipCamera:(id)sender {
    if (picker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
        [picker setCameraDevice:UIImagePickerControllerCameraDeviceRear];
    else
        [picker setCameraDevice:UIImagePickerControllerCameraDeviceFront];
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
