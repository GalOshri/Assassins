//
//  AssassinsService.m
//  Assassins
//
//  Created by Gal Oshri on 8/3/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//
#import "AssassinsService.h"
#import <Parse/Parse.h>
#import "Contract.h"
#import "Assassin.h"
#import "Game.h"

@implementation AssassinsService

+ (void)submitAssassination:(UIImage *)snipeImage withMode:(BOOL)isAttack withComment:(NSString *)comment withCommentLocation:(CGFloat)yCoord withContractId:(NSString *)contractId
{
    if (isAttack)
    {
        NSData *snipeImageData = UIImageJPEGRepresentation(snipeImage, 1);
        PFFile *imageFile = [PFFile fileWithName:[NSString stringWithFormat:@"SnipeImage.jpg"] data:snipeImageData];
        
        PFQuery *query = [PFQuery queryWithClassName:@"Contract"];
        
        // Retrieve the object by id
        [query getObjectInBackgroundWithId:contractId block:^(PFObject *contract, NSError *error) {
        
            // set image, status
            contract[@"image"] = imageFile;
            contract[@"state"] = @"Pending";
            
            // set comment fields
            if ([comment isEqualToString:@""]) {
                contract[@"commentLocation"] = [NSNumber numberWithFloat:-1.0];
                contract[@"comment"] = @"";
            }
            else {
                contract[@"commentLocation"] = [NSNumber numberWithFloat:yCoord];
                contract[@"comment"] = comment;
            }
            
            [contract save];
            
            // send push notifiaction to target
            //query to grab correct user
            PFUser *target = contract[@"target"];
            PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"user" equalTo:target];
            
            // Send push notification to query
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"You got sniped!", @"alert",
                                  contract.objectId, @"contractId",
                                  nil];
            
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:pushQuery];
            [push setData:data];
            [push sendPushInBackground];

        }];
    }
}


+ (NSMutableArray *)getCompletedContractsForGame:(NSString *)gameId
{
    
    NSMutableArray *contractArray = [[NSMutableArray alloc] init];
    
    // Get all completed contracts for this game
    PFQuery *queryContracts = [PFQuery queryWithClassName:@"Contract"];
    [queryContracts whereKey:@"game" equalTo:[PFObject objectWithoutDataWithClassName:@"Game" objectId:gameId]];
    [queryContracts whereKey:@"state" equalTo:@"Completed"];
    
    NSArray *contractObjects = [queryContracts findObjects];
    
    for (PFObject *contractObject in contractObjects)
    {
        Contract *contract = [self getContractFromContractObject:contractObject];
        
        [contractArray addObject:contract];
    }
    return contractArray;
}

// TODO: DON"T USE THIS WITHOUT FIXING THE GAMEID STUFF
/*+ (NSArray *)getCompletedContractsForGames:(NSArray *)gameIdArray
{
    
    NSMutableArray *contractArray = [[NSMutableArray alloc] init];
    
    // Get all completed contracts for this game
    PFQuery *queryContracts = [PFQuery queryWithClassName:@"Contract"];
    NSMutableArray *gameArray = [[NSMutableArray alloc] init];
   // [PFObject objectWithoutDataWithClassName:@"Game" objectId:@"1zEcyElZ80"]
    [queryContracts whereKey:@"game" containedIn:gameIdArray];
    [queryContracts whereKey:@"state" equalTo:@"Completed"];
    
    NSArray *contractObjects = [queryContracts findObjects];
    
    for (PFObject *contractObject in contractObjects)
    {
        Contract *contract = [[Contract alloc] init];
        
        contract.contractId = contractObject.objectId;
        contract.time = [NSDate date];
        //contract.image = [UIImage imageNamed:@"cameraIconSmaill.png"];
        
        PFFile *imageFile = contractObject[@"image"];
        
        NSData *imageData = [imageFile getData];
        contract.image = [UIImage imageWithData:imageData];
        
        PFUser *assassin = contractObject[@"assassin"];
        [assassin fetch];
        contract.assassinName = assassin.username;
        contract.assassinFbId = assassin[@"facebookId"];
        PFUser *target = contractObject[@"target"];
        [target fetch];
        contract.targetName = target.username;
        contract.targetFbId = target[@"facebookId"];
        contract.comment = contractObject[@"comment"];
        
        [contractArray addObject:contract];
    }
    return contractArray;
    
}
 */

