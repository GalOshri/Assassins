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
#import "ContractComment.h"

@implementation AssassinsService

+ (void)submitAssassination:(UIImage *)snipeImage withMode:(BOOL)isAttack withComment:(NSString *)comment withCommentLocation:(CGFloat)yCoord withContract:(Contract *)contract
{
    if (isAttack)
    {
        NSData *snipeImageData = UIImageJPEGRepresentation(snipeImage, 1);
        PFFile *imageFile = [PFFile fileWithName:[NSString stringWithFormat:@"SnipeImage.jpg"] data:snipeImageData];
        
        NSDate *snipeTime = [NSDate date];
        
        PFQuery *query = [PFQuery queryWithClassName:@"Contract"];
        
        // Retrieve the object by id
        [query getObjectInBackgroundWithId:contract.contractId block:^(PFObject *contractObject, NSError *error) {
        
            contractObject[@"image"] = imageFile;
            contractObject[@"state"] = @"Completed"; // NOPENDING
            contractObject[@"snipeTime"] = snipeTime;
            
            // set comment fields
            if ([comment isEqualToString:@""]) {
                contractObject[@"commentLocation"] = [NSNumber numberWithFloat:-1.0];
                contractObject[@"comment"] = @"";
            }
            else {
                contractObject[@"commentLocation"] = [NSNumber numberWithFloat:yCoord];
                contractObject[@"comment"] = comment;
            }
            
            [contractObject save];
            
            // NOPENDING --------------------------------------------*************************************
            NSDictionary *completedContractDict = [[NSDictionary alloc] initWithObjectsAndKeys:contractObject.objectId, @"contractId", nil];
            NSString *responseString = [PFCloud callFunction:@"completedContract" withParameters:completedContractDict];
            
            // should send to everyone! Grab all users
            PFUser *game = contractObject[@"game"];
            [game fetch];
            NSArray *gamePlayers = game[@"players"];
            
            /*
            NSMutableArray *playerObjects;
             for (PFUser *player in gamePlayers)
            {
                PFUser *tempUser= [[PFUser alloc] init];
                [tempUser setObjectId:player.objectId];
                [playerObjects addObject:tempUser];
            }
            */
            /*
            PFQuery *pushQuery = [PFInstallation query];
            [pushQuery whereKey:@"user" containedIn:gamePlayers];
            
            // Send push notification to query
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSString stringWithFormat:@"%@ has been eliminated!", contract.targetName], @"alert",
                                  contractObject.objectId, @"contractId", contract.gameId, @"gameId",
                                  nil];
            
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:pushQuery];
            [push setData:data];
            [push sendPushInBackground];
            */
        }];
    }
}


+ (NSMutableArray *)getCompletedContractsForGame:(NSString *)gameId
{
    
    NSMutableArray *contractArray = [[NSMutableArray alloc] init];
    
    // Get all completed contracts for this game
    // AND PENDING!
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

+ (NSMutableArray *)getPendingContractsForGame:(NSString *)gameId;
{
    NSMutableArray *contractArray = [[NSMutableArray alloc] init];
    
    // Get all completed contracts for this game
    // AND PENDING!
    PFQuery *queryContracts = [PFQuery queryWithClassName:@"Contract"];
    [queryContracts whereKey:@"game" equalTo:[PFObject objectWithoutDataWithClassName:@"Game" objectId:gameId]];
    
    [queryContracts whereKey:@"state" equalTo:@"Pending"];
    
    NSArray *contractObjects = [queryContracts findObjects];
    
    for (PFObject *contractObject in contractObjects)
    {
        Contract *contract = [self getContractFromContractObject:contractObject];
        
        [contractArray addObject:contract];
    }
    return contractArray;
}

+ (NSArray *)getAssassinListFromGame:(Game *)game
{
    NSMutableArray *assassinArray = [[NSMutableArray alloc] init];
    
    NSArray *userArray = game.assassins;
    // NSArray *contractArray = game.contracts;
    NSMutableSet *uniqueIds = [[NSMutableSet alloc] init];
    
    [PFUser fetchAll:userArray];
    
    for (PFUser *user in userArray)
    {
        Assassin *assassin = [[Assassin alloc] init];
        
        assassin.username = user.username;
        assassin.userId = user.objectId;
        assassin.fbId = user[@"facebookId"];
        assassin.isAlive = YES;
        assassin.isPending = NO;
        assassin.numberOfSnipes = (int) user[@"lifetimeSnipes"];
        
        // put all players into a set and array to sort
        [uniqueIds addObject:assassin.userId];
        [assassinArray addObject:assassin];
    }
    
    // sort array
    NSSortDescriptor *usernameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"username" ascending:YES];
    assassinArray = [[assassinArray sortedArrayUsingDescriptors:@[usernameDescriptor]] mutableCopy];
    
    // grab all contracts for a game
    PFQuery *contractQuery = [PFQuery queryWithClassName:@"Contract"];
    
    [contractQuery whereKey:@"game" equalTo:[PFObject objectWithoutDataWithClassName:@"Game" objectId:game.gameId]];
    [contractQuery orderByDescending:@"createdAt"];

    

    NSArray *contractArray = [contractQuery findObjects];
    
    for (PFObject *contract in contractArray)
    {
        PFObject *target = contract[@"target"];
        if ([uniqueIds containsObject:target.objectId]) {
            // change assassin to correct state
            for (Assassin *assassin in assassinArray)
            {
                if ([assassin.userId isEqualToString:target.objectId])
                {
                    if ([contract[@"state"] isEqualToString:@"Completed"])
                        assassin.isAlive = NO;
                    
                    if ([contract[@"state"] isEqualToString:@"Pending"])
                    {
                        assassin.isPending = YES;
                        assassin.isAlive = NO;
                    }
                }
            }
            
            // remove the object to not conflict
            [uniqueIds removeObject:target.objectId];
        }
    }

    return assassinArray;
}


