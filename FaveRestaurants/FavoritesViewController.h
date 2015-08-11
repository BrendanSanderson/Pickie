//
//  FavoritesViewController.h
//  Pickie
//
//  Created by Brendan Sanderson on 7/6/15.
//  Copyright (c) 2015 Brendan Sanderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FavoritesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) UIWindow *window;
@end

