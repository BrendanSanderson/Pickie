//
//  UIViewController+WelcomeViewController.h
//  FaveRestaurants
//
//  Created by Henry Sanderson on 7/7/15.
//  Copyright (c) 2015 King_B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#define kGOOGLE_API_KEY @"AIzaSyDytEJD4kUrUP5AqlDxqszBZwYSTmoqGdY"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface WelcomeViewController : UIViewController
- (IBAction)getStarted:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *PickyLabel;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;



@end