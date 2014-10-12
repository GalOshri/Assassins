//
//  UserTableViewController.m
//  Assassins
//
//  Created by Paul Stavropoulos on 8/6/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "UserTableViewController.h"
#import "AssassinationEventCell.h"
#import "AssassinsService.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "GameCell.h"
#import "GameTableViewController.h"
#import "CreateGameViewController.h"


@interface UserTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lifetimeSnipesLabel;
@property (strong, nonatomic) IBOutlet UILabel *lifetimeGamesLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIView *statusBarView;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePicture;
@property (weak, nonatomic) IBOutlet UIButton *pendingContractsButton;
@property (strong, nonatomic) IBOutlet UIView *backgroundHeaderView;



@property (strong, nonatomic) NSMutableArray *games;
@property (strong, nonatomic) NSMutableArray *completedContracts;

@end

@implementation UserTableViewController

- (IBAction)unwindToUserPage:(UIStoryboardSegue *)segue
{
    if ([segue.identifier isEqualToString:@"UnwindOnCreate"])
    {
        if ([segue.sourceViewController isKindOfClass:[CreateGameViewController class]])
        {
            CreateGameViewController *cgvc = (CreateGameViewController *)segue.sourceViewController;
            
            self.goToGame = cgvc.createdGame;
            [self.games addObject:self.goToGame];
            [self.tableView reloadData];
            
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SegueToGameView"])
    {
        if ([segue.destinationViewController isKindOfClass:[GameTableViewController class]])
        {
            GameTableViewController *gtvc = (GameTableViewController *)segue.destinationViewController;
            GameCell *cell = (GameCell *)sender;
            gtvc.game = cell.game;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.backgroundHeaderView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"spyBckgnd.png"]]];
    
    self.games = [[AssassinsService getGameList:YES] mutableCopy];
    PFUser *currentUser = [PFUser currentUser];
    
    
    
    self.lifetimeSnipesLabel.text = [NSString stringWithFormat:@"%d total assassinations", [currentUser[@"lifetimeSnipes"] intValue]];
    self.lifetimeGamesLabel.text = [NSString stringWithFormat:@"%d completed games",[currentUser[@"lifetimeGames"] intValue]];
    
    //[self.tableView reloadData];
    //[AssassinsService populateCompletedContracts:self.completedContracts withGameId:@"Jr9NNIwOiO" withTable:self.tableView];

    self.usernameLabel.text = [NSString stringWithFormat:@"%@", [PFUser currentUser].username];
    
    // [AssassinsService populateUserGames:self.games];
    // [AssassinsService populateCompletedContracts:self.completedContracts withGameId:@"Jr9NNIwOiO" withTable:self.tableView];
    
    // set picture right he-ah
    self.profilePicture.profileID = [NSString stringWithString:currentUser[@"facebookId"]];
    self.profilePicture.pictureCropping = FBProfilePictureCroppingSquare;
    [[self.profilePicture layer] setCornerRadius:self.profilePicture.frame.size.width/2];
    [[self.profilePicture layer] setMasksToBounds:YES];
    
    UIImage *backgroundImg = nil;
    
    
    for (NSObject *obj in [self.profilePicture subviews]) {
        if ([obj isMemberOfClass:[UIImageView class]]) {
            UIImageView *objImg = (UIImageView *)obj;
            backgroundImg = objImg.image;
            break;
        }
    }
    
    /* FBProfilePictureView *imageView = [[FBProfilePictureView alloc] init];
    imageView.profileID= [NSString stringWithString:currentUser[@"facebookId"]];
    self.backgroundHeaderView.pictureCropping = FBProfilePictureCroppingSquare;
    [self.backgroundHeaderView setAlpha:0.6];

    [self.backgroundHeaderView addSubview:imageView ];
    [self.backgroundHeaderView sendSubviewToBack:imageView ];
    //self.backgroundHeaderView.profileID = [NSString stringWithString:currentUser[@"facebookId"]];
    //self.backgroundHeaderView.pictureCropping = FBProfilePictureCroppingSquare;
    //[self.backgroundHeaderView setAlpha:0.6];
    */
    
    // Change table separators
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    
    // unhide pending contracts button if necessary
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.numberPendingSnipe = [AssassinsService getNumberOfPendingSnipes];
    
    if (appDelegate.numberPendingSnipe > 0)
        [self.pendingContractsButton setHidden:NO];

    // remove table separators when not needed
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void) viewDidAppear:(BOOL)animated
{
    if (self.goToGame)
    {
        GameCell *createdGameCell = [[GameCell alloc] init];
        createdGameCell.game = self.goToGame;
        self.goToGame = nil;
        [self.tableView reloadData];
        [self performSegueWithIdentifier:@"SegueToGameView" sender:createdGameCell];

    }
    
    if (self.goToPendingNotifcations) {
        self.goToPendingNotifcations = NO;
        [self performSegueWithIdentifier:@"userTableToPendingSnipes" sender:self];
    }
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
    return [self.games count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Game *currentGame = [self.games objectAtIndex:indexPath.row];
    GameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userGames" forIndexPath:indexPath];
    cell.gameNameLabel.text = currentGame.name;
    cell.game = currentGame;
    
    if (currentGame.isComplete)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Won by %@", currentGame.winnerName];
    }
    else
    {
        // grab current contract to fill in data
        cell.currentContract = [AssassinsService getContractForGame:cell.game.gameId];
        
        // if current contract exists
        if (cell.currentContract)
        {
            NSArray *nameArray = [cell.currentContract.targetName componentsSeparatedByString:@" "];
            NSString *firstName = nameArray[0];

            cell.detailLabel.text = [NSString stringWithFormat:@"Your target: %@", firstName];
            cell.targetProfilePic.profileID = cell.currentContract.targetFbId;
            cell.targetProfilePic.pictureCropping = FBProfilePictureCroppingSquare;
            [[cell.targetProfilePic layer] setCornerRadius:5];
            [[cell.targetProfilePic layer] setMasksToBounds:YES];
        }
        
        // no contract exists. You were eliminated.
        else
        {
            cell.detailLabel.text = @"You were eliminated";
            [cell.targetProfilePic setHidden:YES];
        }

    }

    return cell;
}

-(void) tableView:(UITableView *)tableView willDisplayCell:(GameCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell.targetProfilePic isHidden]) {
        // move text over
        [cell.detailLabel setFrame:CGRectMake(cell.targetProfilePic.frame.origin.x, cell.targetProfilePic.frame.origin.y, cell.detailLabel.frame.size.width, cell.detailLabel.frame.size.height)];
    }
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
