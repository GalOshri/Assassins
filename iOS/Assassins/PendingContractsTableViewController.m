//
//  PendingContractsTableViewController.m
//  Assassins
//
//  Created by Paul Stavropoulos on 8/10/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "PendingContractsTableViewController.h"
#import "PendingContractsTableViewCell.h"
#import "VerifySnipeViewController.h"
#import "Contract.h"
#import "AssassinsService.h"

@interface PendingContractsTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIView *statusBarView;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePicture;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (strong, nonatomic) NSMutableArray *pendingContracts;

@end

@implementation PendingContractsTableViewController


#pragma mark - Navigation

- (IBAction)unwindToPendingSnipesPage:(UIStoryboardSegue *)segue
{
    if (([segue.identifier isEqualToString:@"UnwindWithConfirmedSnipe"]) || ([segue.identifier isEqualToString:@"UnwindWithDeniedSnipe"]))
    {
        if ([segue.sourceViewController isKindOfClass:[VerifySnipeViewController class]])
        {
            VerifySnipeViewController *vsvc = (VerifySnipeViewController *)segue.sourceViewController;
            
            [self.pendingContracts removeObjectIdenticalTo:vsvc.contract];
            
            [self.tableView reloadData];
        }
    }
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SegueToSnipeVerify"]) {
        if ([segue.destinationViewController isKindOfClass:[VerifySnipeViewController class]])
        {
            if (self.goToContract)
            {
                VerifySnipeViewController *vsvc = (VerifySnipeViewController *)segue.destinationViewController;
                vsvc.contract = self.goToContract;
            }
            
            else
            {
                VerifySnipeViewController *vsvc = (VerifySnipeViewController *)segue.destinationViewController;
                PendingContractsTableViewCell *cell = (PendingContractsTableViewCell *)sender;
                vsvc.contract = cell.contract;
            }
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.goToContract != nil)
    {
        // perform segue
        [self performSegueWithIdentifier:@"SegueToSnipeVerify" sender:self];
    }
    
    else
    {
        [self.view setBackgroundColor:[UIColor whiteColor]];
        
        PFUser *currentUser = [PFUser currentUser];
        self.usernameLabel.text = currentUser.username;

        self.profilePicture.profileID = [NSString stringWithString:currentUser[@"facebookId"]];
        self.profilePicture.pictureCropping = FBProfilePictureCroppingSquare;
        [[self.profilePicture layer] setCornerRadius:self.profilePicture.frame.size.width / 2];
        [[self.profilePicture layer] setMasksToBounds:YES];\
        
        // get pending snipes for user!
        [self.activityIndicatorView startAnimating];
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Add code here to do background processing
            self.pendingContracts = [[AssassinsService getPendingSnipes] mutableCopy];
        
            dispatch_async( dispatch_get_main_queue(), ^{
                // Add code here to update the UI/send notifications based on the
                // results of the background processing
                
                // reload data stop spinner
                [self.tableView reloadData];
                [self.activityIndicatorView stopAnimating];
                [self.activityIndicatorView setHidden:YES];
            });
        });
    }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.statusBarView.frame = CGRectMake(0, scrollView.contentOffset.y, self.statusBarView.frame.size.width, self.statusBarView.frame.size.height);
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.pendingContracts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     PendingContractsTableViewCell *cell = (PendingContractsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"pendingSnipeCell" forIndexPath:indexPath];
    
    // grab correct contract
    Contract *currentContract = [self.pendingContracts objectAtIndex:[indexPath row]];
    
    // time altercation
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"hh:mm a MMM-dd" options:0 locale:[NSLocale currentLocale]]];
    NSString *theTime = [dateFormatter stringFromDate:currentContract.time];
    cell.pendingDateLabel.text = theTime;
    
    NSArray *nameArray = [currentContract.targetName componentsSeparatedByString:@" "];
    NSString *firstName = nameArray[0];
    cell.pendingLabel.text = [NSString stringWithFormat:@"Is %@ still alive?", firstName];
    cell.profilePicture.profileID = currentContract.targetFbId;
    
    cell.profilePicture.pictureCropping = FBProfilePictureCroppingSquare;
    [[cell.profilePicture layer] setCornerRadius:5];
    [[cell.profilePicture layer] setMasksToBounds:YES];
    
    cell.contract = currentContract;
    
    return cell;
}

@end
