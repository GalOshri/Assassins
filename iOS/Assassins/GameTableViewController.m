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
#import "Game.h"

@interface GameTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *numAssassinsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numActiveAssassinsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *gameImage;


@property (weak, nonatomic) IBOutlet UILabel *currentTargetUsername;
@property (weak, nonatomic) IBOutlet UIImageView *currentTargetImage;
@property (weak, nonatomic) IBOutlet UIView *statusBarView;


@property (strong, nonatomic) NSMutableArray *completedContracts;
@property (strong, nonatomic) Contract *currentContract;
@property (strong, nonatomic) Game *game;



@end

@implementation GameTableViewController

- (NSMutableArray *)completedContracts
{
    if (!_completedContracts)
    {
        _completedContracts = [[NSMutableArray alloc] init];
    }
    
    return _completedContracts;
}

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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.game = [AssassinsService getGameWithId:self.gameId];
    
    self.numAssassinsLabel.text = [NSString stringWithFormat:@"%@ assassins", self.game.numberOfAssassins];
    self.numActiveAssassinsLabel.text = [NSString stringWithFormat:@"%@ still in play", self.game.numberOfAssassinsAlive];
    
    // call to AssassinsService to fill current contract
    self.currentContract = [[Contract alloc] init];
    self.currentContract = [AssassinsService getContractForGame:self.gameId];
    
    [self.currentTargetImage setImage:[UIImage imageNamed:@"snipeCircle.png"]];
    self.currentTargetUsername.text = self.currentContract.targetName;
    
    // call AssassinsService to fill list with events
    self.completedContracts = [[NSMutableArray alloc] init];
    self.completedContracts = [AssassinsService getCompletedContractsForGame:self.gameId];

    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    // tweak aesthetics of image
    [cell.snipeImagePreview setImage:currentContract.image];
    [[cell.snipeImagePreview layer] setCornerRadius:5];
    [[cell.snipeImagePreview layer] setMasksToBounds:YES];

    return cell;
}



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