/*
+ (void)populateAssassinList:(NSMutableArray *)assassinArray withGameId:(NSString *)gameId
{
    BOOL DEBUGAL = YES;
 
    [assassinArray removeAllObjects];
 
    if (DEBUGAL)
    {
        for (int i = 0; i < 4; i++)
        {
            Assassin *assassin = [[Assassin alloc] init];
            
            assassin.username = @"Galileo";
            assassin.userId = @"Galilei";
            assassin.isAlive = YES;
            assassin.numberOfSnipes = i;
            
            [assassinArray addObject:assassin];
        }
        //[tableview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        return;
    }
    
    // Get all contracts for this game
    PFQuery *queryContracts = [PFQuery queryWithClassName:@"Contracts"];
    [queryContracts whereKey:@"gameId" equalTo:gameId];
    
    //NSMutableArray *assassinUsers = [[NSMutableArray alloc] init];
    //NSMutableArray *deadAssassinUsers = [[NSMutableArray alloc] init];
    NSMutableSet *existingUserIds = [[NSMutableSet alloc] init];
    
    [queryContracts findObjectsInBackgroundWithBlock:^(NSArray *contracts, NSError *error)
     {
         if (!error)
         {
             // Compile a list of all users
             for (PFObject *contractObject in contracts)
             {
                 PFUser *assassinUser = contractObject[@"assassin"];
                 
                 if (![existingUserIds containsObject:assassinUser.objectId])
                 {
                     Assassin *assassin = [[Assassin alloc] init];
                     
                     assassin.username = assassinUser.username;
                     assassin.userId = assassinUser.objectId;
                     assassin.isAlive = YES;
                     assassin.numberOfSnipes = 4;
                     
                     [assassinArray addObject:assassin];
                     
                     [existingUserIds addObject:assassinUser.objectId];
                 }
             }
             
             for (PFObject *contractObject in contracts)
             {
                 if ([contractObject[@"state"] isEqualToString:@"Completed"])
                 {
                     PFUser *assassinUser = contractObject[@"target"];
                     for (Assassin *assassin in assassinArray)
                     {
                         
                         if ([assassin.userId isEqualToString:assassinUser.objectId])
                         {
                             assassin.isAlive = NO;
                         }
                     }
                 }
      f       }
         }
     }];
    
}
 */

+ (NSArray *)getAssassinListFromGame:(Game *)game
{
    NSMutableArray *assassinArray = [[NSMutableArray alloc] init];
    
    NSArray *userArray = game.assassins;
    NSArray *contractArray = game.contracts;
    
    [PFUser fetchAll:userArray];
    
    for (PFUser *user in userArray)
    {
        Assassin *assassin = [[Assassin alloc] init];
        
        assassin.username = user.username;
        assassin.userId = user.objectId;
        assassin.fbId = user[@"facebookId"];
        assassin.isAlive = YES;
        assassin.numberOfSnipes = 4;
        
        [assassinArray addObject:assassin];
    }
    
    [PFObject fetchAll:contractArray];
    for (PFObject *contract in contractArray)
    {
        if ([contract[@"state"] isEqualToString:@"Completed"])
        {
            for (Assassin *assassin in assassinArray)
            {
                PFUser *target = contract[@"target"];
                if ([assassin.userId isEqualToString:target.objectId])
                {
                    assassin.isAlive = NO;
                }
            }
        }
    }
    

    
    return assassinArray;
}


+ (Contract *)getContractForGame:(NSString *)gameId
{
    PFQuery *query = [PFQuery queryWithClassName:@"Contract"];
    [query whereKey:@"assassin" equalTo:[PFUser currentUser]];
    [query whereKey:@"state" containedIn:@[@"Active", @"Pending"]];
    [query whereKey:@"game" equalTo:[PFObject objectWithoutDataWithClassName:@"Game" objectId:gameId]];
    
    // Retrieve the object by id
    PFObject *contractObject = [query getFirstObject];
    
    if (contractObject)
    {
        Contract *contract = [self getContractFromContractObject:contractObject];
        return contract;
    }
    else
        return nil;
}


+ (NSArray *)getGameList
{
    NSMutableArray *gameList = [[NSMutableArray alloc] init];
    PFUser *currentUser = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Game"];
    
    [query whereKey:@"players" equalTo:currentUser];
    NSArray *gameObjects = [query findObjects];
    
    for (PFObject *gameObject in gameObjects)
    {
        Game *game = [self getGameFromGameObject:gameObject];
        
        [gameList addObject:game];
    }
    
    return gameList;
}

