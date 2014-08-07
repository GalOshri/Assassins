//
//  AssassinsService.h
//  Assassins
//
//  Created by Gal Oshri on 8/3/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Contract.h"

@interface AssassinsService : NSObject

+ (void)submitAssassination:(UIImage *)snipeImage withMode: (BOOL)isSnipeMode withComment:(NSString *)comment withCommentLocation:(CGFloat)yCoord;

+ (void)populateCompletedContracts:(NSMutableArray *)contractArray withGameId:(NSString *)gameId withTable: (UITableView *)tableview;

+ (void)populateCurrentContract:(Contract *)currentContract withGameId:(NSString *)gameId;

+ (void)populateAssassinList:(NSMutableArray *)assassinArray withGameId:(NSString *)gameId;


@end
