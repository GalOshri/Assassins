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
#import "GameEventTableViewCell.h"
#import "ParticipantsTableViewController.h"

@interface GameTableViewController ()

@property (weak, nonatomic) IBOutlet UIButton *participantsButton;
@property (weak, nonatomic) IBOutlet UILabel *totalAssassins;
@property (weak, nonatomic) IBOutlet UILabel *activeAssassins;
@property (weak, nonatomic) IBOutlet UIImageView *gameImage;

@property (strong, nonatomic) NSMutableArray *completedContracts;
@property (strong, nonatomic) NSString *gameId;


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

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {

    }
    
    return self;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gameParticipants"]) {
        if ([segue.destinationViewController isKindOfClass:[ParticipantsTableViewController class]])
        {
            ParticipantsTableViewController *ptvc = (ParticipantsTableViewController *)segue.destinationViewController;
            ptvc.gameId = self.gameId;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // HARDCODED GAME ID
    // TODO: Create a separate method in AssassinsService to grab correct information
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    self.gameId = [userData objectForKey:@"gameId"];
    
    // call AssassinsService to fill list with events
    self.completedContracts = [[NSMutableArray alloc] init];
    [AssassinsService populateCompletedContracts:self.completedContracts withGameId:[NSString stringWithFormat:@"%@", self.gameId] withTable:self.tableView];

    


    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GameEventTableViewCell *cell = (GameEventTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"ContractCell" forIndexPath:indexPath];
    
    // set contract
    Contract *currentContract = [self.completedContracts objectAtIndex:indexPath.row];
    
    // set items in cell
    // cell.userImage;
    cell.commentLabel.text = currentContract.comment;
    cell.headlineLabel.text = [NSString stringWithFormat:@"%@ has been removed", currentContract.targetName];
    cell.timeLabel.text = [NSString stringWithFormat:@"%@",currentContract.time];
    [cell.imageView setImage:currentContract.image];

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
