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
@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePicture;
@property (strong, nonatomic) IBOutlet UIView *backgroundHeaderView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lifetimeSnipesLabel;
@property (weak, nonatomic) IBOutlet UILabel *lifetimeGamesLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;

@property (strong, nonatomic) NSMutableArray *games;
@property (strong, nonatomic) NSMutableArray *pastGames;
@property (strong, nonatomic) NSMutableDictionary *cellContracts;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

// @property (strong, nonatomic) NSCache *cellCache;
// @property (weak, nonatomic) IBOutlet UIButton *pendingContractsButton;

@end

@implementation UserTableViewController

- (IBAction)unwindToUserPage:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass:[CreateGameViewController class]])
    {
        CreateGameViewController *cgvc = (CreateGameViewController *)segue.sourceViewController;
        
        if (cgvc.createdGame)
        {
            self.goToGame = cgvc.createdGame;
            [self.games addObject:self.goToGame];
        }
    }
 
    
    // unhide navigationbar
    [super viewWillAppear:YES];
    [[self navigationController] setNavigationBarHidden:NO];
    self.navigationItem.title = [PFUser currentUser].username;
    
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SegueToGameView"])
    {
        self.navigationItem.title = @"";
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
    
    // background color/imgs
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.backgroundHeaderView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"spyBckgnd.png"]]];
    
    // set items from pfuser currentuser
    PFUser *currentUser = [PFUser currentUser];
    self.lifetimeSnipesLabel.text = [NSString stringWithFormat:@"%d total assassinations", [currentUser[@"lifetimeSnipes"] intValue]];
    self.lifetimeGamesLabel.text = [NSString stringWithFormat:@"%d completed games",[currentUser[@"lifetimeGames"] intValue]];
    
    //  table work
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // set picture right he-ah
    self.profilePicture.profileID = [NSString stringWithString:currentUser[@"facebookId"]];
    self.profilePicture.pictureCropping = FBProfilePictureCroppingSquare;
    [[self.profilePicture layer] setCornerRadius:self.profilePicture.frame.size.width/2];
    [[self.profilePicture layer] setMasksToBounds:YES];
    
    // initiate self.cellContracts, pastGames, and cellCach
    self.cellContracts = [[NSMutableDictionary alloc] init];
    self.pastGames = [[NSMutableArray alloc] init];
    
    // update tables
    [self updateTables];
    
    // set up table refreshing
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(updateTables) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    // unhide navigationbar
    [super viewWillAppear:YES];
    [[self navigationController] setNavigationBarHidden:NO];
    self.navigationItem.title = [PFUser currentUser].username;
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
}

- (IBAction)segmentControlChanged:(id)sender {
    switch (self.segmentControl.selectedSegmentIndex)
    {
        // current games
        case 0:
            // merely reload data
            [self.tableView reloadData];
            break;
            
        // past games
        case 1:
            [self.activityIndicatorView setHidden:NO];
            [self.activityIndicatorView startAnimating];
            
          
                // reload data stop spinner
                [self.tableView reloadData];
                [self.activityIndicatorView stopAnimating];
                [self.activityIndicatorView setHidden:YES];
            
            [self.activityIndicatorView stopAnimating];
            
            break;
            
        default:
            break;
    }
}

