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

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *flashImage;
@property (strong, nonatomic) IBOutlet UIImageView *firstImage;
@property UIImagePickerController *picker;
@property BOOL flashOn;

@end

@implementation ViewController

UIImagePickerController *picker;

- (IBAction)unwindToCamera:(UIStoryboardSegue *)segue {
    
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SnipeSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[SnipeSubmitView class]])
        {
            SnipeSubmitView *ssv = (SnipeSubmitView *)segue.destinationViewController;
            UIImage *chosenImage;
            ssv.snipeImage = (UIImage *)sender;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"HI");


    
    /*
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
    CGFloat cameraAspectRatio = 4.0f/3.0f;
    CGFloat camViewHeight = screenBounds.width * cameraAspectRatio;
    CGFloat scale = screenBounds.height / camViewHeight;
    
    
    picker.cameraViewTransform = CGAffineTransformMakeTranslation(0, (screenBounds.height - camViewHeight) / 2.0);
    picker.cameraViewTransform = CGAffineTransformScale(picker.cameraViewTransform, scale, scale);

    
    [self.view addSubview:picker.view];
    [self.view sendSubviewToBack:picker.view];
 //   self.imageView.frame = CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, picker.view.frame.size.width, picker.view.frame.size.height);
     */
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Log in / sign up if no user signed in
    if (![PFUser currentUser])
    {
        [self showLogInAndSignUpView];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePicture:(UIButton *)sender {
    [picker takePicture];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
  //  self.imageView.image = chosenImage;
    [self performSegueWithIdentifier:@"SnipeSegue" sender:chosenImage];
 //   self.firstImage.image = chosenImage;
    
    //  [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (IBAction)toggleFlash:(UIButton *)sender {
    
    if (self.flashOn == YES) {
        NSLog(@"on-->off");
        picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        [sender setImage:[UIImage imageNamed:  @"noFlash.png"] forState:UIControlStateNormal];
        self.flashOn = NO;
    }
    
    else {
        NSLog(@"off-->on");
        picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
        [sender setImage:[UIImage imageNamed: @"flash.png"] forState:UIControlStateNormal];
        self.flashOn = YES;
    }

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
