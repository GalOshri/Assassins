//
//  GameEventTableViewCell.h
//  Assassins
//
//  Created by Paul Stavropoulos on 8/4/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contract.h"
#import <FacebookSDK/FacebookSDK.h>

@interface AssassinationEventCell : UITableViewCell
@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePicture;


@property (weak, nonatomic) IBOutlet UILabel *headlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *snipeImagePreview;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property float commentLabelPosition;

@property (strong, nonatomic) Contract *contract;

@end
