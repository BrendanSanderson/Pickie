//
//  AppDelegate.m
//  FaveRestaurants
//
//  Created by Henry Sanderson on 7/6/15.
//  Copyright (c) 2015 King_B. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // [Optional] Power your app with Local Datastore. For more info, go to
    // https://parse.com/docs/ios_guide#localdatastore/iOS
    [Parse enableLocalDatastore];
    
    // Initialize Parse.
    [Parse setApplicationId:@"ipoZD08lDRcgdkEaCtKqIMUSRrpnmYzaWiWOXnAs"
                  clientKey:@"LWOCdCDB6lIaYngECj1lUdsT5FwhzHxkXLOUUOU9"];
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    [[UINavigationBar appearance] setTintColor:[[UIColor alloc]initWithRed:239.0/255.0 green:101.0/255.0 blue:85.0/255.0 alpha:1.0]];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [[UIColor alloc]initWithRed:239.0/255.0 green:101.0/255.0 blue:85.0/255.0 alpha:1.0]}];
    [[UINavigationBar appearance] setTranslucent:NO];
    self.window.backgroundColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
    [[UINavigationBar appearance] setBarTintColor:[[UIColor alloc]initWithRed:37.0/255.0 green:62.0/255.0 blue:102.0/255.0 alpha:1.0]];
    [[UITabBar appearance] setTintColor:[[UIColor alloc]initWithRed:239.0/255.0 green:101.0/255.0 blue:85.0/255.0 alpha:1.0]];
//    [[UITabBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [[UIColor alloc]initWithRed:239.0/255.0 green:101.0/255.0 blue:85.0/255.0 alpha:1.0]}];]
    [[UITabBar appearance] setBarTintColor:[[UIColor alloc]initWithRed:37.0/255.0 green:62.0/255.0 blue:102.0/255.0 alpha:1.0]];
    
    
    // ...
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if(![[NSUserDefaults standardUserDefaults] stringForKey:@"userID"]){
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"WelcomeViewController"];
        self.window.rootViewController = viewController;
    } else {
        UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"MainTabBarController"];
        self.window.rootViewController = viewController;
    }
    
    [self.window makeKeyAndVisible];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end