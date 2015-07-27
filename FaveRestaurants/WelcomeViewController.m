//
//  UIViewController+WelcomeViewController.m
//  FaveRestaurants
//
//  Created by Henry Sanderson on 7/7/15.
//  Copyright (c) 2015 King_B. All rights reserved.
//

#import "WelcomeViewController.h"
#import <Parse/Parse.h>
#import <CoreFoundation/CoreFoundation.h>

@implementation WelcomeViewController
@synthesize window, PickyLabel, startButton;
-(void) viewDidLoad
{
//    self.view.backgroundColor = [[UIColor alloc]initWithRed:101.0/255.0 green:132.0/255.0 blue:158.0/255.0 alpha:1.0];
    self.view.backgroundColor = [[UIColor alloc]initWithRed:37.0/255.0 green:62.0/255.0 blue:102.0/255.0 alpha:1.0];
    startButton.layer.borderColor = [UIColor whiteColor].CGColor;
    
    
    [super viewDidLoad];
}
- (IBAction)getStarted:(id)sender {
    
    PFObject * thisUser = [PFObject objectWithClassName:@"User"];
    NSString * uuid = [[NSUUID UUID] UUIDString];
    thisUser[@"userID"] = uuid;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:uuid forKey:@"userID"];
    [prefs synchronize];
    NSLog(@"saved the userID: %@",[prefs stringForKey:@"userID"]);
    
    [thisUser saveInBackground];
    [thisUser pinInBackground];
    
    
    PFQuery *query = [PFQuery queryWithClassName:@"RestaurantsList"];
    [query setLimit: 1000];
    [query orderByDescending:@"count"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %li restaurants.", (unsigned long)objects.count);
            // Do something with the found objects
            [PFObject pinAllInBackground:objects block:^(BOOL succeeded, NSError *error)
                {
                    if (!error)
                        {
                            [[NSNotificationCenter defaultCenter]
                             postNotificationName:@"updateRestaurants"
                             object:self];
                        }
                }];
        }
        else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    

    
}

@end

