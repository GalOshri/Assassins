//
//  GameTableViewController.m
//  Assassins
//
//  Created by Paul Stavropoulos on 8/4/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "Contract.h"
#import "Game.h"
#import "Assassin.h"

#import "CompletedContractViewController.h"
#import "VerifySnipeViewController.h"
#import "GameTableViewController.h"
#import "AssassinsService.h"

#import "ParticipantTableViewCell.h"
#import "SafeZoneTableViewCell.h"
#import "AssassinationEventCell.h"

@interface GameTableViewController ()

// @property (weak, nonatomic) IBOutlet UIImageView *gameImage;
@property (strong, nonatomic) IBOutlet UILabel *gameNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *currentTargetUsername;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *currentTargetProfilePicture;
@property (weak, nonatomic) IBOutlet UIView *statusBarView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *statusBarUsernameLabel;
@property (weak, nonatomic) IBOutlet UIButton *statusBarBackArrow;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UILabel *numAssassinsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numActiveAssassinsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;

// @property (weak, nonatomic) IBOutlet UILabel *currentTargetLabel;

@property (strong, nonatomic) NSMutableArray *completedContracts;
@property (strong, nonatomic) NSMutableArray *pendingContracts;
@property (strong, nonatomic) NSArray *assassins;
@property BOOL is2SectionsOrNah;
@property BOOL isCompletedOrNah;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@end

@implementation GameTableViewController

- (IBAction)unwindToGameView:(UIStoryboardSegue *)segue {
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"CompletedImageViewSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[CompletedContractViewController class]])
        {
            CompletedContractViewController *ccvc = (CompletedContractViewController *)segue.destinationViewController;
            AssassinationEventCell *cell = (AssassinationEventCell *)sender;
            ccvc.contract = cell.contract;
            ccvc.game = self.game;
        }
    }
    
    if ([segue.identifier isEqualToString:@"SegueToSnipeVerify"]) {
        if ([segue.destinationViewController isKindOfClass:[VerifySnipeViewController class]])
        {
            VerifySnipeViewController *vsvc = (VerifySnipeViewController *)segue.destinationViewController;
            AssassinationEventCell *cell = (AssassinationEventCell *)sender;
            vsvc.contract = cell.contract;

        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.statusBarView setAlpha:0.0];
    self.statusBarUsernameLabel.text = self.game.name;
    [self.headerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"scopeBckgnd.png"]]];
    self.gameNameLabel.text = self.game.name;

    [[self.currentTargetProfilePicture layer] setCornerRadius: self.currentTargetProfilePicture.frame.size.width/2];
    [[self.currentTargetProfilePicture layer] setMasksToBounds:YES];

    //  table work
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self updateGameItems];
    
    // set up table refreshing
    UITableViewController *tableViewController = [[UITableViewController alloc] init];
    tableViewController.tableView = self.tableView;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(updateGameItems) forControlEvents:UIControlEventValueChanged];
    tableViewController.refreshControl = self.refreshControl;
}

 - (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    // make status bar change color and add name
    if (scrollView.contentOffset.y <= 40.0)
        [self.statusBarView setAlpha:0.0];
    
    else if (scrollView.contentOffset.y >= 40.0 && scrollView.contentOffset.y <= 65)
    {
        [self.statusBarView setAlpha: 0.0 + (scrollView.contentOffset.y - 40) / 17];
        [self.statusBarUsernameLabel setHidden:YES];
        [self.statusBarBackArrow setHidden:YES];
    }
    
    else
    {
        [self.statusBarView setAlpha:1.0];
        [self.statusBarUsernameLabel setHidden:NO];
        [self.statusBarBackArrow setHidden:NO];
    }
}

