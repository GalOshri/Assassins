//
//  verifySnipeViewController.h
//  Assassins
//
//  Created by Paul Stavropoulos on 8/4/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface VerifySnipeViewController : UIViewController
@property (strong, nonatomic) PFFile *file;
@property (strong, nonatomic) IBOutlet UIImageView *snipeImage;
@property (strong, nonatomic) NSString *contractId;
@property (strong, nonatomic) NSString *commentText;
@property float commentYCoord;



@end
