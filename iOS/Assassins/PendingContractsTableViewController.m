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

@property (strong, nonatomic) NSArray *pendingContracts;

@end

@implementation PendingContractsTableViewController

#pragma mark - Navigation

- (IBAction)unwindToPendingSnipesPage:(UIStoryboardSegue *)segue {
    
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
    
    // get pending snipes for user!
    self.pendingContracts = [AssassinsService getPendingSnipes];
    
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
    
    NSLog(@"%@, %@", [PFUser currentUser].username, currentContract.targetName);
    
    if ([[PFUser currentUser].username isEqualToString:currentContract.targetName])
        cell.pendingLabel.text = [NSString stringWithFormat:@"Were you shot by %@?", currentContract.assassinName];
    else
        cell.pendingLabel.text = [NSString stringWithFormat:@"Did you shoot %@?", currentContract.targetName];
    
    cell.contract = currentContract;
    
  
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/




@end
