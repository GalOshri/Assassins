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
        
        // get pending snipes for user!
        self.pendingContracts = [[AssassinsService getPendingSnipes] mutableCopy];
        
        PFUser *currentUser = [PFUser currentUser];
        self.usernameLabel.text = currentUser.username;
        
        self.profilePicture.profileID = [NSString stringWithString:currentUser[@"facebookId"]];
        self.profilePicture.pictureCropping = FBProfilePictureCroppingSquare;
        [[self.profilePicture layer] setCornerRadius:5];
        [[self.profilePicture layer] setMasksToBounds:YES];
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
    NSArray *timeArray = [[NSString stringWithFormat:@"%@", currentContract.time] componentsSeparatedByString:@"+"];
    NSString *time = [timeArray objectAtIndex:0];
    cell.pendingDateLabel.text = time;
    
    NSArray *nameArray = [currentContract.assassinName componentsSeparatedByString:@" "];
    NSString *firstName = nameArray[0];
    cell.pendingLabel.text = [NSString stringWithFormat:@"Is %@ still alive?", firstName];
    cell.profilePicture.profileID = currentContract.assassinFbId;
    
    cell.profilePicture.pictureCropping = FBProfilePictureCroppingSquare;
    [[cell.profilePicture layer] setCornerRadius:5];
    [[cell.profilePicture layer] setMasksToBounds:YES];
    
    cell.contract = currentContract;
    
    return cell;
}

@end
