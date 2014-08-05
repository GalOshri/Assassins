//
//  verifySnipeViewController.m
//  Assassins
//
//  Created by Paul Stavropoulos on 8/4/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "VerifySnipeViewController.h"

@interface VerifySnipeViewController ()


@end

@implementation VerifySnipeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:self.file.url]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    UIImage *img = [[UIImage alloc] initWithData:data];
                    
                    self.snipeImage.image = img;

                }];
            }] resume];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)ConfirmedSnipe:(id)sender {
}
- (IBAction)DeclinedSnipe:(id)sender {
}

@end
