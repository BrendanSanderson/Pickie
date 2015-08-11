//
//  FavoritesViewController.m
//  Pickie
//
//  Created by Brendan Sanderson on 7/6/15.
//  Copyright (c) 2015 Brendan Sanderson. All rights reserved.
//

#import "FavoritesViewController.h"
#import "FindOneViewController.h"
#import "LocationKeeper.h"
#import "CellFavoriteView.h"
#import "SearchViewController.h"

@interface FavoritesViewController ()


@end

@implementation FavoritesViewController
@synthesize table;
NSString *userID;

- (void)viewDidLoad {
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"edit.png"];
    self.navigationItem.rightBarButtonItem.title = @"";
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    userID = [prefs stringForKey:@"userID"];
    table.backgroundColor = [[UIColor alloc]initWithRed:227.0/255.0 green:223/255.0 blue:215/255.0 alpha:1.0];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
            [[LocationKeeper sharedInstance].locationManager requestAlwaysAuthorization];
            
        }
    [LocationKeeper sharedInstance];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFaves) name:@"foundFavorites" object:nil];
    [self reloadRestaurants];
}
- (void) updateFaves
{
    [table reloadData];
}

- (void) reloadRestaurants
{
    PFQuery *query = [PFQuery queryWithClassName:@"Restaurants"];
    [query setLimit: 1000];
    [query fromLocalDatastore];
    [query orderByDescending:@"count"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objectsPinned, NSError *error) {
        if (!error) {
            // The find succeeded.
            [PFObject fetchAllInBackground:objectsPinned];
            PFQuery *query = [PFQuery queryWithClassName:@"Restaurants"];
            [query orderByDescending:@"count"];
            [query setLimit: 1000];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    if ([objects count] > [objectsPinned count])
                    {
                        [PFObject unpinAll:objectsPinned];
                        [PFObject pinAll:objects];}
                }
                
            }];
            // Do something with the found objects
        }
        else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CellLocationView *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"FaveCell";
    CellLocationView *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[CellLocationView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    int numb = (int)indexPath.row;
    cell.directionLabel.hidden = NO;
    cell.distanceLabel.hidden = NO;
    cell.backgroundColor = [[UIColor alloc]initWithRed:227.0/255.0 green:223/255.0 blue:215/255.0 alpha:1.0];
    if (numb == [[LocationKeeper sharedInstance].favorites count])
    {
        cell.imageView.image = nil;
        if (numb == 0)
        {
            cell.textLabel.text = @"You have no favorites! Click to add one!";
            cell.textLabel.font = [cell.textLabel.font fontWithSize:12];
            cell.directionLabel.text= @"";
            cell.distanceLabel.text = @"";
        }
        else{
            if ([[LocationKeeper sharedInstance].annotationList count] == 0)
            {
                cell.textLabel.text = @"No restaurants were found, tap to try again.";
                cell.textLabel.font = [cell.textLabel.font fontWithSize:12];
                cell.directionLabel.text= @"";
                cell.distanceLabel.text = @"";
            }
            else{
            cell.textLabel.text = @"You have no more favorites! Click to add one!";
            cell.textLabel.font = [cell.textLabel.font fontWithSize:12];
            cell.directionLabel.text= @"";
            cell.distanceLabel.text = @"";
            }
        }
        return cell;
    }
    
    cell.textLabel.font = [cell.textLabel.font fontWithSize:16];
    cell.imageView.image = [UIImage imageNamed:@"pickyBurger.png"];
    PFObject *fave = [PFObject objectWithClassName:@"Favorites"];
    fave = [[LocationKeeper sharedInstance].favorites objectAtIndex:numb];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",fave[@"restaurantName"]];
    if([tableView isEditing] == NO)
    {
    if ([[LocationKeeper sharedInstance].annotationList count] >0)
    {
        MapPoint *loc = [self getClosestLocation:fave[@"restaurantName"]];
        if (loc.name != nil)
        {
        cell.directionLabel.text = loc.direction;
        cell.distanceLabel.text = [NSString stringWithFormat:@"%.2f mi",loc.distance];
        }
        else{
            cell.directionLabel.text = @"-";
            cell.distanceLabel.text = [NSString stringWithFormat:@"-- mi"];
        }
    }
    else
    {
        cell.directionLabel.text = @"-";
        cell.distanceLabel.text = [NSString stringWithFormat:@"-- mi"];
    }
    }
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == [[LocationKeeper sharedInstance].favorites count]) {
        return NO;
    }
    
    return YES;
    
}

- (MapPoint *) getClosestLocation: (NSString*) name
{
    for ( MapPoint* point in [LocationKeeper sharedInstance].annotationList)
    {
       if ([point.searchName isEqualToString:name])
       {
           return point;
       }
    }
    return nil;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return ([[LocationKeeper sharedInstance].favorites count]+1);
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIWindow *mywindow = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.window=mywindow;
    UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    int numb = (int)indexPath.row;
    if (numb == [[LocationKeeper sharedInstance].favorites count])
    {
        if ([[tableView cellForRowAtIndexPath:indexPath].textLabel.text isEqualToString:@"No restaurants were found, tap to try again."])
            {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFavorites" object:self];
            return;
            }
        SearchViewController *searchView =[mainstoryboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
        [self showViewController:searchView sender:self];
        return;
    }
    
    FindOneViewController *findOneView=[mainstoryboard instantiateViewControllerWithIdentifier:@"FindOneViewController"];
    findOneView.favorite = [[LocationKeeper sharedInstance].favorites objectAtIndex:numb];
    findOneView.name = findOneView.favorite[@"name"];
    [self showViewController:findOneView sender:self];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.table setEditing:editing animated:YES];
    
    //Do not let the user add if the app is in edit mode.
    if(editing){
        self.navigationItem.leftBarButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"check.png"];
        self.navigationItem.rightBarButtonItem.title = nil;
  }

    else{
        self.navigationItem.leftBarButtonItem.enabled = YES;
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"edit.png"];
        self.navigationItem.rightBarButtonItem.title = nil;
        [self.table reloadData];
    }
    }


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        
        
        UITableViewCell *cell = [self.table cellForRowAtIndexPath:indexPath];
        
        
        
        PFQuery *query = [PFQuery queryWithClassName:@"Favorites"];
        [query fromLocalDatastore];
        [query whereKey:@"UserID" equalTo:userID];
        [query whereKey:@"restaurantName" equalTo:cell.textLabel.text];
        [[query getFirstObject] unpin];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFavorites" object:self];
        PFQuery *query2 = [PFQuery queryWithClassName:@"Favorites"];
        [query2 whereKey:@"UserID" equalTo:userID];
        [query2 whereKey:@"restaurantName" equalTo:cell.textLabel.text];
        [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                for (PFObject *object in objects) {
                    [object deleteInBackground];
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
        //[self.table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
@end
