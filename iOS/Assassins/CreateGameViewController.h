//
//  CreateGameViewController.h
//  Assassins
//
//  Created by Paul Stavropoulos on 8/21/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "Game.h"

@interface CreateGameViewController : UIViewController <FBFriendPickerDelegate>

@property (strong, nonatomic) Game *createdGame;


@end
