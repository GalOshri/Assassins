//
//  verifySnipeViewController.m
//  Assassins
//
//  Created by Paul Stavropoulos on 8/4/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "VerifySnipeViewController.h"

@interface VerifySnipeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *commentField;
@property (weak, nonatomic) IBOutlet UILabel *verifyLabel;
@property (weak, nonatomic) IBOutlet UIButton *VerifySnipeButton;
@property (weak, nonatomic) IBOutlet UIButton *declineSnipeButton;
@property (weak, nonatomic) IBOutlet UIView *verifyBackground;

@end

@implementation VerifySnipeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /* NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithURL:[NSURL URLWithString:self.file.url]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    UIImage *img = [[UIImage alloc] initWithData:data];
                    
                    self.snipeImage.image = img;

                }];
            }] resume];
     */
    self.snipeImage.image = self.contract.image;
}


-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // set commentField
    if (![self.contract.comment isEqualToString:@""])
    {
        [self.commentField setHidden:NO];
        [self.commentField setText:self.contract.comment];
        self.commentField.frame = CGRectMake(0,self.contract.commentYCoord, self.commentField.frame.size.width, self.commentField.frame.size.height);
        NSLog(@"%f", self.contract.commentYCoord);
    }
    
    // set the verify snipe section
    if (![[PFUser currentUser].username isEqualToString: self.contract.targetName]) {
        // user is not the victim, and cannot take action
        [self.VerifySnipeButton setHidden:YES];
        [self.declineSnipeButton setHidden:YES];
        [self.verifyLabel setText: @"This snipe is pending"];
        self.verifyLabel.center = CGPointMake(self.verifyLabel.center.x, (2* self.verifyBackground.frame.origin.x + self.verifyBackground.frame.size.height)/2);
    }
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
    PFQuery *query = [PFQuery queryWithClassName:@"Contract"];
    
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:self.contract.contractId block:^(PFObject *contract, NSError *error) {
        
        // Now let's update it with some new data. In this case, only cheatMode and score
        // will get sent to the cloud. playerName hasn't changed.
        contract[@"state"] = @"Completed";
        [contract saveInBackground];
        
        PFUser *assassin = contract[@"assassin"];
        
        // Find devices associated with these users
        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"user" equalTo:assassin];
        
        // Send push notification to query
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:pushQuery]; // Set our Installation query
        [push setMessage:@"Your assassination was confirmed!"];
        [push sendPushInBackground];
    }];
}


- (IBAction)DeclinedSnipe:(id)sender {
    PFQuery *query = [PFQuery queryWithClassName:@"Contract"];
    
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:self.contract.contractId block:^(PFObject *contract, NSError *error) {
        
        // Now let's update it with some new data. In this case, only cheatMode and score
        // will get sent to the cloud. playerName hasn't changed.
        contract[@"state"] = @"Active";
        [contract saveInBackground];
        
        PFUser *assassin = contract[@"assassin"];
        
        // Find devices associated with these users
        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"user" equalTo:assassin];
        
        // Send push notification to query
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:pushQuery]; // Set our Installation query
        [push setMessage:@"Your assassination was denied."];
        [push sendPushInBackground];
    }];
}

@end
