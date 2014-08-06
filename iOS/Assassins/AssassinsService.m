//
//  AssassinsService.m
//  Assassins
//
//  Created by Gal Oshri on 8/3/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "AssassinsService.h"
#import <Parse/Parse.h>

@implementation AssassinsService

+ (void)submitAssassination:(UIImage *)snipeImage
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

@end
