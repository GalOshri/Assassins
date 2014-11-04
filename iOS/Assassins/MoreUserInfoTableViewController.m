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
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIView *statusBarView;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *profilePicture;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UIButton *statusBarBack;
@property (weak, nonatomic) IBOutlet UILabel *statusBarUsernameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

/*
 @property (weak, nonatomic) IBOutlet UILabel *lifetimeGamesLabel;
 @property (weak, nonatomic) IBOutlet UILabel *lifetimeSnipesLabel;
 */

@property (strong, nonatomic) NSMutableArray *games;

@end

@implementation MoreUserInfoTableViewController

/*
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

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
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.backgroundHeaderView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"spyBckgnd.png"]]];
    [self.statusBarView setAlpha:0.0];
    
    PFUser *currentUser = [PFUser currentUser];
    self.usernameLabel.text = [NSString stringWithFormat:@"%@", currentUser.username];
    self.statusBarUsernameLabel.text = [NSString stringWithFormat:@"%@", currentUser.username];
    
    self.profilePicture.profileID = [NSString stringWithString:currentUser[@"facebookId"]];
    self.profilePicture.pictureCropping = FBProfilePictureCroppingSquare;
    [[self.profilePicture layer] setCornerRadius:self.profilePicture.frame.size.width/2];
    [[self.profilePicture layer] setMasksToBounds:YES];
    
    // remove table separators when not needed
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self.activityIndicatorView startAnimating];
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        self.games = [[AssassinsService getGameList:NO] mutableCopy];

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
    
    // set profileID to nil so that we don't display FB image from previous cell
    cell.targetProfilePic.profileID = nil;
    
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
        [[cell.targetProfilePic  layer] setCornerRadius:cell.targetProfilePic.frame.size.width/2];
        [[cell.targetProfilePic layer] setMasksToBounds:YES];
    }

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 94.0;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    // make status bar change color and add name
    if (scrollView.contentOffset.y <= 100.0)
        [self.statusBarView setAlpha:0.0];
    
    else if (scrollView.contentOffset.y >= 100.0 && scrollView.contentOffset.y <= 115)
    {
        [self.statusBarView setAlpha: 0.0 + (scrollView.contentOffset.y - 100.0) / 15.50];
        [self.statusBarUsernameLabel setHidden:YES];
        [self.statusBarBack setHidden:YES];
    }
    
    else
    {
        [self.statusBarView setAlpha:1.0];
        [self.statusBarUsernameLabel setHidden:NO];
        [self.statusBarBack setHidden:NO];
    }
}

@end
