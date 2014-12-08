//
//  AssassinsLogInView.m
//  Assassins
//
//  Created by Gal Oshri on 8/3/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "AssassinsLogInView.h"
#import <QuartzCore/QuartzCore.h>
#import <FacebookSDK/FacebookSDK.h>


@interface AssassinsLogInView ()

@end

@implementation AssassinsLogInView

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"assassinsSignIn.png"]]];
    [self.logInView.logo setHidden:YES];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // create text to show people
    UITextView *fbLabel = [[UITextView alloc]init];
    [fbLabel setText:@"Snipe uses facebook so that you can create games of Assassins with your friends. We use your name, profile picture, and friend list."];
    [fbLabel setScrollEnabled:NO];
    [fbLabel setSelectable:NO];
    [fbLabel setFont:[UIFont systemFontOfSize:14.0]];
    [fbLabel setTextColor: [UIColor whiteColor]];
    [fbLabel setBackgroundColor:[UIColor clearColor]];
    fbLabel.textAlignment = NSTextAlignmentLeft;
    [fbLabel setFrame:CGRectMake(8, 100, self.view.frame.size.width - 16, 80)];
    [self.logInView addSubview:fbLabel];
    
    // set frame of fb button
    [self.logInView.facebookButton setFrame:CGRectMake(self.view.center.x - 60,fbLabel.frame.origin.y + fbLabel.frame.size.height +20, 120.0, 40.0f)];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
