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

@property (weak, nonatomic) IBOutlet UILabel *numAssassinsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numActiveAssassinsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *gameImage;
@property (strong, nonatomic) IBOutlet UILabel *gameNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *currentTargetUsername;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *currentTargetProfilePicture;
@property (weak, nonatomic) IBOutlet UILabel *currentTargetLabel;

@property (weak, nonatomic) IBOutlet UIView *statusBarView;

@property (strong, nonatomic) NSMutableArray *completedContracts;
@property (strong, nonatomic) Contract *currentContract;



@end

@implementation GameTableViewController

/* - (NSMutableArray *)completedContracts
{
    if (!_completedContracts)
    {
        _completedContracts = [[NSMutableArray alloc] init];
    }
    
    return _completedContracts;
} */

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
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.numAssassinsLabel.text = [NSString stringWithFormat:@"%@ assassins", self.game.numberOfAssassins];
    self.numActiveAssassinsLabel.text = [NSString stringWithFormat:@"%@ still in play", self.game.numberOfAssassinsAlive];
    self.gameNameLabel.text = self.game.name;
    
    // call to AssassinsService to fill current contract
    self.currentContract = [AssassinsService getContractForGame:self.game.gameId];
    
    if (!self.game.isComplete)
    {
        if (self.currentContract)
        {
            self.currentTargetUsername.text = self.currentContract.targetName;
            self.currentTargetProfilePicture.profileID = self.currentContract.targetFbId;
            self.currentTargetProfilePicture.pictureCropping = FBProfilePictureCroppingSquare;
            [[self.currentTargetProfilePicture layer] setCornerRadius:5];
            [[self.currentTargetProfilePicture layer] setMasksToBounds:YES];
        }
        else
        {
            self.currentTargetLabel.text = @"You were eliminated";
            [self.currentTargetProfilePicture setHidden:YES];
            self.currentTargetUsername.text = @"Game is not over";
            
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
    
    // call AssassinsService to fill list with events
    self.completedContracts = [AssassinsService getCompletedContractsForGame:self.game.gameId];
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
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.completedContracts count];
}


- (AssassinationEventCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AssassinationEventCell *cell = (AssassinationEventCell *) [tableView dequeueReusableCellWithIdentifier:@"ContractCell" forIndexPath:indexPath];
    
    // set contract
    Contract *currentContract = [self.completedContracts objectAtIndex:indexPath.row];
    
    // set items in cell
    cell.commentLabel.text = currentContract.comment;
    cell.headlineLabel.text = [NSString stringWithFormat:@"%@ has been removed", currentContract.targetName];
    
    // time altercation
    NSArray *timeArray = [[NSString stringWithFormat:@"%@", currentContract.time] componentsSeparatedByString:@"+"];
    NSString *time = [timeArray objectAtIndex:0];
    cell.timeLabel.text = [NSString stringWithFormat:@"%@",time];
    
    // tweak aesthetics of images
    [cell.snipeImagePreview setImage:currentContract.image];
    [[cell.snipeImagePreview layer] setCornerRadius:5];
    [[cell.snipeImagePreview layer] setMasksToBounds:YES];
    
    cell.profilePicture.profileID = currentContract.assassinFbId;
    cell.profilePicture.pictureCropping = FBProfilePictureCroppingSquare;
    [[cell.profilePicture layer] setCornerRadius:5];
    [[cell.profilePicture layer] setMasksToBounds:YES];
    
    cell.contract = currentContract;

    return cell;
}

@end
