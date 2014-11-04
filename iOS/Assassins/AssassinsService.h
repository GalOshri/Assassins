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
+ (NSMutableArray *)getPendingContractsForGame:(NSString *)gameId;

// called in UserTableViewController
+ (Contract *)getContractForGame:(NSString *)gameId;
+ (NSMutableDictionary *)getContractsForGames: (NSMutableArray *)gameIds;

// called in ParticipantsTableViewController
+ (NSArray *)getAssassinListFromGame:(Game *)game;

// called in SnipeSubmitView
+ (NSArray *)getGameList:(BOOL)getCurrentGamesOrNah;
+ (Game *) getGameWithId:(NSString *)gameId;

// called in createGameViewController
+ (Game *)createGame:(NSString *)gameName withSafeZones:(NSString *)safeZones withUserIds:(NSMutableArray *)userIdArray;

+ (void)confirmAssassination:(NSString *)contractId;
+ (void)declineAssassination:(NSString *)contractId withGameId: (NSString *)gameId;
+ (void)startPendingContractProcess: (Contract *)contract withGame:(Game *)game;

// Get array of Contract objects
+ (NSMutableArray *)getContractArray;
+ (Contract *) getContractFromContractObject:(PFObject *)contractObject;
+ (NSMutableArray *) getCommentsWithContract:(NSString *)contractId;
+ (BOOL) addComment:(NSString *)comment withContractId:(NSString *)contractId;

@end


//+ (void)populateAssassinList:(NSMutableArray *)assassinArray withGameId:(NSString *)gameId;
// + (NSArray *)getPendingSnipes;
// + (int)checkPendingSnipes;
// + (FBProfilePictureView *)getUserProfilePic:(PFUser *)user;
// + (int)getNumberOfPendingSnipes;
// + (void)removeSnipeToVerify:(NSString *)contractId;