//
//  UITableViewController+SearchViewController.m
//  FaveRestaurants
//
//  Created by Henry Sanderson on 7/8/15.
//  Copyright (c) 2015 King_B. All rights reserved.
//

#import "SearchViewController.h"
#import <Parse/Parse.h>
#import <CoreFoundation/CoreFoundation.h>


@implementation SearchViewController
@synthesize searchResults, table;
NSMutableArray *restaurantList;
NSString *userID;
NSMutableArray *faves;
- (void) viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = nil;
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    [self.searchController.searchBar sizeToFit];
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO; // default is YES
    self.searchController.searchBar.delegate = self;
    self.definesPresentationContext = YES;
    searchResults = [[NSMutableArray alloc] init];
    faves = [FavoritesViewController getFavorites];
    self.tableView.backgroundColor = [[UIColor alloc]initWithRed:227.0/255.0 green:223/255.0 blue:215/255.0 alpha:1.0];
    restaurantList = [[NSMutableArray alloc] init];
    [self updateRestaurants];



}
- (void) updateRestaurants
{
    PFQuery *query = [PFQuery queryWithClassName:@"Restaurants"];
    [query setLimit: 1000];
    [query fromLocalDatastore];
    [query orderByDescending:@"count"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully added %lu restaurants to search.", (unsigned long)objects.count);
            // Do something with the found objects
            [restaurantList removeAllObjects];
            [restaurantList addObjectsFromArray:objects];
            dispatch_async(dispatch_get_main_queue(), ^ {
                [self.tableView reloadData];
            });
        }
    }];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // restore the searchController's active state
    if (self.searchControllerWasActive) {
        self.searchController.active = self.searchControllerWasActive;
        _searchControllerWasActive = NO;
        
        if (self.searchControllerSearchFieldWasFirstResponder) {
            [self.searchController.searchBar becomeFirstResponder];
            _searchControllerSearchFieldWasFirstResponder = NO;
        }
    }

}

 - (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
                [searchBar resignFirstResponder];
 }
     
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
         // update the filtered array based on the search text
         NSString *searchText = searchController.searchBar.text;
         searchResults = [restaurantList mutableCopy];
         
         // strip out all the leading and trailing spaces
         NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
         
         // break up the search terms (separated by spaces)
         NSArray *searchItems = nil;
         if (strippedString.length > 0) {
             searchItems = [strippedString componentsSeparatedByString:@" "];
         }
         
         NSMutableArray *andMatchPredicates = [NSMutableArray array];
         
         for (NSString *searchString in searchItems) {
             NSExpression *lhs = [NSExpression expressionForKeyPath:@"name"];
             NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
             NSPredicate *finalPredicate = [NSComparisonPredicate
                                            predicateWithLeftExpression:lhs
                                            rightExpression:rhs
                                            modifier:NSDirectPredicateModifier
                                            type:NSContainsPredicateOperatorType
                                            options:NSCaseInsensitivePredicateOption];
             [andMatchPredicates addObject:finalPredicate];
         }
    
         NSCompoundPredicate *finalCompoundPredicate =
        [NSCompoundPredicate andPredicateWithSubpredicates:andMatchPredicates];
        searchResults = (NSMutableArray*)[searchResults filteredArrayUsingPredicate:finalCompoundPredicate];
        [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchController.active)
    {
        return [searchResults count];
    }
    else
    {
        return [restaurantList count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *kCellID = @"CellIdentifier";
    
    // Dequeue a cell from self's table view.
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID];
    }
    /*
     If the requesting table view is the search display controller's table view, configure the cell using the search results array, otherwise use the product array.
     */
    PFObject *rest;
    if (self.searchController.active)
    {
        rest = [searchResults objectAtIndex:indexPath.row];
    }
    else
    {
        rest = [restaurantList objectAtIndex:indexPath.row];
    }
    cell.backgroundColor = [[UIColor alloc]initWithRed:227.0/255.0 green:223/255.0 blue:215/255.0 alpha:1.0];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", rest[@"name"]];
    cell.imageView.image = [UIImage imageNamed:@"pickyBurger.png"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell = [tableView cellForRowAtIndexPath:indexPath];
    PFObject * favorite = [PFObject objectWithClassName:@"Favorites"];
    favorite[@"restaurantName"] = cell.textLabel.text;
    BOOL alreadyAdded = false;
    for (int i = 0; i<faves.count;i++)
    {
        PFObject *object = [faves objectAtIndex:i];
        if ([object[@"restaurantName"] isEqualToString:favorite[@"restaurantName"]])
            {
                alreadyAdded = true;
            }
    }
    if (alreadyAdded == false)
    {
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        favorite[@"UserID"] = [prefs stringForKey:@"userID"];
        [favorite saveInBackground];
        [favorite pin];
    }
    
    UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *loginvc=[mainstoryboard instantiateViewControllerWithIdentifier:@"MainTabBarController"];
    [self presentViewController:loginvc animated:NO completion:nil];
}



NSString *const ViewControllerTitleKey = @"ViewControllerTitleKey";
NSString *const SearchControllerIsActiveKey = @"SearchControllerIsActiveKey";
NSString *const SearchBarTextKey = @"SearchBarTextKey";
NSString *const SearchBarIsFirstResponderKey = @"SearchBarIsFirstResponderKey";

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    [super encodeRestorableStateWithCoder:coder];
    
    // encode the view state so it can be restored later
    
    // encode the title
    [coder encodeObject:self.title forKey:ViewControllerTitleKey];
    
    UISearchController *searchController = self.searchController;
    
    // encode the search controller's active state
    BOOL searchDisplayControllerIsActive = searchController.isActive;
    [coder encodeBool:searchDisplayControllerIsActive forKey:SearchControllerIsActiveKey];
    
    // encode the first responser status
    if (searchDisplayControllerIsActive) {
        [coder encodeBool:[searchController.searchBar isFirstResponder] forKey:SearchBarIsFirstResponderKey];
    }
    
    // encode the search bar text
    [coder encodeObject:searchController.searchBar.text forKey:SearchBarTextKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    [super decodeRestorableStateWithCoder:coder];
    
    // restore the title
    self.title = [coder decodeObjectForKey:ViewControllerTitleKey];
    
    // restore the active state:
    // we can't make the searchController active here since it's not part of the view
    // hierarchy yet, instead we do it in viewWillAppear
    //
    _searchControllerWasActive = [coder decodeBoolForKey:SearchControllerIsActiveKey];
    
    // restore the first responder status:
    // we can't make the searchController first responder here since it's not part of the view
    // hierarchy yet, instead we do it in viewWillAppear
    //
    _searchControllerSearchFieldWasFirstResponder = [coder decodeBoolForKey:SearchBarIsFirstResponderKey];
    
    // restore the text in the search field
    self.searchController.searchBar.text = [coder decodeObjectForKey:SearchBarTextKey];
}



@end
