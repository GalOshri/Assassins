//
//  FriendTableViewCell.h
//  Assassins
//
//  Created by Paul Stavropoulos on 8/22/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "fbFriend.h"

@interface FriendTableViewCell : UITableViewCell

@property (strong, nonatomic) fbFriend *fbFriend;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;


@end
