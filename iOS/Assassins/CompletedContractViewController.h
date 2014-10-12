//
//  CompletedImageViewController.h
//  Assassins
//
//  Created by Paul Stavropoulos on 8/15/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contract.h"
#import "Game.h"

@interface CompletedContractViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>


@property (weak, nonatomic) IBOutlet UIImageView *contractImage;
@property (weak, nonatomic) IBOutlet UITextField *contractComment;

@property (strong, nonatomic) Contract *contract;
@property (strong, nonatomic) Game *game;

@end
