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
            VerifySnipeViewController *vsvc = (VerifySnipeViewController *)segue.destinationViewController;
            PendingContractsTableViewCell *cell = (PendingContractsTableViewCell *)sender;
            vsvc.contract = cell.contract;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorWithRed:22.0/256 green:174.0/256 blue:255.0/256 alpha:1.0]];
    
    // get pending snipes for user!
    self.pendingContracts = [[AssassinsService getPendingSnipes] mutableCopy];
    
    PFUser *currentUser = [PFUser currentUser];
    self.usernameLabel.text = currentUser.username;
    
    self.profilePicture.profileID = [NSString stringWithString:currentUser[@"facebookId"]];
    self.profilePicture.pictureCropping = FBProfilePictureCroppingSquare;
    [[self.profilePicture layer] setCornerRadius:5];
    [[self.profilePicture layer] setMasksToBounds:YES];
    
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
    
    if ([[PFUser currentUser].username isEqualToString:currentContract.targetName])
    {
        cell.pendingLabel.text = [NSString stringWithFormat:@"Did %@ tag you?", currentContract.assassinName];
        cell.profilePicture.profileID = currentContract.assassinFbId;
    }
    
    else
    {
        cell.pendingLabel.text = [NSString stringWithFormat:@"Did you tag %@?", currentContract.targetName];
        cell.profilePicture.profileID = currentContract.targetFbId;
    }
    
    cell.profilePicture.pictureCropping = FBProfilePictureCroppingSquare;
    [[cell.profilePicture layer] setCornerRadius:5];
    [[cell.profilePicture layer] setMasksToBounds:YES];
    
    cell.contract = currentContract;
    
    return cell;
}

@end
