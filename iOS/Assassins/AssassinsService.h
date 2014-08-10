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
#import "Game.h"

@interface AssassinsService : NSObject

// called in VerifySnipeViewController
+ (void)submitAssassination:(UIImage *)snipeImage withMode: (BOOL)isSnipeMode withComment:(NSString *)comment withCommentLocation:(CGFloat)yCoord;

// called in GameTableViewController
+ (NSMutableArray *)getCompletedContractsForGame:(NSString *)gameId;

+ (Contract *)getContractForGame:(NSString *)gameId;

// called in ParticipantsTableViewController
+ (void)populateAssassinList:(NSMutableArray *)assassinArray withGameId:(NSString *)gameId;

+ (NSArray *)getAssassinListFromGame:(Game *)game;

// called in UserTableViewController.
+ (void)populateUserGames:(NSMutableArray *)gamesList;

+ (Game *) getGameWithId:(NSString *)gameId;

@end
