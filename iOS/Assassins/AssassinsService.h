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

@property BOOL hasPendingSnipe;

// called in VerifySnipeViewController
+ (void)submitAssassination:(UIImage *)snipeImage withMode:(BOOL)isAttack withComment:(NSString *)comment withCommentLocation:(CGFloat)yCoord withContractId: (NSString *)contractId;

// called in GameTableViewController
+ (NSMutableArray *)getCompletedContractsForGame:(NSString *)gameId;

// TODO: DON'T USE THIS WITHOUT FIXING GAME ID STUFF - not used for anything now
// + (NSArray *)getCompletedContractsForGames:(NSArray *)gameIdArray;

+ (Contract *)getContractForGame:(NSString *)gameId;

// called in ParticipantsTableViewController
//+ (void)populateAssassinList:(NSMutableArray *)assassinArray withGameId:(NSString *)gameId;

+ (NSArray *)getAssassinListFromGame:(Game *)game;

// called in UserTableViewController.
+ (NSArray *)getGameList;

+ (Game *) getGameWithId:(NSString *)gameId;

+ (NSArray *)getPendingSnipes;

// + (FBProfilePictureView *)getUserProfilePic:(PFUser *)user;

+ (Game *)createGame:(NSString *)gameName withUserIds:(NSMutableArray *)userIdArray withCurrentUserId:(NSString *)currentUserId;

+ (void)confirmAssassination:(NSString *)contractId;

+ (void)declineAssassination:(NSString *)contractId;

// Get array of Contract objects
+ (NSArray *)getContractArray;

@end
