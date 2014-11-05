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
#import <QuartzCore/QuartzCore.h>
#import <DBFBProfilePictureView/DBFBProfilePictureView.h>
#import <FacebookSDK/FacebookSDK.h>

@interface GameCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *gameNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (strong, nonatomic) IBOutlet DBFBProfilePictureView *targetProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *gameProgressLabel;

@property (nonatomic, strong) Game *game;
@property (strong, nonatomic) Contract *currentContract;

@end