- (IBAction)segmentChanged:(UISegmentedControl *)sender {
    switch (self.segmentControl.selectedSegmentIndex)
    {
        // events
        case 0:
            // data
            [self.tableView reloadData];
            break;
        
        // players
        case 1:
            // if players array empty, fill
            if ([self.assassins count] == 0)
            {
                // set activity indicator
                [self.activityIndicatorView setHidden:NO];
                [self.activityIndicatorView startAnimating];
                
                if (!self.game.isComplete)
                {
                    for (Assassin *assassin in self.assassins)
                    {
                        if(!assassin.isAlive)
                            self.game.numberOfAssassinsAlive = [NSNumber numberWithInt:([self.game.numberOfAssassinsAlive intValue] - 1)];
                    }

                }
                
                // reload data stop spinner
                [self.tableView reloadData];
                [self.activityIndicatorView stopAnimating];
                [self.activityIndicatorView setHidden:YES];
            }
            
            else
            {
                // reload data stop spinner
                [self.tableView reloadData];
                [self.activityIndicatorView stopAnimating];
                [self.activityIndicatorView setHidden:YES];
            }
            
            break;
            
        case 2:
            // set activity indicator
            [self.activityIndicatorView setHidden:NO];
            [self.activityIndicatorView startAnimating];
            [self.tableView reloadData];
            [self.activityIndicatorView setHidden:YES];
            
        default:
            break;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)updateGameItems
{
    [self.activityIndicatorView startAnimating];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        // call AssassinsService to fill lists with events
        self.completedContracts = [AssassinsService getCompletedContractsForGame:self.game.gameId];
        self.pendingContracts = [AssassinsService getPendingContractsForGame:self.game.gameId];
        self.assassins = [AssassinsService getAssassinListFromGame:self.game];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            // Add code here to update the UI/send notifications based on the
            // results of the background processing
            
            // number of assassins
            self.numAssassinsLabel.text = [NSString stringWithFormat:@"%@ assassins", self.game.numberOfAssassins];
            
            // set strings for current target and assassins alive, depending on state of game
            if (!self.game.isComplete)
            {
                if ([self.currentContract.state isEqualToString:@"Active"])
                {
                    NSArray *nameArray = [self.currentContract.targetName componentsSeparatedByString:@" "];
                    NSString *firstName = nameArray[0];
                    
                    self.currentTargetUsername.text = [NSString stringWithFormat:@"current target: %@", firstName];
                    
                    self.currentTargetProfilePicture.profileID = self.currentContract.targetFbId;
                    self.currentTargetProfilePicture.pictureCropping = FBProfilePictureCroppingSquare;
                    // self.currentTargetLabel.text = @"your current target:";
                }
                
                else if ([self.currentContract.state isEqualToString:@"Pending"])
                {
                    // self.currentTargetUsername.text = @"sit tight...";
                    self.currentTargetUsername.text = @"your status is pending";
                    
                    // put pending icon
                    for (NSObject *obj in [self.currentTargetProfilePicture subviews]) {
                        if ([obj isMemberOfClass:[UIImageView class]]) {
                            UIImageView *objImg = (UIImageView *)obj;
                            objImg.image = [UIImage imageNamed:@"userSilhouettePending.png"];
                            break;
                        }
                    }
                }
                
                else
                {
                    // self.currentTargetLabel.text = @"you were eliminated";
                    [self.currentTargetProfilePicture setHidden:YES];
                    self.currentTargetUsername.text = @"you were eliminated";
                    
                    // put dead icon
                    for (NSObject *obj in [self.currentTargetProfilePicture subviews]) {
                        if ([obj isMemberOfClass:[UIImageView class]]) {
                            UIImageView *objImg = (UIImageView *)obj;
                            objImg.image = [UIImage imageNamed:@"userSilhouetteDead.png"];
                            break;
                        }
                    }
                }
                
                // set strings for number alive and number of players
                for (Assassin *assassin in self.assassins)
                {
                    if(!assassin.isAlive)
                        self.game.numberOfAssassinsAlive = [NSNumber numberWithInt:([self.game.numberOfAssassins intValue] - 1)];
                }
                self.numActiveAssassinsLabel.text = [NSString stringWithFormat:@"%@ still in play", self.game.numberOfAssassinsAlive];
            }
            
            else
            {
                NSArray *nameArray = [self.game.winnerName componentsSeparatedByString:@" "];
                NSString *firstName = nameArray[0];
                
                // self.currentTargetLabel.text = @"Game won by:";
                self.numActiveAssassinsLabel.text = @"game over";
                self.currentTargetUsername.text = [NSString stringWithFormat:@"game won by %@", firstName];
                self.currentTargetProfilePicture.profileID = self.game.winnerFbId;
                self.currentTargetProfilePicture.pictureCropping = FBProfilePictureCroppingSquare;
            }
            
            // hidden by default; unhide
            [self.currentTargetProfilePicture setHidden:NO];
            
            // reload data stop spinner
            [self.tableView reloadData];
            [self.activityIndicatorView stopAnimating];
            [self.activityIndicatorView setHidden:YES];
        });
    });
    
    // update constraints and end refreshing
    [self.refreshControl endRefreshing];
    self.tableViewTopConstraint = 0;
    [self.view layoutIfNeeded];

}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.segmentControl.selectedSegmentIndex == 0)
    {
        if ([self.pendingContracts count] > 0 && [self.completedContracts count] > 0)
            return 2;
        else
            return 1;
    }
    
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    
    if (self.segmentControl.selectedSegmentIndex == 0)
    {
        if (tableView.numberOfSections == 2)
        {
            self.is2SectionsOrNah = YES;
            
            switch (section)
            {
                case 0:
                    sectionName = @"Pending Snipes";
                    break;
                case 1:
                    sectionName = @"Completed Snipes";
                    break;
                default:
                    sectionName = @"";
                    break;
            }
        }
        
        else
        {
            self.is2SectionsOrNah = NO;
            if([self.completedContracts count] > 0)
            {
                sectionName = @"Completed Snipes";
                self.isCompletedOrNah = YES;
            }
            else
            {
                sectionName= @"Pending Snipes";
                self.isCompletedOrNah = NO;
            }
        }
    }
    
    return sectionName;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number;
    
    if (self.segmentControl.selectedSegmentIndex == 0)
    {
        if (self.is2SectionsOrNah)
        {
            switch (section)
            {
                case 0:
                    number = [self.pendingContracts count];
                    break;
                case 1:
                    number = [self.completedContracts count];
                    break;
                default:
                    number = 0;
                    break;
            }
        }
        
        else // 1 section
        {
            if(self.isCompletedOrNah)
                    number = [self.completedContracts count];
                else
                    number = [self.pendingContracts count];
        }
    }
    
    else if (self.segmentControl.selectedSegmentIndex == 1)
        number = [self.assassins count];
    
    else
        number = 1;
    
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // set contract based on section
    if (self.segmentControl.selectedSegmentIndex == 0)
    {
        Contract *currentContract;
        AssassinationEventCell *cell;
        
        if (self.is2SectionsOrNah)
        {
            if(indexPath.section == 0)
            {
                currentContract = [self.pendingContracts objectAtIndex:indexPath.row];
                cell = (AssassinationEventCell *) [tableView dequeueReusableCellWithIdentifier:@"PendingCell" forIndexPath:indexPath];
            }
            
            else
            {
                currentContract = [self.completedContracts objectAtIndex:indexPath.row];
                cell = (AssassinationEventCell *) [tableView dequeueReusableCellWithIdentifier:@"ContractCell" forIndexPath:indexPath];
            }
            
        }
        
        // only 1 section
        else
        {
            if (self.isCompletedOrNah)
            {
                currentContract = [self.completedContracts objectAtIndex:indexPath.row];
                cell = (AssassinationEventCell *) [tableView dequeueReusableCellWithIdentifier:@"ContractCell" forIndexPath:indexPath];
            }
            
            else
            {
                currentContract = [self.pendingContracts objectAtIndex:indexPath.row];
                cell = (AssassinationEventCell *) [tableView dequeueReusableCellWithIdentifier:@"PendingCell" forIndexPath:indexPath];
            }
        }
        
        // set profileID to nil so that we don't display FB image from previous cell
        cell.profilePicture.profileID = nil;
        
        // time altercation
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"hh:mm a MMM-dd" options:0 locale:[NSLocale currentLocale]]];
        NSString *theTime = [dateFormatter stringFromDate:currentContract.time];
        cell.timeLabel.text = theTime;
        
        // tweak aesthetics of images
        [cell.snipeImagePreview setImage:currentContract.image];
        [[cell.snipeImagePreview layer] setCornerRadius:5];
        [[cell.snipeImagePreview layer] setMasksToBounds:YES];
        
        cell.profilePicture.profileID = currentContract.targetFbId;
        cell.profilePicture.pictureCropping = FBProfilePictureCroppingSquare;
        [[cell.profilePicture layer] setCornerRadius:cell.profilePicture.frame.size.width/2];
        [[cell.profilePicture layer] setMasksToBounds:YES];
        
        cell.contract = currentContract;
        
        // tweak UI if pending:
        if ([currentContract.state isEqualToString:@"Pending"])
            cell.headlineLabel.text = [NSString stringWithFormat:@"Pending Snipe of %@!", currentContract.targetName];
        
        else
        {
            // set items in cell
            cell.headlineLabel.text = [NSString stringWithFormat:@"%@ has been eliminated", currentContract.targetName];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        return cell;
    }
    
    else if (self.segmentControl.selectedSegmentIndex == 1)
    {
        ParticipantTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"assassinCell" forIndexPath:indexPath];
        Assassin *currentAssassin = [self.assassins objectAtIndex: [indexPath row]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // assign cell items
        cell.username.text = currentAssassin.username;
        cell.profilePicture.profileID = currentAssassin.fbId;
        cell.profilePicture.pictureCropping = FBProfilePictureCroppingSquare;
        [[cell.profilePicture layer] setCornerRadius:cell.profilePicture.frame.size.width / 2];
        [[cell.profilePicture layer] setMasksToBounds:YES];
        
        if (currentAssassin.isAlive)
        {
            if (self.game.isComplete)
                cell.isAliveLabel.text = @"Winner";
            else
                cell.isAliveLabel.text = @"Alive";
        }
        else {
            if (currentAssassin.isPending) {
                cell.isAliveLabel.text = @"Pending";
            }
            
            else
            {
                cell.isAliveLabel.text = @"Neutralized";
                
                [cell.username setAlpha:0.5];
                [cell.profilePicture setAlpha:0.5];
                [cell.isAliveLabel setAlpha:0.5];
            }
        }
        
        return cell;
    }
    
    else
    {
        SafeZoneTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SafeZoneCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // set game safe zones
        if (self.game.safeZones == nil || [self.game.safeZones isEqualToString:@""])
            cell.safeZoneTextView.text = @"none were set!";
        else
            cell.safeZoneTextView.text = self.game.safeZones;
        
        cell.safeZoneTextView.textColor = [UIColor blackColor];
        
        // change height of textview and headerview. Other objects are auto layouted
        [cell.safeZoneTextView sizeToFit];
        
        CGSize textFrameSize = [cell.safeZoneTextView.text sizeWithAttributes: @{NSFontAttributeName:[UIFont systemFontOfSize:15.0f]}];
        
        cell.safeZoneTextView.frame = CGRectMake(cell.safeZoneTextView.frame.origin.x, cell.safeZoneTextView.frame.origin.y, cell.frame.size.width, textFrameSize.height);
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // deselect the row
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
-(void) tableView:(UITableView *)tableView willDisplayCell:(AssassinationEventCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // set contract based on section
    Contract *currentContract;
    if (self.is2SectionsOrNah)
    {
        if(indexPath.section == 0)
            currentContract = [self.pendingContracts objectAtIndex:indexPath.row];
        
        else
            currentContract = [self.completedContracts objectAtIndex:indexPath.row];
    }
    
    [cell.snipeImagePreview setFrame:CGRectMake(cell.snipeImagePreview.frame.origin.x, cell.snipeImagePreview.frame.origin.y, currentContract.image.size.width/3.5f, currentContract.image.size.height/3.5f)];
    NSLog(@"width of image is %f", currentContract.image.size.width);
}
*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentControl.selectedSegmentIndex == 0) {
        return 264.0;
    }
    
    else if (self.segmentControl.selectedSegmentIndex == 1)
        return 83.0;
    
    else
        return 300;
}

@end
