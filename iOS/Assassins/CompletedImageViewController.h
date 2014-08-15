//
//  CompletedImageViewController.h
//  Assassins
//
//  Created by Paul Stavropoulos on 8/15/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompletedImageViewController : UIViewController

@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *comment;

@property (weak, nonatomic) IBOutlet UIImageView *contractImage;
@property (weak, nonatomic) IBOutlet UITextField *contractComment;
@property float commentLabelYCoord;

@end
