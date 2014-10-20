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

@interface VerifySnipeViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) Contract *contract;
@property (strong, nonatomic) IBOutlet UIImageView *snipeImage;

@property BOOL isSnipeChanged;

@end
