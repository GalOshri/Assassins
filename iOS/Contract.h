//
//  Contract.h
//  Assassins
//
//  Created by Gal Oshri on 8/6/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Contract : NSObject

@property (strong, nonatomic) NSString *contractId;
@property (strong, nonatomic) NSDate *time;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *assassinName;
@property (strong, nonatomic) NSString *targetName;
@property (strong, nonatomic) NSString *comment;
@property (strong, nonatomic) NSString *state;
@property float commentYCoord;


@end
