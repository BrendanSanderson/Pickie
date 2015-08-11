//
//  FindOneViewController.m
//  Pickie
//
//  Created by Brendan Sanderson on 7/6/15.
//  Copyright (c) 2015 Brendan Sanderson. All rights reserved.
//

#import "FindOneViewController.h"
#import "MapPoint.h"
#import <Parse/Parse.h>
#import "FavoritesViewController.h"
#import <CoreLocation/CoreLocation.h>
#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)
#import "LocationTableViewController.h"
#import "CellLocationView.h"

@implementation FindOneViewController
@synthesize mapView, tableView, favorite, name, noResultsLabel;
bool changeView;
MapPoint *curPoint;
NSMutableArray* annotationList;
UIImageView *loadingImage;
- (void)viewDidLoad {
    [super viewDidLoad];
    noResultsLabel.hidden = YES;
    mapView.hidden = YES;
    loadingImage = [[UIImageView alloc] initWithFrame:self.view.frame];
    loadingImage.backgroundColor = [[UIColor alloc]initWithRed:227.0/255.0 green:223.0/255.0 blue:215.0/255.0 alpha:1.0];
    [self.view addSubview:loadingImage];
    UIBarButtonItem *listButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"map_list.png"] style:UIBarButtonItemStylePlain target:self action:@selector(switchView:)];
    self.navigationItem.rightBarButtonItem = listButton;
    
    name = favorite[@"restaurantName"];
    self.title = [NSString stringWithFormat:@"Find %@", name];
    
    firstLaunch=YES;
    [mapView setRegion:MKCoordinateRegionMake([LocationKeeper sharedInstance].currentLocation.coordinate, MKCoordinateSpanMake(0.1f, 0.1f))];
    tableView.backgroundColor = [[UIColor alloc]initWithRed:227.0/255.0 green:223/255.0 blue:215/255.0 alpha:1.0];
    [self.tableView reloadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRestaurants) name:@"updateLocations" object:nil];
    tableView.hidden = YES;
    mapView.hidden = NO;
    annotationList = [[NSMutableArray alloc] init];
    [self updateRestaurants];
}

- (void) updateRestaurants
{
    [annotationList removeAllObjects];

    for (MapPoint *object in [LocationKeeper sharedInstance].annotationList)
    {
        if ([object.searchName isEqualToString:name])
        {
            [annotationList addObject:object];
        }
    }
    [tableView reloadData];
    [mapView removeAnnotations:mapView.annotations];
    [mapView addAnnotations:annotationList];
    [mapView setRegion:MKCoordinateRegionMake([LocationKeeper sharedInstance].currentLocation.coordinate, MKCoordinateSpanMake(0.1f, 0.1f))];
    if ([annotationList count] == 0)
    {
        mapView.hidden = YES;
        tableView.hidden = YES;
        noResultsLabel.hidden = NO;
        self.navigationItem.rightBarButtonItem = nil;
    }
    else if (noResultsLabel.hidden == NO)
    {
        mapView.hidden = YES;
        [self switchView];
        noResultsLabel.hidden = YES;
    }
}



- (void)viewDidAppear:(BOOL)animated
{
    loadingImage.hidden = false;
    [super viewDidAppear:true];
    [self.mapView setRegion:MKCoordinateRegionMake([LocationKeeper sharedInstance].currentLocation.coordinate, MKCoordinateSpanMake(0.1f, 0.1f)) animated:NO];
    loadingImage.hidden = true;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    // Define your reuse identifier.
    static NSString *identifier = @"MapPoint";
    
    if ([annotation isKindOfClass:[MapPoint class]]) {
        MKAnnotationView *annotationView = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        curPoint = annotation;
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.image = [UIImage imageNamed:@"pickyMapIcon.png"];
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return annotationView;
    }
    return nil;
}
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if (![view.annotation isKindOfClass:[MapPoint class]])
        return;
    UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LocationTableViewController *locationView=[mainstoryboard instantiateViewControllerWithIdentifier:@"LocationTableViewController"];
    locationView.location = view.annotation;
    [self showViewController:locationView sender:self];
    
}

#pragma mark - Table Info
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [annotationList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CellLoc";
    CellLocationView *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        cell = [[CellLocationView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    int numb = (int)indexPath.row;
    MapPoint *store =  [annotationList objectAtIndex:numb];
    //UIImageView *direction = (UIImageView *)[cell viewWithTag:3];
    //cell.detailTextLabel.text = [NSString stringWithFormat:@"%f", store.distance];
    //cell.textLabel.text = store.name;
    cell.distanceLabel.text = [NSString stringWithFormat:@"%.2f mi", store.distance];
    cell.directionLabel.text = [NSString stringWithFormat:@"%@", store.direction];
    cell.textLabel.text = [NSString stringWithFormat:@"%@",store.name];
    cell.addressLabel.text = store.address;
    cell.imageView.image = [UIImage imageNamed:@"pickyBurger.png"];
    cell.backgroundColor = [[UIColor alloc]initWithRed:227.0/255.0 green:223/255.0 blue:215/255.0 alpha:1.0];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIWindow *mywindow = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.window=mywindow;
    UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    LocationTableViewController *locationView=[mainstoryboard instantiateViewControllerWithIdentifier:@"LocationViewController"];
    int numb = (int)indexPath.row;
    MapPoint *store =  [annotationList objectAtIndex:numb];
    locationView.location =store;
    [self showViewController:locationView sender:self];
}

- (IBAction)switchView:(id)sender {
    [self switchView];
}

-(void) switchView
{
    if (tableView.hidden == true) {
        mapView.hidden = true;
        tableView.hidden = false;
        [self.tableView reloadData];
        UIBarButtonItem *mapButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"map_map.png"] style:UIBarButtonItemStylePlain target:self action:@selector(switchView:)];
        self.navigationItem.rightBarButtonItem = mapButton;
    }
    else
    {
        mapView.hidden = false;
        tableView.hidden = true;
        UIBarButtonItem *listButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"map_list.png"] style:UIBarButtonItemStylePlain target:self action:@selector(switchView:)];
        self.navigationItem.rightBarButtonItem = listButton;
    }
}
@end