//
//  TutorialViewController.m
//  Assassins
//
//  Created by Gal Oshri on 11/9/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "TutorialViewController.h"

@interface TutorialViewController ()

@property (strong, nonatomic) NSArray *images;
@property (nonatomic) NSUInteger numTutorialImages;
@property (nonatomic) NSUInteger currentTutorialImage;

@end

@implementation TutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.tutorialScrollView.delegate = self;
    
    self.images = @[@"tutorialPage1.jpg", @"spyBckgnd.png", @"spyBckgnd.png"];
    
    self.numTutorialImages = [self.images count];
    self.currentTutorialImage = 0;
    
    for (int i = 0; i < self.images.count; i++)
    {
        CGRect frame;
        frame.origin.x = self.tutorialScrollView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = self.tutorialScrollView.frame.size;
        
        UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self.images objectAtIndex:i]]];
        imgView.frame = frame;
        [self.tutorialScrollView addSubview:imgView];
        
        
        /*
         //  [spotlightSpinner stopAnimating];
         //[spotlightSpinner removeFromSuperview];
         UILabel *imgLabel = [[UILabel alloc] init];
         imgLabel.frame = CGRectMake(frame.origin.x + 12, frame.origin.y + 122, frame.size.width, 23);
         imgLabel.text = [spotlightStrings objectAtIndex:i];
         imgLabel.textColor = [UIColor whiteColor];
         [self.spotlightView addSubview:imgLabel];
         if (i == 0)
         [self.kefiSpotlight removeFromSuperview];
         */
    }
    
    self.tutorialScrollView.contentSize = CGSizeMake(self.tutorialScrollView.frame.size.width * self.images.count, self.tutorialScrollView.frame.size.height);
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.tutorialScrollView.frame.size.width;
    int page = floor((self.tutorialScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (self.pageControl.currentPage != page)
    {
        if (page == 2)
        {
            UIApplication *application = [UIApplication sharedApplication];
            
            // Register for push notifications
            if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
                UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                                UIUserNotificationTypeBadge |
                                                                UIUserNotificationTypeSound);
                UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                         categories:nil];
                [application registerUserNotificationSettings:settings];
                [application registerForRemoteNotifications];
            }
            else {
                // Register for Push Notifications before iOS 8
                [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                                 UIRemoteNotificationTypeAlert |
                                                                 UIRemoteNotificationTypeSound)];
            }
            
            
            self.endTutorialButton.hidden = NO;
            NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
            [userData setObject:[NSNumber numberWithBool:YES] forKey:@"isTutorialDone"];
            [userData synchronize];

        }
    }
    
    self.pageControl.currentPage = page;
}


@end
