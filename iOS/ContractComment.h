//
//  ContractComment.h
//  Assassins
//
//  Created by Paul Stavropoulos on 10/12/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContractComment : NSObject

@property(strong, nonatomic) NSString *commentCreator;
@property(strong, nonatomic) NSDate *dateCreated;
@property(strong, nonatomic) NSString *commentText;

@end
