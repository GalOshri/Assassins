//
//  CreateGameViewController.m
//  Assassins
//
//  Created by Paul Stavropoulos on 8/21/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "CreateGameViewController.h"
#import "AssassinsService.h"

@interface CreateGameViewController ()

@property (weak, nonatomic) IBOutlet UITextField *gameNameField;
@property (weak, nonatomic) IBOutlet UITextView *selectedPlayersTextView;

@property (strong, nonatomic) NSMutableArray *friendList;
@property (strong, nonatomic) NSMutableArray *selectedFriends;
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITextView *safeZones;

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
    if ([segue.identifier isEqualToString:@"UnwindOnCreate"])
    {
        Game *game = (Game *)sender;
        self.createdGame = game;
    }
 
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Do any additional setup after loading the view.
    
    [self.headerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"mysteryManBckgnd"]]];
    
    self.friendList = [[NSMutableArray alloc] init];
    self.selectedFriends = [[NSMutableArray alloc] init];
    
    [self.safeZones.layer setBorderWidth:0.5];
    [self.safeZones.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.safeZones.layer setCornerRadius:15];
    self.safeZones.delegate = self;
    // self.isEditing = NO; TODO if want to dismiss on tap view
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
    
    UINavigationController *nc = [[UINavigationController alloc]initWithRootViewController:self.friendPickerController];
    //[nc setNavigationBarHidden:YES];
    [self presentViewController:nc animated:YES completion:nil];
    //[nc pushViewController:self.friendPickerController animated:YES];

}

- (IBAction)createGame:(id)sender
{
    // create array of facebook ID
    NSMutableArray *newGameParticipants = [[NSMutableArray alloc] init];

    [newGameParticipants addObject:[[PFUser currentUser] objectForKey:@"facebookId"]];
    
    for(int i=0; i< [self.friendPickerController.selection count]; i++)
        [newGameParticipants addObject:[self.friendPickerController.selection[i] objectForKey:@"id"]];
    
    if([self.safeZones.text isEqualToString:@"List Safe Zones separated by commas"])
        self.safeZones.text = @"";
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        Game *newGame = [AssassinsService createGame:self.gameNameField.text withSafeZones:self.safeZones.text withUserIds:newGameParticipants];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"UnwindOnCreate" sender:newGame];
        });
    });
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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

- (IBAction)textFieldFinish:(id)sender {
    [sender resignFirstResponder];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    // get rid of text
    if ([self.safeZones.text isEqualToString:@"List Safe Zones separated by commas"])
        self.safeZones.text = @"";
    
    self.safeZones.backgroundColor = [[UIColor alloc] initWithWhite:0.0 alpha:0.5];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        
        self.safeZones.backgroundColor = [UIColor clearColor];
        
        if ([self.safeZones.text isEqualToString:@""])
            self.safeZones.text = @"List Safe Zones separated by commas";
        
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}

@end
