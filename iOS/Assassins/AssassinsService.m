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

+ (void)populateCompletedContracts:(NSMutableArray *)contractArray withGameId:(NSString *)gameId
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
            contract.image = [UIImage imageNamed:@"cameraIcon.png"];
            contract.assassinName = @"Galileo";
            contract.targetName = @"Pauly";
            contract.comment = @"Boom.";
            
            [contractArray addObject:contract];
            
            
        }
        return;
    }
    
    // Get all completed contracts for this game
    PFQuery *queryContracts = [PFQuery queryWithClassName:@"Game"];
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

@end
