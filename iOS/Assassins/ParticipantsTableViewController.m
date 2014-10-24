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
@property (weak, nonatomic) IBOutlet UILabel *numAssassinsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numActiveAssassinsLabel;
@property (weak, nonatomic) IBOutlet UIView *statusBarView;
@property (strong, nonatomic) NSArray *assassins;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@property (weak, nonatomic) IBOutlet UIView *headerView;

@end

@implementation ParticipantsTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.gameNameLabel.text = [NSString stringWithString:self.game.name];
    self.numAssassinsLabel.text = [NSString stringWithFormat:@"%@ assassins", self.game.numberOfAssassins];
    
    // remove table separators when not needed
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    
    [self.activityIndicatorView startAnimating];
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Add code here to do background processing
        self.assassins = [AssassinsService getAssassinListFromGame:self.game];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            // Add code here to update the UI/send notifications based on the
            // results of the background processing
            
            if (!self.game.isComplete)
            {
                for (Assassin *assassin in self.assassins)
                {
                    if(!assassin.isAlive)
                        self.game.numberOfAssassinsAlive = [NSNumber numberWithInt:([self.game.numberOfAssassinsAlive intValue] - 1)];
                }
                self.numActiveAssassinsLabel.text = [NSString stringWithFormat:@"%@ still in play", self.game.numberOfAssassinsAlive];
            }
            else
                self.numActiveAssassinsLabel.text = @"game over";
            
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
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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

@end
