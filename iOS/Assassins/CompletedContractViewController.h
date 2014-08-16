//
//  CompletedImageViewController.h
//  Assassins
//
//  Created by Paul Stavropoulos on 8/15/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Contract.h"

@interface CompletedContractViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIImageView *contractImage;
@property (weak, nonatomic) IBOutlet UITextField *contractComment;

@property (strong, nonatomic) Contract *contract;

@end
