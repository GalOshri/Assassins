//
//  AssassinsService.h
//  Assassins
//
//  Created by Gal Oshri on 8/3/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Contract.h"

@interface AssassinsService : NSObject

// called in VerifySnipeViewController
+ (void)submitAssassination:(UIImage *)snipeImage withMode: (BOOL)isSnipeMode withComment:(NSString *)comment withCommentLocation:(CGFloat)yCoord;

// called in GameTableViewController
+ (void)populateCompletedContracts:(NSMutableArray *)contractArray withGameId:(NSString *)gameId withTable: (UITableView *)tableview;
+ (void)populateCurrentContract:(Contract *)currentContract withGameId:(NSString *)gameId;

// called in ParticipantsTableViewController
+ (void)populateAssassinList:(NSMutableArray *)assassinArray withGameId:(NSString *)gameId;


// called in UserTableViewController.
+ (void)populateUserGames:(NSMutableArray *)gamesList withUserId:(PFUser *)user;
+ (void)populateCompletedUserContracts:(NSMutableArray *)contractArray forUser:(PFUser *)user;


@end
