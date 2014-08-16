//
//  UserTableViewController.m
//  Assassins
//
//  Created by Paul Stavropoulos on 8/6/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "UserTableViewController.h"
#import "AssassinationEventCell.h"
#import "Game.h"
#import "AssassinsService.h"
#import <Parse/Parse.h>
#import "GameCell.h"
#import "GameTableViewController.h"


@interface UserTableViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *lifetimeSnipesLabel;
@property (strong, nonatomic) IBOutlet UILabel *lifetimeGamesLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIView *statusBarView;


@property (strong, nonatomic) NSArray *games;
@property (strong, nonatomic) NSMutableArray *completedContracts;

@end

@implementation UserTableViewController

- (IBAction)unwindToUserPage:(UIStoryboardSegue *)segue {
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SegueToGameView"])
    {
        if ([segue.destinationViewController isKindOfClass:[GameTableViewController class]])
        {
            GameTableViewController *gtvc = (GameTableViewController *)segue.destinationViewController;
            GameCell *cell = (GameCell *)sender;
            gtvc.gameId = cell.gameId;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.completedContracts = [[NSMutableArray alloc] init];
        self.games = [AssassinsService getGameList];
    PFUser *currentUser = [PFUser currentUser];
    
    self.lifetimeSnipesLabel.text = [NSString stringWithFormat:@"%d total hits", [currentUser[@"lifetimeSnipes"] intValue]];
    self.lifetimeGamesLabel.text = [NSString stringWithFormat:@"%d total games",[currentUser[@"lifetimeGames"] intValue]];
    
    //[self.tableView reloadData];
    //[AssassinsService populateCompletedContracts:self.completedContracts withGameId:@"Jr9NNIwOiO" withTable:self.tableView];

    self.usernameLabel.text = [NSString stringWithFormat:@"%@", [PFUser currentUser].username];
    
    // [AssassinsService populateUserGames:self.games];
    // [AssassinsService populateCompletedContracts:self.completedContracts withGameId:@"Jr9NNIwOiO" withTable:self.tableView];
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.statusBarView.frame = CGRectMake(0, scrollView.contentOffset.y, self.statusBarView.frame.size.width, self.statusBarView.frame.size.height);
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    // Change to 2 if we want events
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return [self.games count];
    else
        return [self.completedContracts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        Game *currentGame = [self.games objectAtIndex:indexPath.row];

        GameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userGames" forIndexPath:indexPath];
        //cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        cell.textLabel.text = currentGame.name;
        cell.gameId = currentGame.gameId;
        return cell;
    }
    
    else
    {
        // display completed contracts dealing with user (user is assassin, user is target and died)
        // call to AssassinsService
        AssassinationEventCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userEvents" forIndexPath:indexPath];
        //[cell.userImage setImage:[UIImage imageNamed:@"snipeCircle.png"]];
        //cell.headlineLabel.text = @"placeholder for now; we'll fill";
        cell.textLabel.text = @"hi";
        return cell;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"Your Games";
    else
        return @"Your Events";
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
