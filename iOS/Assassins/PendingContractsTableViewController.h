//
//  PendingContractsTableViewController.h
//  Assassins
//
//  Created by Paul Stavropoulos on 8/10/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contract.h"

@interface PendingContractsTableViewController : UITableViewController

@property (strong, nonatomic) Contract *goToContract;

@end
