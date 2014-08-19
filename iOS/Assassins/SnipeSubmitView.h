//
//  SnipeSubmitView.h
//  Assassins
//
//  Created by Gal Oshri on 7/24/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Game.h"


@interface SnipeSubmitView : UIViewController <UIGestureRecognizerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *snipeImageView;
@property (strong, nonatomic) UIImage *snipeImage;

@end
