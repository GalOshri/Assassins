//
//  ViewController.m
//  Assassins
//
//  Created by Gal Oshri on 7/21/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "ViewController.h"
#import "SnipeSubmitView.h"
#import "UIImage+Resize.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *flashImage;
@property (strong, nonatomic) IBOutlet UIImageView *firstImage;
@property UIImagePickerController *picker;
@property BOOL flashOn;

@end

@implementation ViewController

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
    CGFloat camViewHeight = screenBounds.width * cameraAspectRatio;
    scale = screenBounds.height / camViewHeight;
    
    
    picker.cameraViewTransform = CGAffineTransformMakeTranslation(0, (screenBounds.height - camViewHeight) / 2.0);
    NSLog(@"screenheight: %f, camHeight:%f, diff: %f", screenBounds.height, camViewHeight, screenBounds.height - camViewHeight );
    picker.cameraViewTransform = CGAffineTransformScale(picker.cameraViewTransform, scale, scale);

    
    [self.view addSubview:picker.view];
    [self.view sendSubviewToBack:picker.view];
 //   self.imageView.frame = CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, picker.view.frame.size.width, picker.view.frame.size.height);
}


- (void) viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePicture:(UIButton *)sender
{
    [picker takePicture];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    NSLog(@"%@", info);

    [self performSegueWithIdentifier:@"SnipeSegue" sender:chosenImage];
    //  [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (IBAction)toggleFlash:(UIButton *)sender
{
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

@end
