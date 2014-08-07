//
//  UserTableViewController.m
//  Assassins
//
//  Created by Paul Stavropoulos on 8/6/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "UserTableViewController.h"
#import "GameEventTableViewCell.h"
#import "Game.h"

@interface UserTableViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *totalSnipes;
@property (weak, nonatomic) IBOutlet UILabel *isAliveLabel;

@property (strong, nonatomic) NSMutableArray *games;
@property (strong, nonatomic) NSMutableArray *userCompletedContracts;


@end

@implementation UserTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    if (section == 0)
        return [self.games count];
    else
        return [self.userCompletedContracts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        Game *currentGame = [self.games objectAtIndex:indexPath.row];
        //TODO: set currentGame to pull name and
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userGames" forIndexPath:indexPath];
        cell = [[UITableViewCell alloc] init];
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
        cell.textLabel.text = currentGame.gameName;
        return cell;
    }
    
    else
    {
        // display completed contracts dealing with user (user is assassin, user is target and died)
        // call to AssassinsService
        GameEventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userEvents" forIndexPath:indexPath];
        [cell.userImage setImage:[UIImage imageNamed:@"snipeCircle.png"]];
        cell.headlineLabel.text = @"placeholder for now; we'll fill";
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
