//
//  SecondViewController.h
//  FaveRestaurants
//
//  Created by Henry Sanderson on 7/6/15.
//  Copyright (c) 2015 King_B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FavoritesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) UIWindow *window;
- (void) generateFavorites;
+ (NSMutableArray*) getFavorites;
+(void) addFavorite: (PFObject *) ojb;
@end

