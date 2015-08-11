//
//  FindViewController.m
//  Pickie
//
//  Created by Brendan Sanderson on 7/6/15.
//  Copyright (c) 2015 Brendan Sanderson. All rights reserved.
//

#import "FindViewController.h"
#import "MapPoint.h"
#import <Parse/Parse.h>
#import "FavoritesViewController.h"
#import <CoreLocation/CoreLocation.h>
#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)
#import "LocationViewController.h"
#import "LocationTableViewController.h"
#import "CellLocationView.h"
#import "LocationKeeper.h"

@implementation FindViewController
@synthesize mapView, tableView, noResultsLabel;
bool changeView;
MapPoint *curPoint;
NSMutableArray* annotationList;
UIImageView *loadingImage;
- (void)viewDidLoad {
    [super viewDidLoad];
    noResultsLabel.hidden = YES;
    mapView.hidden = true;
    loadingImage = [[UIImageView alloc] initWithFrame:self.view.frame];
    loadingImage.backgroundColor = [[UIColor alloc]initWithRed:227.0/255.0 green:223.0/255.0 blue:215.0/255.0 alpha:1.0];
    [self.view addSubview:loadingImage];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight ;
    changeView = true;
    firstLaunch=YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRestaurants) name:@"updateLocations" object:nil];
    tableView.backgroundColor = [[UIColor alloc]initWithRed:227.0/255.0 green:223.0/255.0 blue:215.0/255.0 alpha:1.0];
    tableView.hidden = true;
    mapView.hidden = false;
    [self updateRestaurants];
    [mapView setRegion:MKCoordinateRegionMake([LocationKeeper sharedInstance].currentLocation.coordinate, MKCoordinateSpanMake(0.1f, 0.1f))];
    
}

- (void) updateRestaurants
{
    [mapView removeAnnotations:mapView.annotations];
    if ([[LocationKeeper sharedInstance].annotationList count] == 0)
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
    [mapView addAnnotations:[LocationKeeper sharedInstance].annotationList];
    [mapView setRegion:MKCoordinateRegionMake([LocationKeeper sharedInstance].currentLocation.coordinate, MKCoordinateSpanMake(0.1f, 0.1f))];
    [tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    loadingImage.hidden = false;
    [super viewDidAppear:true];
    [mapView setRegion:MKCoordinateRegionMake([LocationKeeper sharedInstance].currentLocation.coordinate, MKCoordinateSpanMake(0.1f, 0.1f))];
    loadingImage.hidden = true;
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
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
-(void) presentMoreInfo: (MapPoint*)annotation
{
    UIWindow *mywindow = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.window=mywindow;
    UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LocationViewController *locationView=[mainstoryboard instantiateViewControllerWithIdentifier:@"LocationViewController"];
    locationView.location =curPoint;
    [self showViewController:locationView sender:self];
}

#pragma mark - Table Info
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [[LocationKeeper sharedInstance].annotationList count];
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
    MapPoint *store =  [[LocationKeeper sharedInstance].annotationList objectAtIndex:numb];
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
    
    LocationTableViewController *locationView=[mainstoryboard instantiateViewControllerWithIdentifier:@"LocationTableViewController"];
    int numb = (int)indexPath.row;
    MapPoint *store =  [[LocationKeeper sharedInstance].annotationList objectAtIndex:numb];
    locationView.location =store;
    [self showViewController:locationView sender:self];
}


- (void) addToAnnotationList:(MapPoint *) mP
{
    CLLocationDistance mPDist= mP.distance;
    BOOL added = NO;
    int count = (int)annotationList.count;
    for (int i = 0; i <count; i++)
    {
        MapPoint* annotation = [annotationList objectAtIndex:i];
        if (mPDist < annotation.distance && added == NO)
        {
            [annotationList insertObject:mP atIndex:i];
            added = YES;
        }
    }
    if (added == NO)
    {
    [annotationList addObject:mP];
    }
}

- (NSString*)getHeadingForDirectionFromCoordinate:(CLLocationCoordinate2D)fromLoc toCoordinate:(CLLocationCoordinate2D)toLoc
{
    float fLat = degreesToRadians(fromLoc.latitude);
    float fLng = degreesToRadians(fromLoc.longitude);
    float tLat = degreesToRadians(toLoc.latitude);
    float tLng = degreesToRadians(toLoc.longitude);
    
    float degree = radiandsToDegrees(atan2(sin(tLng-fLng)*cos(tLat), cos(fLat)*sin(tLat)-sin(fLat)*cos(tLat)*cos(tLng-fLng)));
    
    if (degree >= 0) {
    }
    else {
        degree = 360+degree;
    }
    if (0.0<=degree && degree<=22.5)
    {
        return @"N";
    }
    else if (347.5<=degree && degree<=360.0)
    {
        return @"N";
    }
    else if (22.5<=degree && degree<67.5)
    {
        return @"NE";
    }
    else if (67.5<=degree && degree<=112.5)
    {
        return @"E";
    }
    else if (112.5<=degree && degree<=157.5)
    {
        return @"SE";
    }
    else if (157.5<=degree && degree<=202.5)
    {
        return @"S";
    }
    else if (202.5<=degree && degree<=247.5)
    {
        return @"SW";
    }
    else if (247.5<=degree && degree<=302.5)
    {
        return @"W";
    }
    else
    {
        return @"NW";
    }
}

- (IBAction)switchView:(id)sender {
    [self switchView];
}

- (IBAction)FindMyLocation:(id)sender {
    [self.mapView setRegion:MKCoordinateRegionMake([LocationKeeper sharedInstance].currentLocation.coordinate, MKCoordinateSpanMake(0.1f, 0.1f)) animated:YES];
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