//
//  AppDelegate.m
//  Assassins
//
//  Created by Gal Oshri on 7/21/14.
//  Copyright (c) 2014 Kefi. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "VerifySnipeViewController.h"

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
    
    // Register for push notifications
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeBadge |
     UIRemoteNotificationTypeAlert |
     UIRemoteNotificationTypeSound];
    
    // Deal with push notification
    if (launchOptions != nil) {
        // Launched from push notification

        // Extract the notification data
        NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        
        // Create a pointer to the Photo object
        NSString *contractId = [notificationPayload objectForKey:@"contractId"];
        
        [self presentSnipeVerificationView:contractId];
    }
    
    return YES;
}


/*
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
} */


- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    currentInstallation.channels = @[@"global"];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    
    // Create a pointer to the Photo object
    NSString *contractId = [userInfo objectForKey:@"contractId"];
    
    [self presentSnipeVerificationView:contractId];
}

- (void)presentSnipeVerificationView:(NSString *)contractId
{
    PFQuery *query = [PFQuery queryWithClassName:@"Contract"];
    PFObject *contractObject = [query getObjectWithId:contractId];
    
    Contract *contract = [[Contract alloc] init];
    contract.contractId = contractObject.objectId;
    contract.time = contractObject[@"snipeTime"];
    PFFile *imageFile = contractObject[@"image"];
    NSData *imageData = [imageFile getData];
    contract.image = [UIImage imageWithData:imageData];
    
    PFUser *assassin = contractObject[@"assassin"];
    [assassin fetch];
    contract.assassinName = assassin.username;
    PFUser *target = contractObject[@"target"];
    [target fetch];
    contract.targetName = target.username;
    contract.comment = contractObject[@"comment"];
    contract.state = contractObject[@"state"];
    contract.commentYCoord = [contractObject[@"commentLocation"] floatValue];
    
    UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    VerifySnipeViewController* vsvc = [mainstoryboard instantiateViewControllerWithIdentifier:@"verifySnipeView"];
    vsvc.contract = contract;
    [self.window.rootViewController presentViewController:vsvc animated:YES completion:NULL];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
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
