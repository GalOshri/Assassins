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
    
    //HUD creation here (see example for code)
    
    PFQuery *query = [PFQuery queryWithClassName:@"Contract"];
    
    // Retrieve the object by id
    [query getObjectInBackgroundWithId:@"EJyZKoN3pT" block:^(PFObject *contract, NSError *error) {
        
        contract[@"image"] = imageFile;
        contract[@"status"] = @"Pending";
        
        [contract save];
    }];
}

@end
