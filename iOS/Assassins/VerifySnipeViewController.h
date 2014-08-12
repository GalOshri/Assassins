//
//  verifySnipeViewController.h
//  Assassins
//
//  Created by Paul Stavropoulos on 8/4/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "Contract.h"

@interface VerifySnipeViewController : UIViewController

@property (strong, nonatomic) Contract *contract;
@property (strong, nonatomic) IBOutlet UIImageView *snipeImage;

@end