+ (Contract *)getContractForGame:(NSString *)gameId
{
    PFQuery *query = [PFQuery queryWithClassName:@"Contract"];
    [query whereKey:@"assassin" equalTo:[PFUser currentUser]];
    [query whereKey:@"state" equalTo:@"Active"];
    [query whereKey:@"game" equalTo:[PFObject objectWithoutDataWithClassName:@"Game" objectId:gameId]];
    
    // Retrieve the object by id
    PFObject *contractObject = [query getFirstObject];
    
    // if user is active in game
    if (contractObject != nil)
    {
        Contract *contract = [self getContractFromContractObject:contractObject];
        return contract;
    }
    
    // if user is pending or dead
    else
    {
        PFQuery *query1 = [PFQuery queryWithClassName:@"Contract"];
        [query1 whereKey:@"target" equalTo:[PFUser currentUser]];
        [query1 whereKey:@"state" equalTo:@"Pending"];
        [query1 whereKey:@"game" equalTo:[PFObject objectWithoutDataWithClassName:@"Game" objectId:gameId]];
        
        // Retrieve the object by id
        PFObject *contractObject1 = [query1 getFirstObject];
        
        if (contractObject1)
        {
            Contract *contract = [self getContractFromContractObject:contractObject1];
            return contract;
        }
        
        // if nothing, user is dead
        else
        {
            return nil;
        }
    }
}


+ (NSArray *)getGameList:(BOOL)getCurrentGamesOrNah
{
    NSMutableArray *gameList = [[NSMutableArray alloc] init];
    PFUser *currentUser = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Game"];
    
    [query whereKey:@"players" equalTo:currentUser];
    
    if (getCurrentGamesOrNah)
        [query whereKey:@"state" equalTo:@"Active"];
    else
        [query whereKey:@"state" equalTo:@"Completed"];

    [query orderByDescending:@"createdAt"];
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
    
    // make query for current user to find pending snipes.
    PFQuery *userSnipeQuery = [PFUser query];
    [userSnipeQuery whereKey:@"objectId" equalTo:[PFUser currentUser].objectId];
    
    PFObject *user = [userSnipeQuery getFirstObject];
    NSArray *userPendingSnipes = [user objectForKey:@"snipesToVerify"];
    
    PFQuery *findContracts = [PFQuery queryWithClassName:@"Contract"];
    [findContracts whereKey:@"objectId" containedIn:userPendingSnipes];
    
    NSArray *contractObjects = [findContracts findObjects];
    
    for (PFObject *contractObject in contractObjects)
    {
        Contract *contract = [self getContractFromContractObject:contractObject];
        
        if ([contract.targetFbId isEqualToString:[user objectForKey:@"facebookId"]])
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
        PFUser *currentUser = [PFUser currentUser];
        return (int)currentUser[@"snipesToVerify"];
    }
    else
        return 0;
}

+ (void) removeSnipeToVerify:(NSString *)contractId
{
    // get user
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"objectId" equalTo:[PFUser currentUser].objectId];
    PFObject *currentUser = [userQuery getFirstObject];
    
    // remove object and save
    [currentUser removeObjectsInArray:@[contractId] forKey:@"snipesToVerify"];
    [currentUser save];
    

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

