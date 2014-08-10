//
//  Game.h
//  Assassins
//
//  Created by Paul Stavropoulos on 8/7/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Game : NSObject

@property (strong, nonatomic) NSString *gameId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *numberOfAssassins;
@property (strong, nonatomic) NSNumber *numberOfAssassinsAlive;
@property (strong, nonatomic) NSArray *assassins;

@end
