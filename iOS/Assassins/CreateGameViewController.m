//
//  CreateGameViewController.m
//  Assassins
//
//  Created by Paul Stavropoulos on 8/21/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "CreateGameViewController.h"
#import "AssassinsService.h"
#import "Game.h"

@interface CreateGameViewController ()

@property (weak, nonatomic) IBOutlet UITextField *gameNameField;
@property (weak, nonatomic) IBOutlet UITextView *selectedPlayersTextView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITextView *safeZones;
@property (weak, nonatomic) IBOutlet UIView *safeZonesView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *safeZoneViewBottomConstraint;

@property (strong, nonatomic) Game *game;
@property (strong, nonatomic) NSMutableArray *selectedFriends;
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property BOOL keyboardOrNah;


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
    if ([segue.identifier isEqualToString:@"unwindToUserPageSegue"] && self.game)
    {
        self.createdGame = self.game;
    }
 
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Do any additional setup after loading the view.
    
    [self.headerView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"mysteryManBckgnd.png"]]];
    [self.safeZonesView setBackgroundColor:[UIColor whiteColor]];
    
    self.selectedFriends = [[NSMutableArray alloc] init];
    
    [self.safeZones.layer setBorderWidth:0.5];
    [self.safeZones.layer setBorderColor:[UIColor grayColor].CGColor];
    [self.safeZones.layer setCornerRadius:15];
    self.safeZones.delegate = self;
    
    self.gameNameField.delegate = self;
    self.safeZones.delegate = self;
    
    // set responder for keyboard and bool for safe zones
    self.keyboardOrNah = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardFrameDidChange:)
                                                 name:UIKeyboardWillChangeFrameNotification object:nil];
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
    
    if ([self.selectedFriends count] <= 0)
    {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Choose friends";
        

        self.friendPickerController.allowsMultipleSelection = YES;
        self.friendPickerController.sortOrdering = FBFriendSortByLastName;
        self.friendPickerController.delegate = self;
    }
    
    // else, keep previous selection
    [self.friendPickerController setSelection: self.selectedFriends];
    [self.friendPickerController loadData];
    
    UINavigationController *nc = [[UINavigationController alloc]initWithRootViewController:self.friendPickerController];
    nc.navigationController.navigationBarHidden = YES;
    self.friendPickerController.title = @"";
    [self presentViewController:nc animated:YES completion:nil];
    //[nc pushViewController:self.friendPickerController animated:YES];
    
    //[self.friendPickerController presentModallyFromViewController:self animated:YES handler:nil];
}

- (IBAction)createGame:(id)sender
{

    if ([self.selectedFriends count] <= 0)
    {
        UIAlertView *incomplete = [[UIAlertView alloc] initWithTitle:@"choose friends to play with!" message:@"please select at least 1 friend to play an assassins game with" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [incomplete show];
        return;
    }

    else if ([self.gameNameField.text length] <=0)
    {
        UIAlertView *noGameName = [[UIAlertView alloc] initWithTitle:@"create a game title" message:@"come up with a name for your game!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [noGameName show];
        return;
    }
    
    else
    {
    
        // create array of facebook ID
        NSMutableArray *newGameParticipants = [[NSMutableArray alloc] init];

        [newGameParticipants addObject:[[PFUser currentUser] objectForKey:@"facebookId"]];
        
        for(int i=0; i< [self.selectedFriends count]; i++)
            [newGameParticipants addObject:[self.friendPickerController.selection[i] objectForKey:@"id"]];
        
        if([self.safeZones.text isEqualToString:@"List Safe Zones separated by commas"])
            self.safeZones.text = @"";
        
        dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            Game *newGame = [AssassinsService createGame:self.gameNameField.text withSafeZones:self.safeZones.text withUserIds:newGameParticipants];
            
            dispatch_async( dispatch_get_main_queue(), ^{
                self.game = newGame;
                [self performSegueWithIdentifier:@"unwindToUserPageSegue" sender:self];
            });
        });
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

# pragma mark - Friend picker work
- (void)facebookViewControllerDoneWasPressed:(id)sender {
    [self.selectedFriends removeAllObjects];
    NSMutableString *text = [[NSMutableString alloc] initWithString:@""];
    // we pick up the users from the selection, and create a string that we use to update the text view
    for (id<FBGraphUser> user in self.friendPickerController.selection)
    {
            if ([text isEqualToString:@""])
                text = [NSMutableString stringWithFormat:@"%@",user.name];
            else
            {
                [text appendString:@", "];
                [text appendString:user.name];
            }
            
            [self.selectedFriends addObject:user];
    }
    
    [self fillTextBoxAndDismiss:text];
}


- (void)facebookViewControllerCancelWasPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)fillTextBoxAndDismiss:(NSString *)text {
    if (![text isEqualToString:@""])
        self.selectedPlayersTextView.text = text;
    else
        self.selectedPlayersTextView.text = @"no friends selected";
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    //call selector to dismiss keyboard code if it is present
    UITapGestureRecognizer *tapRecognizerTextField = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchEventOnView:)];
    [tapRecognizerTextField setNumberOfTapsRequired:1];
    [tapRecognizerTextField setDelegate:self];
    [self.view addGestureRecognizer:tapRecognizerTextField];
}

- (IBAction)textFieldFinish:(id)sender {
    [sender resignFirstResponder];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.keyboardOrNah = YES;
    
    // get rid of text
    if ([self.safeZones.text isEqualToString:@"List Safe Zones separated by commas"])
    {    self.safeZones.text = @"";
        self.safeZones.textColor = [UIColor blackColor];
    }
    
    //call selector to dismiss keyboard code if it is present
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchEventOnView:)];
    [tapRecognizer setNumberOfTapsRequired:1];
    [tapRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapRecognizer];
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        
        if ([self.safeZones.text isEqualToString:@""] || [self.safeZones.text isEqualToString:@" "])
        {
            self.safeZones.text = @"List Safe Zones separated by commas";
            self.safeZones.textColor = [UIColor grayColor];
        }
        
        self.keyboardOrNah = NO;
        // Return FALSE so that the final '\n' character doesn't get added
        return FALSE;
    }
    // For any other character return TRUE so that the text gets added to the view
    return TRUE;
}

- (void)touchEventOnView: (id) sender
{
    //[self endEditing];
    // remove gesture
    UITapGestureRecognizer *gestureRecognizer = sender;
    [self.view removeGestureRecognizer:gestureRecognizer];

    [self.view endEditing:YES];
    
    if ([self.safeZones.text isEqualToString:@""] || [self.safeZones.text isEqualToString:@" "])
    {
        self.safeZones.text = @"List Safe Zones separated by commas";
        self.safeZones.textColor = [UIColor grayColor];
    }
    
    // reset logic
    self.keyboardOrNah = NO;
}

- (void)keyboardFrameDidChange:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    CGRect kKeyBoardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    
    if (self.keyboardOrNah && [self.safeZones isFirstResponder])
    {
        self.safeZoneViewBottomConstraint.constant = 18;
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    
    else if ([self.safeZones isFirstResponder])
    {
        self.safeZoneViewBottomConstraint.constant = kKeyBoardFrame.size.height;
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
    
    self.keyboardOrNah = !self.keyboardOrNah;
}

@end
