//
//  GameTableViewController.h
//  Assassins
//
//  Created by Paul Stavropoulos on 8/4/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"
#import "Contract.h"

@interface GameTableViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) Game *game;
@property (strong, nonatomic) Contract *currentContract;

@end