+ (Game *) getGameWithId:(NSString *)gameId
{
    PFQuery *query = [PFQuery queryWithClassName:@"Game"];
    PFObject *gameObject = [query getObjectWithId:gameId];
    
    Game *game = [self getGameFromGameObject:gameObject];
    
    return game;
}

+ (NSArray *)getPendingSnipes;
{
    NSMutableArray *pendingSnipes = [[NSMutableArray alloc] init];
    
    PFQuery *targetQuery = [PFQuery queryWithClassName:@"Contract"];
    [targetQuery whereKey:@"target" equalTo:[PFUser currentUser]];
    [targetQuery whereKey:@"state" equalTo:@"Pending"];
    
    PFQuery *assassinQuery = [PFQuery queryWithClassName:@"Contract"];
    [assassinQuery whereKey:@"assassin" equalTo:[PFUser currentUser]];
    [assassinQuery whereKey:@"state" equalTo:@"Pending"];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[targetQuery, assassinQuery]];
    PFUser *currentUser = [PFUser currentUser];
    
    NSArray *contractObjects = [query findObjects];
    
    for (PFObject *contractObject in contractObjects)
    {
        Contract *contract = [self getContractFromContractObject:contractObject];
        
        if ([contract.targetFbId isEqualToString:currentUser[@"facebookId"]])
            [pendingSnipes insertObject:contract atIndex:0];
        else
            [pendingSnipes addObject:contract];
    }
    return pendingSnipes;
}

+ (int)checkPendingSnipes
{
    if ([PFUser currentUser])
    {
        PFQuery *targetQuery = [PFQuery queryWithClassName:@"Contract"];
        [targetQuery whereKey:@"target" equalTo:[PFUser currentUser]];
        [targetQuery whereKey:@"state" equalTo:@"Pending"];
        
        int pendingCount = (int) [targetQuery countObjects];
        return pendingCount;
    }
    else
        return 0;
}

/*
+ (UIImage *)getUserProfilePic:(PFUser *)user
{
    if (user[@"facebookId"] == nil)
        return [[UIImage alloc] initWithContentsOfFile:@"snipeCircle.png"];
    
    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", user[@"facebookId"]]];
    
    
    // Asynchornous image loading
    NSURLSession *session = [NSURLSession sharedSession];
    //UIActivityIndicatorView *spotlightSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //spotlightSpinner.center = CGPointMake(frame.origin.x + (frame.size.width / 2.0), frame.origin.y + (frame.size.height / 2.0));
    //[self.spotlightView addSubview:spotlightSpinner];
    //[spotlightSpinner startAnimating];
    [[session dataTaskWithURL:[NSURL URLWithString: pictureURL]
            completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    UIImage *img = [[UIImage alloc] initWithData:data];
                    
                    return img;
                }];
            }] resume];
 
    
    UIImage *image = [UIImage imageWithData: [NSData dataWithContentsOfURL:pictureURL]];
    return image;

}
*/

+ (Game *) createGame:(NSString *)gameName withUserIds:(NSMutableArray *)userIdArray withCurrentUserId:(NSString *)currentUserId
{
    NSDictionary *createGameDict = [[NSDictionary alloc] initWithObjectsAndKeys:currentUserId, @"meUserId", gameName, @"gameName", userIdArray, @"userList", nil];
    
    PFObject *gameObject = [PFCloud callFunction:@"createGame" withParameters:createGameDict];
    
    Game *game = [self getGameFromGameObject:gameObject];
    return game;
}


+ (Game *) getGameFromGameObject:(PFObject *)gameObject
{
    Game *game = [[Game alloc] init];
    
    game.name = [NSString stringWithString:gameObject[@"name"]];
    game.gameId = [NSString stringWithString:gameObject.objectId];
    NSArray *numPlayers = gameObject[@"players"];
    game.numberOfAssassins = [NSNumber numberWithUnsignedInteger:[numPlayers count]];
    NSArray *contractArray = gameObject[@"contracts"];
    int numAliveAssassins = (int) (2 * [numPlayers count] - [contractArray count]);
    game.numberOfAssassinsAlive = [NSNumber numberWithInt:numAliveAssassins];
    game.assassins = gameObject[@"players"];
    game.contracts = gameObject[@"contracts"];
    
    if ([gameObject[@"state"] isEqualToString:@"Completed"])
    {
        game.isComplete = YES;
        PFUser *gameWinner = gameObject[@"winner"];
        [gameWinner fetch];
        game.winnerName = gameWinner.username;
    }
    else
    {
        game.isComplete = NO;
        game.winnerName = nil;
    }
    
    return game;
}