+ (Game *) createGame:(NSString *)gameName withSafeZones:(NSString *)safeZones withUserIds:(NSMutableArray *)userIdArray
{
    NSDictionary *createGameDict = [[NSDictionary alloc] initWithObjectsAndKeys: gameName, @"gameName", safeZones, @"safeZones", userIdArray, @"userList", nil];
    
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
    game.numberPendingContracts = gameObject[@"numberPendingSnipes"];
    game.safeZones = gameObject[@"safeZones"];
    
    if ([gameObject[@"state"] isEqualToString:@"Completed"])
    {
        game.isComplete = YES;
        game.winnerName = gameObject[@"winnerName"];
        game.winnerFbId = gameObject[@"winnerFbId"];
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
    contract.time = contractObject[@"snipeTime"];
    contract.state = contractObject[@"state"];
    
    // PFUser *assassin = contractObject[@"assassin"];
    contract.assassinName = contractObject[@"assassinName"];
    contract.assassinFbId = contractObject[@"assassinFbId"];
    // PFUser *target = contractObject[@"target"];

    contract.targetName = contractObject[@"targetName"];
    contract.targetFbId = contractObject[@"targetFbId"];
    PFObject *game = contractObject[@"game"];
    [game fetchIfNeeded];
    contract.gameId = game.objectId;
    contract.gameName = game[@"name"];
    
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

}

+ (void)declineAssassination:(NSString *)contractId withGameId:(NSString *)gameId
{
    // call cloud code to add username to array of invalidateVoters, check if it has been overturned, and clean function if not
    NSDictionary *declineSnipeDict = [[NSDictionary alloc] initWithObjectsAndKeys:gameId, @"gameId", contractId, @"contractId", [PFUser currentUser].objectId, @"userId", nil];
    NSString *responseString = [PFCloud callFunction:@"checkInvalidatedSnipe" withParameters:declineSnipeDict];
}

+ (void)startPendingContractProcess:(Contract *)contract withGame:(Game *)game
{
    NSDictionary *pendingContractDict = [[NSDictionary alloc] initWithObjectsAndKeys:game.gameId, @"gameId", contract.contractId, @"contractId",contract.targetName, @"targetName", nil];
    NSString *responseString = [PFCloud callFunction:@"startPendingContractProcess" withParameters:pendingContractDict];
}

/*
 + (int)getNumberOfPendingSnipes
{
    // make query for current user to find number of pending snipes.
    // TODO: is this right?
    PFQuery *userSnipeQuery = [PFUser query];
    [userSnipeQuery whereKey:@"objectId" equalTo:[PFUser currentUser].objectId];
    
    PFObject *user = [userSnipeQuery getFirstObject];
    NSArray *snipesToVerify = [user objectForKey:@"snipesToVerify"];
    
    return [snipesToVerify count];
}
*/

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

+ (NSMutableArray *) getCommentsWithContract:(NSString *)contractId
{
    NSMutableArray *commentObjects = [[NSMutableArray alloc] init];
    
    // create query to Contract
    PFQuery *query = [PFQuery queryWithClassName:@"Comment"];
    [query whereKey:@"contractId" equalTo:[PFObject objectWithoutDataWithClassName:@"Contract" objectId:contractId]];
    [query orderByAscending:@"createdAt"];
    
    // create comments
    NSArray *objects = [query findObjects];
    
    for(PFObject *comment in objects)
    {
        ContractComment *newComment = [[ContractComment alloc] init];
        newComment.commentCreator = comment[@"creatorName"];
        newComment.commentText = comment[@"text"];
        newComment.dateCreated = comment[@"createdAt"];
        
        // add to array
        [commentObjects addObject:newComment];
    }

    return commentObjects;
}

+ (BOOL)addComment:(NSString *)comment withContractId:(NSString *)contractId
{
    // perform checks to see if we post
    if ([comment isEqualToString:@""] || [comment isEqualToString:@" "]) {
        return false;
    }
    
    else
    {
        PFObject *commentToAdd = [PFObject objectWithClassName:@"Comment"];
        commentToAdd[@"contractId"] = [PFObject objectWithoutDataWithClassName:@"Contract" objectId:contractId];
        commentToAdd[@"creator"] = [PFObject objectWithoutDataWithClassName:@"_User" objectId:[PFUser currentUser].objectId];
        commentToAdd[@"creatorName"] = [PFUser currentUser].username;
        commentToAdd[@"text"] = comment;
        
        [commentToAdd saveInBackground];
        
        return true;
    }
}

@end
