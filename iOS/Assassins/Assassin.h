//
//  Assassin.h
//  Assassins
//
//  Created by Paul Stavropoulos on 8/6/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Assassin : NSObject

@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *fbId;
@property BOOL isAlive;
@property int numberOfSnipes;



@end
