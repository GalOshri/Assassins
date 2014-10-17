//
//  GameTableViewController.m
//  Assassins
//
//  Created by Paul Stavropoulos on 8/4/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "GameTableViewController.h"
#import "AssassinsService.h"
#import "Contract.h"
#import "AssassinationEventCell.h"
#import "ParticipantsTableViewController.h"
#import "CompletedContractViewController.h"
#import "Game.h"


@interface GameTableViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *gameImage;
@property (strong, nonatomic) IBOutlet UILabel *gameNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *currentTargetUsername;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *currentTargetProfilePicture;
@property (weak, nonatomic) IBOutlet UILabel *currentTargetLabel;

@property (weak, nonatomic) IBOutlet UIView *statusBarView;

@property (strong, nonatomic) Contract *currentContract;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (strong, nonatomic) NSMutableArray *completedContracts;
@property (strong, nonatomic) NSMutableArray *pendingContracts;
@property BOOL is2SectionsOrNah;
@property BOOL isCompletedOrNah;

@end

@implementation GameTableViewController

- (IBAction)unwindToGameView:(UIStoryboardSegue *)segue {
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SegueToParticipants"]) {
        if ([segue.destinationViewController isKindOfClass:[ParticipantsTableViewController class]])
        {
            ParticipantsTableViewController *ptvc = (ParticipantsTableViewController *)segue.destinationViewController;
            ptvc.game = self.game;
        }
    }
    
    if ([segue.identifier isEqualToString:@"CompletedImageViewSegue"]) {
        if ([segue.destinationViewController isKindOfClass:[CompletedContractViewController class]])
        {
            CompletedContractViewController *ccvc = (CompletedContractViewController *)segue.destinationViewController;
            AssassinationEventCell *cell = (AssassinationEventCell *)sender;
            ccvc.contract = cell.contract;
            ccvc.game = self.game;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.headerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"scopeBckgnd.png"]]];
    self.gameNameLabel.text = self.game.name;

    [[self.currentTargetProfilePicture layer] setCornerRadius: self.currentTargetProfilePicture.frame.size.width/2];
    [[self.currentTargetProfilePicture layer] setMasksToBounds:YES];

    //  table work
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
    
    [self.activityIndicatorView startAnimating];
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
    
        // call to AssassinsService to fill current contract
        self.currentContract = [AssassinsService getContractForGame:self.game.gameId];
        
        // call AssassinsService to fill lists with events
        self.completedContracts = [AssassinsService getCompletedContractsForGame:self.game.gameId];
        self.pendingContracts = [AssassinsService getPendingContractsForGame:self.game.gameId];
    
        dispatch_async( dispatch_get_main_queue(), ^{
            // Add code here to update the UI/send notifications based on the
            // results of the background processing

        
            if (!self.game.isComplete)
            {
                if (self.currentContract)
                {
                    self.currentTargetUsername.text = self.currentContract.targetName;
                    self.currentTargetProfilePicture.profileID = self.currentContract.targetFbId;
                    self.currentTargetProfilePicture.pictureCropping = FBProfilePictureCroppingSquare;
                    self.currentTargetLabel.text = @"your current target:";
                }
                else
                {
                    self.currentTargetLabel.text = @"you were eliminated";
                    [self.currentTargetProfilePicture setHidden:YES];
                    self.currentTargetUsername.text = @"game is not over";
                    
                }
            }
            else
            {
                self.currentTargetLabel.text = @"Game won by:";
                self.currentTargetUsername.text = self.game.winnerName;
                self.currentTargetProfilePicture.profileID = self.game.winnerFbId;
                self.currentTargetProfilePicture.pictureCropping = FBProfilePictureCroppingSquare;
                [[self.currentTargetProfilePicture layer] setCornerRadius:5];
                [[self.currentTargetProfilePicture layer] setMasksToBounds:YES];
            }
            
            // reload data stop spinner
            [self.tableView reloadData];
            [self.activityIndicatorView stopAnimating];
            [self.activityIndicatorView setHidden:YES];    
        });
    });
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.statusBarView.frame = CGRectMake(0, scrollView.contentOffset.y, self.statusBarView.frame.size.width, self.statusBarView.frame.size.height);
   // self.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.pendingContracts count] > 0 && [self.completedContracts count] > 0)
        return 2;
    else
        return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    
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
    
    return sectionName;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number;
    
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
    
    return number;
}

- (AssassinationEventCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AssassinationEventCell *cell = (AssassinationEventCell *) [tableView dequeueReusableCellWithIdentifier:@"ContractCell" forIndexPath:indexPath];
    
    // set contract based on section
    Contract *currentContract;
    
    if (self.is2SectionsOrNah)
    {
        if(indexPath.section == 0)
        {
            currentContract = [self.pendingContracts objectAtIndex:indexPath.row];
        }
        
        else
        {
            currentContract = [self.completedContracts objectAtIndex:indexPath.row];
        }
            
    }
    
    // only 1 section
    else
    {
        if (self.isCompletedOrNah)
        {
            currentContract = [self.completedContracts objectAtIndex:indexPath.row];
        }
        
        else
        {
            currentContract = [self.pendingContracts objectAtIndex:indexPath.row];
        }
    }
    
    // time altercation
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[NSDateFormatter dateFormatFromTemplate:@"hh:mm a MMM-dd" options:0 locale:[NSLocale currentLocale]]];
    NSString *theTime = [dateFormatter stringFromDate:currentContract.time];
    cell.timeLabel.text = theTime;
    
    cell.commentLabel.text = currentContract.comment;
    
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
    return cell;
}

@end
