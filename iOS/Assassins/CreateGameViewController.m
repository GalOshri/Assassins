//
//  CreateGameViewController.m
//  Assassins
//
//  Created by Paul Stavropoulos on 8/21/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "CreateGameViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "fbFriend.h"
#import "FriendTableViewCell.h"
#import "AssassinsService.h"
#import "Game.h"
#import "GameTableViewController.h"

@interface CreateGameViewController ()

@property (weak, nonatomic) IBOutlet UITextField *gameNameField;
@property (weak, nonatomic) IBOutlet UISearchBar *friendSearchBar;

@property (strong, nonatomic) NSMutableArray *friendList;
@property (strong, nonatomic) NSMutableArray *selectedFriends;


@end


@implementation CreateGameViewController
{
    // search results array for search term
    NSArray *searchResults;
}

@synthesize friendTableView;


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     if ([segue.identifier isEqualToString:@"SegueFromGameCreationToGameView"])
     {
         if ([segue.destinationViewController isKindOfClass:[GameTableViewController class]])
         {
             GameTableViewController *gtvc = (GameTableViewController *)segue.destinationViewController;
             Game *game = (Game *)sender;
             gtvc.game = game;
         }
     }
     
 }
 

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Do any additional setup after loading the view.
    
    self.friendList = [[NSMutableArray alloc] init];
    self.selectedFriends = [[NSMutableArray alloc] init];
    
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id data, NSError *error)
    {
        if (!error)
        {
            NSLog(@"friends: %@", data);
            
            // TODO: add facebook friends into array self.friendList
            self.friendList = (NSMutableArray *)[data data];
        }
        
        else
            NSLog(@"ERROR!");
    }];
}


- (IBAction)createGame:(id)sender
{
    // Assuming game name is filled and selectedFriends is populated.
    // TODO: NEED A USER ID.
    
    NSArray *userIdArray = @[@"GUFHki0asM", @"wahMYDPk15"];
    
    Game *newGame = [AssassinsService createGame:self.gameNameField.text withUserIds:userIdArray];
    
    [self performSegueWithIdentifier:@"SegueFromGameCreationToGameView" sender:newGame];
    
}



#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.friendList count];
}

- (FriendTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendTableViewCell *cell = (FriendTableViewCell *) [self.friendTableView dequeueReusableCellWithIdentifier:@"friendCell"];
    fbFriend *fbFriend = [self.friendList objectAtIndex:indexPath.row];
    
    cell.fbFriend = fbFriend;
    cell.nameLabel.text = fbFriend.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // place checkmark on FriendTableViewCell
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    // if selected friend, add friend to selectedFriend array
    fbFriend *selectedFbFriend = [self.friendList objectAtIndex:indexPath.row];
    [self.selectedFriends addObject:selectedFbFriend];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //remove checkmark from FriendTableViewCell
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    // if deslected, remove friend from selectedFriend array
    fbFriend *selectedFbFriend = [self.friendList objectAtIndex:indexPath.row];
    [self.selectedFriends removeObject:selectedFbFriend];

}

@end
