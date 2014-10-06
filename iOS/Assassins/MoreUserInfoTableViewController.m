//
//  MoreUserInfoTableViewController.m
//  Assassins
//
//  Created by Paul Stavropoulos on 9/27/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "MoreUserInfoTableViewController.h"
#import "GameTableViewController.h"
#import "AssassinsService.h"
#import "Game.h"
#import "GameCell.h"

@interface MoreUserInfoTableViewController ()

@property (weak, nonatomic) IBOutlet UIView *backgroundHeaderView;
@property (weak, nonatomic) IBOutlet UIView *statusBarView;
@property (weak, nonatomic) IBOutlet UILabel *lifetimeSnipesLabel;
@property (weak, nonatomic) IBOutlet UILabel *lifetimeGamesLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *profilePicture;

@property (strong, nonatomic) NSMutableArray *games;

@end

@implementation MoreUserInfoTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
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
    
    self.games = [[AssassinsService getGameList:NO] mutableCopy];

    PFUser *currentUser = [PFUser currentUser];
    self.lifetimeSnipesLabel.text = [NSString stringWithFormat:@"%d total assassinations", [currentUser[@"lifetimeSnipes"] intValue]];
    self.lifetimeGamesLabel.text = [NSString stringWithFormat:@"%d completed games",[currentUser[@"lifetimeGames"] intValue]];
    
    self.usernameLabel.text = [NSString stringWithFormat:@"%@", [PFUser currentUser].username];
    
    self.profilePicture.profileID = [NSString stringWithString:currentUser[@"facebookId"]];
    self.profilePicture.pictureCropping = FBProfilePictureCroppingSquare;
    [[self.profilePicture layer] setCornerRadius:self.profilePicture.frame.size.width/2];
    [[self.profilePicture layer] setMasksToBounds:YES];

    // remove table separators when not needed
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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
    
    // Configure the cell...
    if (currentGame.isComplete)
    {
        NSArray *nameArray = [currentGame.winnerName componentsSeparatedByString:@" "];
        NSString *firstName = nameArray[0];

        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.detailLabel.text = [NSString stringWithFormat:@"Won by %@", firstName];
        
        // set picture to winner
        cell.targetProfilePic.profileID = cell.game.winnerFbId;
        cell.targetProfilePic.pictureCropping = FBProfilePictureCroppingSquare;
        [[cell.targetProfilePic  layer] setCornerRadius:5];
        [[cell.targetProfilePic layer] setMasksToBounds:YES];
    }

    return cell;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.statusBarView.frame = CGRectMake(0, scrollView.contentOffset.y, self.statusBarView.frame.size.width, self.statusBarView.frame.size.height);
}

@end
