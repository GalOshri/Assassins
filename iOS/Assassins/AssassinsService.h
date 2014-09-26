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
+ (void)submitAssassination:(UIImage *)snipeImage withMode:(BOOL)isAttack withComment:(NSString *)comment withCommentLocation:(CGFloat)yCoord withContract:(Contract *)contract;

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

+ (int)checkPendingSnipes;

// + (FBProfilePictureView *)getUserProfilePic:(PFUser *)user;

+ (Game *)createGame:(NSString *)gameName withUserIds:(NSMutableArray *)userIdArray;

+ (void)confirmAssassination:(NSString *)contractId;

+ (void)declineAssassination:(NSString *)contractId withGameId: (NSString *)gameId;

+ (void)startPendingContractProcess: (Contract *)contract withGame:(Game *)game;

+ (int)getNumberOfPendingSnipes;

// Get array of Contract objects
+ (NSMutableArray *)getContractArray;

+ (Contract *) getContractFromContractObject:(PFObject *)contractObject;

@end
