//
//  AppDelegate.m
//  Assassins
//
//  Created by Gal Oshri on 7/21/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "AssassinsService.h"
#import "ViewController.h"
#import "GameTableViewController.h"
#import "AGPushNoteView.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [Parse setApplicationId:@"VFGeqNO5kWHeylYJa7veoVIiBr77ER337hnJdfdm"
                  clientKey:@"zfTN95pYukQlNMQy2jKEF51DtiIkV2wUce3E903F"];
    
    [PFTwitterUtils initializeWithConsumerKey:@"ghZLs8QVyMpTOt2k0wYMd2Xad"
                               consumerSecret:@"bc0Yrtc2rp8csRStmDo8ef2ISCNcM6ZVblUNd2BN5i2QEFk8HA"];
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [PFFacebookUtils initializeFacebook];
    [FBProfilePictureView class];
    [FBFriendPickerViewController class];
    
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

    
    
    // Deal with push notification
    if (launchOptions != nil) {
        /*
         // Launched from push notification

        // Extract the notification data
        NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        
        if ([notificationPayload valueForKey:@"contractId"] != nil) {
            // someone wants to verify snipe
            NSString *contractId = [notificationPayload objectForKey:@"contractId"];
            [self presentSnipeVerificationView:contractId];
        }
        
        else
        {
            // game was won
            NSString *gameId = [notificationPayload objectForKey:@"gameId"];
            [self presentCameraView:gameId];
        }

    }
    
    // find number of pending snipes
    // self.numberPendingSnipe = [AssassinsService getNumberOfPendingSnipes];
    */
    }
    
    self.isInForeground = YES;
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    currentInstallation.channels = @[@"global"];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    //BOOL inForefground = NO;

    /*if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive || [[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive)
        inForefground = YES;
    */
    
    if (!self.isInForeground)
    {
        [PFPush handlePush:userInfo];
        /*// events: game created, someone sniped, someone contests, someoneone wins, someone brought back to life
        //  --> ALL GO TO GAME VIEW
        if ([userInfo valueForKey:@"contractId"] != nil) {
            // someone wants to verify snipe
            NSString *contractId = [userInfo objectForKey:@"contractId"];
           // [self 
         */
        
        if ([userInfo valueForKey:@"gameId"] != nil)
        {
            // game was won
            NSString *gameId = [userInfo objectForKey:@"gameId"];
            [self presentCameraView:gameId];
        }
    }
    
    // app is active, we send a local event
    else
    {
        NSDictionary *message = [userInfo objectForKey:@"aps"];
        [AGPushNoteView showWithNotificationMessage:message[@"alert"]];
        //AGPushNoteView setMessageAction:^(NSString *message) {
        
        //}
    }
}

- (void)presentCameraView:(NSString *)gameId
{
   // UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
    
    GameTableViewController *gameView = [[GameTableViewController alloc] init];
    //gameView.game.gameId = gameId;

    [navController pushViewController:gameView animated:YES];
    
    
}

-(void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    self.isInForeground = NO;
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    // self.isInForeground = YES;
}



- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}


@end