+ (Contract *) getContractFromContractObject:(PFObject *)contractObject
{
    Contract *contract = [[Contract alloc] init];
    
    contract.contractId = contractObject.objectId;
    contract.time = [NSDate date];
    contract.state = contractObject[@"state"];
    
    PFUser *assassin = contractObject[@"assassin"];
    [assassin fetchIfNeeded];
    contract.assassinName = assassin.username;
    contract.assassinFbId = assassin[@"facebookId"];
    PFUser *target = contractObject[@"target"];
    [target fetch];
    contract.targetName = target.username;
    contract.targetFbId = target[@"facebookId"];
    PFObject *game = contractObject[@"game"];
    [game fetchIfNeeded];
    contract.gameId = game.objectId;
    
    if (([contract.state isEqualToString:@"Completed"]) || ([contract.state isEqualToString:@"Pending"]))
    {
        PFFile *imageFile = contractObject[@"image"];
        
        NSData *imageData = [imageFile getData];
        contract.image = [UIImage imageWithData:imageData];
        
        contract.comment = contractObject[@"comment"];
        contract.commentYCoord = [contractObject[@"commentLocation"] floatValue];
    }
    
    else if ([contract.state isEqualToString:@"Active"] || ([contract.state isEqualToString:@"Failed"]))
    {
        contract.image = nil;
        
        contract.comment = nil;
        contract.commentYCoord = -1;
    }
    
    else
    {
        NSLog(@"FATAL ERROR: Unknown state of contract");
    }
    
    return contract;
}

+ (void)confirmAssassination:(NSString *)contractId
{
    PFQuery *query = [PFQuery queryWithClassName:@"Contract"];
    
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:contractId block:^(PFObject *contract, NSError *error) {
        
        // Now let's update it with some new data. In this case, only cheatMode and score
        // will get sent to the cloud. playerName hasn't changed.
        contract[@"state"] = @"Completed";
        [contract save];
        
        NSDictionary *completedContractDict = [[NSDictionary alloc] initWithObjectsAndKeys:contractId, @"contractId", nil];
        NSString *responseString = [PFCloud callFunction:@"completedContract" withParameters:completedContractDict];
        
        NSLog(@"%@", responseString);
        
        PFUser *assassin = contract[@"assassin"];
        
        // Find devices associated with these users
        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"user" equalTo:assassin];
        
        // Send push notification to query
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:pushQuery]; // Set our Installation query
        [push setMessage:[NSString stringWithFormat:@"Your assassination of %@ was confirmed!", [PFUser currentUser].username]];
        [push sendPushInBackground];
    }];
}

+ (void)declineAssassination:(NSString *)contractId
{
    PFQuery *query = [PFQuery queryWithClassName:@"Contract"];
    
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:contractId block:^(PFObject *contract, NSError *error) {
        
        // Now let's update it with some new data. In this case, only cheatMode and score
        // will get sent to the cloud. playerName hasn't changed.
        contract[@"state"] = @"Active";
        [contract saveInBackground];
        
        PFUser *assassin = contract[@"assassin"];
        
        // Find devices associated with these users
        PFQuery *pushQuery = [PFInstallation query];
        [pushQuery whereKey:@"user" equalTo:assassin];
        
        // Send push notification to query
        PFPush *push = [[PFPush alloc] init];
        [push setQuery:pushQuery]; // Set our Installation query
        [push setMessage:@"Your assassination was denied."];
        [push sendPushInBackground];
    }];
}

+ (NSMutableArray *)getContractArray
{
    PFQuery *query = [PFQuery queryWithClassName:@"Contract"];
    [query whereKey:@"assassin" equalTo:[PFUser currentUser]];
    [query whereKey:@"state" containedIn:@[@"Active", @"Pending"]];
    
    NSArray *contractObjects = [query findObjects];
    NSMutableArray *contracts = [[NSMutableArray alloc] init];
    
    for (PFObject *contractObject in contractObjects)
    {
        Contract *contract = [self getContractFromContractObject:contractObject];
        
        [contracts addObject:contract];
    }
    
    return contracts;
}

@end
