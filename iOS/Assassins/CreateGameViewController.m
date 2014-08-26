//
//  CreateGameViewController.m
//  Assassins
//
//  Created by Paul Stavropoulos on 8/21/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "CreateGameViewController.h"
#import "fbFriend.h"
#import "FriendTableViewCell.h"
#import "AssassinsService.h"
#import "Game.h"
#import "GameTableViewController.h"

@interface CreateGameViewController ()

@property (weak, nonatomic) IBOutlet UITextField *gameNameField;
@property (weak, nonatomic) IBOutlet UITextView *selectedPlayersTextView;

@property (strong, nonatomic) NSMutableArray *friendList;
@property (strong, nonatomic) NSMutableArray *selectedFriends;
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;

@end


@implementation CreateGameViewController
{
    // search results array for search term
    NSArray *searchResults;
}


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

}

- (IBAction)selectPlayers:(id)sender
{
    // FBSample logic
    // if the session is open, then load the data for our view controller
    if (!FBSession.activeSession.isOpen)
    {
        // if the session is closed, then we open it here, and establish a handler for state changes
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"user_friends"] allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState state, NSError *error)
        {
            if (error)
            {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                  [alertView show];
            }
            else if (session.isOpen)
                [self selectPlayers:sender];
        }];
        
        return;
    }
    
    if (self.friendPickerController == nil)
    {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Pick Friends";
        self.friendPickerController.allowsMultipleSelection = YES;
        self.friendPickerController.sortOrdering = FBFriendSortByLastName;
        self.friendPickerController.delegate = self;
    }
    
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection];
    
    [self presentViewController:self.friendPickerController animated:YES completion:nil];

}

- (IBAction)createGame:(id)sender
{
    // TODO: go from facebookId to parse object ID
    NSArray *newGameParticipants = [[NSArray alloc] initWithArray:self.friendPickerController.selection];

    // NSArray *userIdArray = @[@"GUFHki0asM", @"wahMYDPk15"];
    
    Game *newGame = [AssassinsService createGame:self.gameNameField.text withUserIds:newGameParticipants];
    
    [self performSegueWithIdentifier:@"SegueFromGameCreationToGameView" sender:newGame];
    
}


# pragma mark - Friend picker work
- (void)facebookViewControllerDoneWasPressed:(id)sender {
    NSMutableString *text = [[NSMutableString alloc] init];
    [text appendString:@"Participants:\n\n"];
    
    // we pick up the users from the selection, and create a string that we use to update the text view
    for (id<FBGraphUser> user in self.friendPickerController.selection)
    {
        if (![text isEqualToString:@"Participants:\n\n"])
        {
            [text appendString:@", "];
        }
        [text appendString:user.name];
    }
    
    [self fillTextBoxAndDismiss:text.length > 0 ? text : @"No friends selected"];
}

- (void)facebookViewControllerCancelWasPressed:(id)sender
{
    [self fillTextBoxAndDismiss:@"No friends selected"];
}

- (void)fillTextBoxAndDismiss:(NSString *)text {
    self.selectedPlayersTextView.text = text;
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}


/*
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
*/
@end
