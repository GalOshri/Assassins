//
//  PendingContractsTableViewCell.h
//  Assassins
//
//  Created by Paul Stavropoulos on 8/11/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contract.h"
#import <FacebookSDK/FacebookSDK.h>

@interface PendingContractsTableViewCell : UITableViewCell

@property (strong, nonatomic) Contract *contract;
@property (weak, nonatomic) IBOutlet UILabel *pendingLabel;
@property (weak, nonatomic) IBOutlet UILabel *pendingDateLabel;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *profilePicture;



@end
