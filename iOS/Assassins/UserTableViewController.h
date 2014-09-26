//
//  UserTableViewController.h
//  Assassins
//
//  Created by Paul Stavropoulos on 8/6/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "Game.h"

@interface UserTableViewController : UITableViewController

@property (strong, nonatomic) Game *goToGame;
@property BOOL goToPendingNotifcations;

@end
