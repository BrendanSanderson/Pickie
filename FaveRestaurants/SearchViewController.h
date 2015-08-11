//
//  SearchViewController.h
//  Pickie
//
//  Created by Brendan Sanderson on 7/6/15.
//  Copyright (c) 2015 Brendan Sanderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "FavoritesViewController.h"

@interface SearchViewController : UITableViewController <UISearchDisplayDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate>
//@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) UIWindow *window;
@property (strong, nonatomic) UISearchController *searchController;
@property BOOL searchControllerWasActive;
@property BOOL searchControllerSearchFieldWasFirstResponder;
@property (nonatomic, strong) NSMutableArray *searchResults;
@property (weak, nonatomic) IBOutlet UITableView *table;


@end