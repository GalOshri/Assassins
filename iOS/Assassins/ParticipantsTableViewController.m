//
//  ParticipantsTableViewController.m
//  Assassins
//
//  Created by Paul Stavropoulos on 8/6/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "ParticipantsTableViewController.h"
#import "ParticipantTableViewCell.h"
#import "AssassinsService.h"
#import "Assassin.h"

@interface ParticipantsTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *gameNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *gameImage;
@property (weak, nonatomic) IBOutlet UILabel *numAssassinsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numActiveAssassinsLabel;
@property (strong, nonatomic) NSMutableArray *assassins;

@end

@implementation ParticipantsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.gameNameLabel.text = [NSString stringWithString:self.game.name];
    self.numAssassinsLabel.text = [NSString stringWithFormat:@"%@ assassins", self.game.numberOfAssassins];
    self.numActiveAssassinsLabel.text = [NSString stringWithFormat:@"%@ still in play", self.game.numberOfAssassinsAlive];
    
    // populate assasssins array
    self.assassins = [[NSMutableArray alloc] init];
    [AssassinsService populateAssassinList:self.assassins withGameId:self.game.gameId];
    
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
    // Return the number of rows in the section.
    return [self.assassins count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ParticipantTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"assassinCell" forIndexPath:indexPath];
    Assassin *currentAssassin = [self.assassins objectAtIndex: [indexPath row]];
    
    // FIRE ZEH MISSILES!
    // I mean, assign cell items
    cell.username.text = currentAssassin.username;
    [cell.userImage setImage: currentAssassin.assassinImage];
    
    if (currentAssassin.isAlive)
        cell.isAliveLabel.text = @"Alive";
    else {
        cell.isAliveLabel.text =@"Neutralized";
        [cell.username setAlpha:0.5];
        [cell.userImage setAlpha:0.5];
        [cell.isAliveLabel setAlpha:0.5];
    }
    
    
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
