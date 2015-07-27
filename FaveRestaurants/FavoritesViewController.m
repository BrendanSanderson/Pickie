//
//  SecondViewController.m
//  FaveRestaurants
//
//  Created by Henry Sanderson on 7/6/15.
//  Copyright (c) 2015 King_B. All rights reserved.
//

#import "FavoritesViewController.h"
#import "FindOneViewController.h"

@interface FavoritesViewController ()


@end

@implementation FavoritesViewController
@synthesize table;
NSString *userID;
NSMutableArray* favorites;

- (void)viewDidLoad {
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"edit.png"];
    self.navigationItem.rightBarButtonItem.title = @"";
    favorites = [[NSMutableArray alloc] init];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    userID = [prefs stringForKey:@"userID"];
    table.backgroundColor = [[UIColor alloc]initWithRed:227.0/255.0 green:223/255.0 blue:215/255.0 alpha:1.0];

}
- (void) viewDidAppear:(BOOL)animated
{
    [self generateFavorites];
}
- (void) generateFavorites
{
    PFQuery *query = [PFQuery queryWithClassName:@"Favorites"];
    [query fromLocalDatastore];
    [query whereKey:@"UserID" equalTo:userID];
    NSLog(@"Testing for user: %@", userID);
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            // Do something with the found objects
            favorites = [NSMutableArray arrayWithArray:objects];
        }
        else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self.table reloadData];
            [self reloadRestaurants];
        });
    }];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    int numb = (int)indexPath.row;
    cell.imageView.image = [UIImage imageNamed:@"pickyBurger.png"];
    PFObject *fave = [PFObject objectWithClassName:@"Favorites"];
    fave = [favorites objectAtIndex:numb];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",fave[@"restaurantName"]];
    cell.backgroundColor = [[UIColor alloc]initWithRed:227.0/255.0 green:223/255.0 blue:215/255.0 alpha:1.0];
    return cell;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [favorites count];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIWindow *mywindow = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.window=mywindow;
    UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    FindOneViewController *findOneView=[mainstoryboard instantiateViewControllerWithIdentifier:@"FindOneViewController"];
    int numb = (int)indexPath.row;
    findOneView.favorite = [favorites objectAtIndex:numb];
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
    }
    }


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if ()
//        return UITableViewCellEditingStyleInsert;
//    else
        return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        
        [favorites removeObjectAtIndex:indexPath.row];
        
        UITableViewCell *cell = [self.table cellForRowAtIndexPath:indexPath];
        
        
        
        PFQuery *query = [PFQuery queryWithClassName:@"Favorites"];
        [query fromLocalDatastore];
        [query whereKey:@"UserID" equalTo:userID];
        [query whereKey:@"restaurantName" equalTo:cell.textLabel.text];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                for (PFObject *object in objects) {
                    [object unpinInBackground];
                }
            } else {
                // Log details of the failure
                NSLog(@"Error: %@ %@", error, [error userInfo]);
            }
        }];
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
        
        
        [self.table deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
    
    }
}
+ (NSMutableArray*) getFavorites
{
    return favorites;
}
+(void) addFavorite: (PFObject *) ojb
{
    [favorites addObject:ojb];
}
@end
