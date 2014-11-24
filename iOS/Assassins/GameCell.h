//
//  GameCell.h
//  Assassins
//
//  Created by Gal Oshri on 8/10/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"
#import "Contract.h"
#import <FacebookSDK/FacebookSDK.h>

@interface GameCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *gameNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *targetProfilePic;
@property (weak, nonatomic) IBOutlet UIImageView *noTargetPic;


@property (nonatomic, strong) Game *game;
@property (strong, nonatomic) Contract *currentContract;

// @property (weak, nonatomic) IBOutlet UILabel *gameProgressLabel;

@end
