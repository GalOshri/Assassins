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
#import "Contract.h"


@interface UserTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIView *statusBarView;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePicture;
@property (strong, nonatomic) IBOutlet UIView *backgroundHeaderView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lifetimeSnipesLabel;
@property (weak, nonatomic) IBOutlet UILabel *lifetimeGamesLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusBarUsernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *statusBarCameraIcon;

// @property (weak, nonatomic) IBOutlet UIButton *pendingContractsButton;

@property (strong, nonatomic) NSMutableArray *games;
@property (strong, nonatomic) NSMutableArray *cellContracts;
@property (strong, nonatomic) NSCache *cellCache;

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
        }
    }
    
    [self.tableView reloadData];
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
            gtvc.currentContract = cell.currentContract;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.statusBarView setAlpha:0.0];
    [self.backgroundHeaderView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"spyBckgnd.png"]]];
    
    // set items from pfuser currentuser
    PFUser *currentUser = [PFUser currentUser];
    self.lifetimeSnipesLabel.text = [NSString stringWithFormat:@"%d total assassinations", [currentUser[@"lifetimeSnipes"] intValue]];
    self.lifetimeGamesLabel.text = [NSString stringWithFormat:@"%d completed games",[currentUser[@"lifetimeGames"] intValue]];
    self.usernameLabel.text = [NSString stringWithFormat:@"%@", currentUser.username];
    self.statusBarUsernameLabel.text = [NSString stringWithFormat:@"%@", currentUser.username];
    
    // AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //  table work
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // set picture right he-ah
    self.profilePicture.profileID = [NSString stringWithString:currentUser[@"facebookId"]];
    self.profilePicture.pictureCropping = FBProfilePictureCroppingSquare;
    [[self.profilePicture layer] setCornerRadius:self.profilePicture.frame.size.width/2];
    [[self.profilePicture layer] setMasksToBounds:YES];
    
    // initiate self.cellContracts
    self.cellContracts = [[NSMutableArray alloc] init];
    
    [self.activityIndicatorView startAnimating];
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        self.games = [[AssassinsService getGameList:YES] mutableCopy];
        
        // get all currentContracts for game Id's
        for(Game *currentGame in self.games)
        {
            Contract *currentContract = [AssassinsService getContractForGame:currentGame.gameId];
            if (currentContract != nil)
                [self.cellContracts addObject:currentContract];
            else
            {
                Contract *emptyContract = [[Contract alloc] init];
                [self.cellContracts addObject:emptyContract];
            }
        }
        
        dispatch_async( dispatch_get_main_queue(), ^{
            // Add code here to update the UI/send notifications based on the
            // results of the background processing
            
            UIImage *backgroundImg = nil;
            for (NSObject *obj in [self.profilePicture subviews]) {
                if ([obj isMemberOfClass:[UIImageView class]]) {
                    UIImageView *objImg = (UIImageView *)obj;
                    backgroundImg = objImg.image;
                    break;
                }
            }

            // unhide pending contracts button if necessary
            //if (appDelegate.numberPendingSnipe > 0)
                //[self.pendingContractsButton setHidden:NO];
            
            // reload data stop spinner
            [self.tableView reloadData];
            [self.activityIndicatorView stopAnimating];
            [self.activityIndicatorView setHidden:YES];
        });
    });
}

- (void) viewDidAppear:(BOOL)animated
{
    if (self.goToGame)
    {
        GameCell *createdGameCell = [[GameCell alloc] init];
        createdGameCell.game = self.goToGame;
        
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Add code here to do background processing

            // if don't have self.currentContract, you just created game. Go get
            createdGameCell.currentContract = [AssassinsService getContractForGame:self.goToGame.gameId];
            
            dispatch_async( dispatch_get_main_queue(), ^{
                // perform segue, reload data, and then set goToGame to nil.
                [self.tableView reloadData];
                [self performSegueWithIdentifier:@"SegueToGameView" sender:createdGameCell];
                self.goToGame = nil;
            });
        });
    }
    
/*    if (self.goToPendingNotifcations) {
        self.goToPendingNotifcations = NO;
        [self performSegueWithIdentifier:@"userTableToPendingSnipes" sender:self];
    }
*/
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
        [self.statusBarCameraIcon setHidden:YES];
    }
    
    else
    {
        [self.statusBarView setAlpha:1.0];
        [self.statusBarUsernameLabel setHidden:NO];
        [self.statusBarCameraIcon setHidden:NO];
    }
    
    // NSLog(@"%f",scrollView.contentOffset.y);
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
    
    GameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userGames" forIndexPath:indexPath];
    
    cell.game = [self.games objectAtIndex:indexPath.row];
    cell.gameNameLabel.text = cell.game.name;
    
    // grab current contract to fill in data
    cell.currentContract = [self.cellContracts objectAtIndex:indexPath.row];

    // if there is a pending snipe, it takes precedent over showing your target
    if([cell.game.numberPendingContracts integerValue] > 0)
    {
        // set image to pending img
        for (NSObject *obj in [cell.targetProfilePic subviews]) {
            if ([obj isMemberOfClass:[UIImageView class]]) {
                UIImageView *objImg = (UIImageView *)obj;
                objImg.image = [UIImage imageNamed:@"userSilhouettePending.png"];
                break;
            }
        }

        // if the pending snipe is of you snipe
        if([cell.currentContract.state isEqualToString:@"Pending"])
            cell.detailLabel.text = [NSString stringWithFormat:@"there is a pending snipe of you"];
        
        // pending snipe is someone else's
        else
            cell.detailLabel.text = [NSString stringWithFormat:@"help validate pending snipes"];
    }
    
    // if current contract exists
    else if ([cell.currentContract.state isEqualToString:@"Active"])
    {
        NSArray *nameArray = [cell.currentContract.targetName componentsSeparatedByString:@" "];
        NSString *firstName = nameArray[0];
        cell.detailLabel.text = [NSString stringWithFormat:@"Your target: %@", firstName];
        
        // see if picture is in Cache
        NSString *photoId = [NSString stringWithFormat:@"%@", cell.currentContract.targetFbId];
        FBProfilePictureView *fbProfilePic = [self.cellCache objectForKey:photoId];

        if (fbProfilePic)
        {
            cell.targetProfilePic = fbProfilePic;
        }
        
        // if not, find and assign
        else
        {
            cell.targetProfilePic.profileID = cell.currentContract.targetFbId;
            cell.targetProfilePic.pictureCropping = FBProfilePictureCroppingSquare;
            
            [self.cellCache setObject:cell.targetProfilePic forKey:[NSString stringWithFormat:@"%@", cell.currentContract.targetFbId]];
        }
        
    }
    
    //  you have been eliminated
    else
    {
        cell.detailLabel.text = [NSString stringWithFormat:@"You have been elimintated"];
        
        // set image to pending img
        for (NSObject *obj in [cell.targetProfilePic subviews]) {
            if ([obj isMemberOfClass:[UIImageView class]]) {
                UIImageView *objImg = (UIImageView *)obj;
                objImg.image = [UIImage imageNamed:@"userSilhouetteDead.png"];
                break;
            }
        }
    }

    // style and unhie target prof pic; hidden by defailt.
    [[cell.targetProfilePic layer] setCornerRadius:cell.targetProfilePic.frame.size.width/2];
    [[cell.targetProfilePic layer] setMasksToBounds:YES];
    [cell.targetProfilePic setHidden:NO];
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110.0;
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
