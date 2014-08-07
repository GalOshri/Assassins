//
//  ParticipantTableViewCell.h
//  Assassins
//
//  Created by Paul Stavropoulos on 8/6/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ParticipantTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *isAliveLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;

@end
