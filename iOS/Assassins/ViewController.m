//
//  ViewController.m
//  Assassins
//
//  Created by Gal Oshri on 7/21/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "ViewController.h"
#import "SnipeSubmitView.h"

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *firstImage;

@end

@implementation ViewController

UIImagePickerController *picker;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SnipeSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[SnipeSubmitView class]])
        {
            SnipeSubmitView *ssv = (SnipeSubmitView *)segue.destinationViewController;
            ssv.snipeImage = (UIImage *)sender;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    picker  = [[UIImagePickerController alloc] init];
    
    [picker setDelegate:self];
    [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
    [picker setMediaTypes:@[@"public.image"]]; //specify image (not video)
    [picker setShowsCameraControls:NO]; //hide default camera controls
    [picker setNavigationBarHidden:YES];
    [picker setToolbarHidden:YES];
    [picker setAllowsEditing:NO];
    picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
  
    picker.view.frame = CGRectMake(0, 0, picker.view.frame.size.width, picker.view.frame.size.height);
    [self.view addSubview:picker.view];
    [self.view sendSubviewToBack:picker.view];
 //   self.imageView.frame = CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, picker.view.frame.size.width, picker.view.frame.size.height);
    
    
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takePicture:(UIButton *)sender {
    
    NSLog(@"WEH");
    [picker takePicture];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
  //  self.imageView.image = chosenImage;
    
    NSLog(@"HI");
    [self performSegueWithIdentifier:@"SnipeSegue" sender:chosenImage];
 //   self.firstImage.image = chosenImage;
    
    //  [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

@end
