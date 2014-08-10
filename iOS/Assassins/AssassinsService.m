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

+ (void)submitAssassination:(UIImage *)snipeImage withMode:(BOOL)isSnipeMode withComment:(NSString *)comment withCommentLocation:(CGFloat)yCoord
{
    if (isSnipeMode)
    {

    
        NSData *snipeImageData = UIImageJPEGRepresentation(snipeImage, 1);
        PFFile *imageFile = [PFFile fileWithName:[NSString stringWithFormat:@"SnipeImage.jpg"] data:snipeImageData];
        
        // Get Contract
        NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
        NSString *contractId = [userData objectForKey:@"contractId"];
        
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


+ (void)populateCompletedContracts:(NSMutableArray *)contractArray withGameId:(NSString *)gameId withTable:(UITableView *)tableview
{
    BOOL DEBUGAL = YES;
    
    [contractArray removeAllObjects];
    
    if (DEBUGAL)
    {
        for (int i = 0; i < 4; i++)
        {
            Contract *contract = [[Contract alloc] init];
            
            contract.contractId = [NSString stringWithFormat:@"Contract%d",i];
            contract.time = [NSDate date];
            contract.image = [UIImage imageNamed:@"cameraIconSmaill.png"];
            contract.assassinName = @"Galileo";
            contract.targetName = @"Pauly";
            contract.comment = @"Boom.";
            
            [contractArray addObject:contract];
        }
        //[tableview performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        return;
    }
    
    // Get all completed contracts for this game
    PFQuery *queryContracts = [PFQuery queryWithClassName:@"Contract"];
    [queryContracts whereKey:@"gameId" equalTo:gameId];
    [queryContracts whereKey:@"state" equalTo:@"Completed"];
    
    
    
    [queryContracts findObjectsInBackgroundWithBlock:^(NSArray *contracts, NSError *error)
    {
        if (!error)
        {
            for (PFObject *contractObject in contracts)
            {
                Contract *contract = [[Contract alloc] init];
                
                contract.contractId = contractObject.objectId;
                contract.time = [NSDate date];
                PFFile *imageFile = contractObject[@"image"];
                
                NSURLSession *session = [NSURLSession sharedSession];
                [[session dataTaskWithURL:[NSURL URLWithString:imageFile.url]
                        completionHandler:^(NSData *data,
                                            NSURLResponse *response,
                                            NSError *error) {
                            
                            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                
                                UIImage *img = [[UIImage alloc] initWithData:data];
                                
                                contract.image = img;
                                
                            }];
                        }] resume];
                
                PFUser *assassin = contractObject[@"assassin"];
                contract.assassinName = assassin.username;
                PFUser *target = contractObject[@"target"];
                contract.targetName = target.username;
                contract.comment = contractObject[@"comment"];
            }
        }
    }];
    
}


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
            assassin.assassinImage = [UIImage imageNamed:@"snipeCircle.png"];
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
                     assassin.assassinImage = [UIImage imageNamed:@"flipCamera.png"];
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
             }
         }
     }];
    
}

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
        assassin.assassinImage = [UIImage imageNamed:@"snipeCircle.png"];
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
    // Get Contract
    // TODO: Can have multiple contracts (one per game).
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    NSString *contractId = [userData objectForKey:@"contractId"];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Contract"];
    [query whereKey:@"assassin" equalTo:[PFUser currentUser]];
    [query whereKey:@"gameId" equalTo:gameId];
    
    // Retrieve the object by id
    PFObject *contractObject = [query getFirstObject];
    
    Contract *contract = [[Contract alloc] init];
    
    contract.contractId = contractObject.objectId;
    contract.time = contractObject[@"snipeTime"];
    contract.image = nil;
    contract.assassinName = [PFUser currentUser].username;
    PFUser *target = contractObject[@"target"];
    [target fetch];
    contract.targetName = target.username;
    contract.comment = nil;
    
    return contract;
}


+ (void) populateUserGames:(NSMutableArray *)gamesList
{
    PFUser *currentUser = [PFUser currentUser];
    PFQuery *query = [PFQuery queryWithClassName:@"Game"];
    
    [query whereKey:@"players" equalTo:currentUser];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *games, NSError *error) {
        if (!error)
        {
            for (PFObject *gameObject in games)
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
                
                [gamesList addObject:game];
            }
        }
    }];
}

+ (Game *) getGameWithId:(NSString *)gameId
{
    PFQuery *query = [PFQuery queryWithClassName:@"Game"];
    PFObject *gameObject = [query getObjectWithId:gameId];
    
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
    
    return game;
}


@end