- (void) updateTables
{
    NSMutableArray *gameIdsForCurrentGames = [[NSMutableArray alloc] init];
    
    // get objects for current games
    [self.activityIndicatorView startAnimating];
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        self.games = [[AssassinsService getGameList:YES] mutableCopy];
        
        for(Game *currentGame in self.games)
        {
            [gameIdsForCurrentGames addObject: currentGame.gameId];
        }
        
        self.cellContracts = [AssassinsService getContractsForGames:gameIdsForCurrentGames];
        
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
            
            // reload data stop spinner
            [self.tableView reloadData];
            // [self.activityIndicatorView stopAnimating];
            [self.activityIndicatorView setHidden:YES];
        });
    });
    
    
    // get objects for past games
    [self.activityIndicatorView startAnimating];
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        self.pastGames = [[AssassinsService getGameList:NO] mutableCopy];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            // Add code here to update the UI/send notifications based on the
            // results of the background processing
            
            // reload data stop spinner
            [self.tableView reloadData];
            [self.activityIndicatorView stopAnimating];
            [self.activityIndicatorView setHidden:YES];
        });
    });
    
    [self.refreshControl endRefreshing];
    [self.view layoutIfNeeded];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.segmentControl.selectedSegmentIndex == 0)
        return [self.games count];
    else
        return [self.pastGames count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    GameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userGames" forIndexPath:indexPath];
    cell.targetProfilePic.profileID = nil;
    //[cell.targetProfilePic setHidden:YES];
    
    if (self.segmentControl.selectedSegmentIndex == 0)
    {
        cell.game = [self.games objectAtIndex:indexPath.row];
        cell.gameNameLabel.text = cell.game.name;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        // grab current contract to fill in data
        cell.currentContract = [self.cellContracts objectForKey:cell.game.gameId];

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
            
            cell.targetProfilePic.profileID = cell.currentContract.targetFbId;
            cell.targetProfilePic.pictureCropping = FBProfilePictureCroppingSquare;
            
            // see if picture is in Cache
            //NSString *photoId = [NSString stringWithFormat:@"%@", cell.currentContract.targetFbId];
           // NSData *fbProfilePic = [self.cellCache objectForKey:photoId];

            /*if (currentGame.currentTargetPic != nil)
            {
                for (NSObject *obj in [cell.targetProfilePic subviews]) {
                    if ([obj isMemberOfClass:[UIImageView class]]) {
                        UIImageView *objImg = (UIImageView *)obj;
                        objImg.image = [ UIImage imageWithData:cell.game.currentTargetPic];
                        break;
                    }
                }
            }
            
                // Attempt at storing as cache...FAILED
                 for (NSObject *obj in [cell.targetProfilePic subviews]) {
                    if ([obj isMemberOfClass:[UIImageView class]]) {
                        UIImageView *objImg = (UIImageView *)obj;
                        
                         NSData *imgData = UIImagePNGRepresentation(objImg.image);
                        // [self.cellCache setObject:imgData forKey:[NSString stringWithFormat:@"%@", cell.currentContract.targetFbId]];
                        currentGame.currentTargetPic = imgData;
                        
                        break;
                    }
                }
                */
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
    }
    
    // we are looking at past games (and thus completed games)
    else
    {
        cell.game = [self.pastGames objectAtIndex:indexPath.row];
        cell.gameNameLabel.text = cell.game.name;
        
        // Configure the cell...
        if (cell.game.isComplete)
        {
            NSArray *nameArray = [cell.game.winnerName componentsSeparatedByString:@" "];
            NSString *firstName = nameArray[0];
            
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.detailLabel.text = [NSString stringWithFormat:@"Won by %@", firstName];
            
            cell.targetProfilePic.profileID = cell.game.winnerFbId;
            cell.targetProfilePic.pictureCropping = FBProfilePictureCroppingSquare;
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

-(IBAction)showActionSheet:(id)sender {
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Feedback", @"Terms of service", @"Privacy policy", nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
        {
            NSString *urlString = @"mailto:kefiapp@gmail.com?subject=Feedback%20On%20Assassins";
            NSURL *url = [NSURL URLWithString:urlString];
            [[UIApplication sharedApplication] openURL:url];
            break;
        }
        case 1:
            [self performSegueWithIdentifier:@"SegueToTermsOfService" sender:self];
            break;
        case 2:
            [self performSegueWithIdentifier:@"SegueToPrivacyPolicy" sender:self];
            break;
        case 3:
            NSLog(@"Cancel");
        default:
            break;
            // terms of service, feedback, privacy policy,
    }
    
}

@end
