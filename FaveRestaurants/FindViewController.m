//
//  SecondViewController.m
//  FaveRestaurant
//
//  Created by Lee Anne Sanderson on 6/15/15.
//  Copyright (c) 2015 Brendan. All rights reserved.
//

#import "FindViewController.h"
#import "MapPoint.h"
#import <Parse/Parse.h>
#import "FavoritesViewController.h"
#import <CoreLocation/CoreLocation.h>
#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)
#import "LocationViewController.h"
#import "CellLocationView.h"

@implementation FindViewController
@synthesize mapView, locationManager, favorites, tableView;
bool pins, changeView;
MapPoint *curPoint;
NSMutableArray* annotationList;
UIImageView *loadingImage;
- (void)viewDidLoad {
    [super viewDidLoad];
    mapView.hidden = true;
    loadingImage = [[UIImageView alloc] initWithFrame:self.view.frame];
    loadingImage.backgroundColor = [[UIColor alloc]initWithRed:101.0/255.0 green:132.0/255.0 blue:158.0/255.0 alpha:1.0];
    [self.view addSubview:loadingImage];
    
    annotationList = [[NSMutableArray alloc] init];
    self.locationManager = [[CLLocationManager alloc] init];
    changeView = true;
    if (favorites != [FavoritesViewController getFavorites])
    {
        pins = false;
        favorites = [FavoritesViewController getFavorites];
        [annotationList removeAllObjects];
        [self.locationManager startUpdatingLocation];
        [self.tableView reloadData];
    }
    geocoder = [[CLGeocoder alloc] init];
    self.locationManager.delegate = self;
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [self.locationManager requestAlwaysAuthorization];
        
    }
    firstLaunch=YES;
    [locationManager startUpdatingLocation];
    [mapView setRegion:MKCoordinateRegionMake(currentLocation.coordinate, MKCoordinateSpanMake(0.1f, 0.1f))];
    currentCentre = currentLocation.coordinate;
    tableView.backgroundColor = [[UIColor alloc]initWithRed:227.0/255.0 green:223/255.0 blue:215/255.0 alpha:1.0];
    [self.tableView reloadData];
    tableView.hidden = true;
    mapView.hidden = false;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    loadingImage.hidden = false;
    if (favorites != [FavoritesViewController getFavorites])
    {
        pins = false;
        [annotationList removeAllObjects];
        [self.locationManager startUpdatingLocation];
        [self.tableView reloadData];
    }
    [super viewDidAppear:true];
    [self.mapView setRegion:MKCoordinateRegionMake(currentLocation.coordinate, MKCoordinateSpanMake(0.1f, 0.1f)) animated:YES];
    loadingImage.hidden = true;
}


- (void) generateFavorites
{
    favorites = [FavoritesViewController getFavorites];
    [self.mapView removeAnnotations:[self.mapView annotations]];
    for (PFObject *object in favorites) {
        [self queryGooglePlaces:[NSString stringWithFormat:@"%@", object[@"restaurantName"]]];
    }
    pins = true;
}



//-(void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views {
//    //Zoom back to the user location after adding a new set of annotations.
//    //Get the center point of the visible map.
//    CLLocationCoordinate2D centre = [mv centerCoordinate];
//    MKCoordinateRegion region;
//    //If this is the first launch of the app, then set the center point of the map to the user's location.
//    if (firstLaunch) {
//        region = MKCoordinateRegionMakeWithDistance(locationManager.location.coordinate,1000,1000);
//        firstLaunch=NO;
//    }else {
//        //Set the center point to the visible region of the map and change the radius to match the search radius passed to the Google query string.
//        region = MKCoordinateRegionMakeWithDistance(centre,currenDist,currenDist);
//    }
//    //Set the visible region of the map.
//    [mv setRegion:region animated:YES];
//}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [self.locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    currentLocation = newLocation;
    NSLog(@"%@", currentLocation);
    
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) { 
        
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
            
//            NSLog(@"Country: %@", placemark.country);
//            NSLog(@"Area: %@", placemark.administrativeArea);
//            NSLog(@"City: %@", placemark.locality);
//            NSLog(@"Code: %@", placemark.postalCode);
            NSLog(@"Road: %@", placemark.thoroughfare);
            NSLog(@"Number: %@", placemark.subThoroughfare);
            
            // Stop Location Manager
            [self.locationManager stopUpdatingLocation];
            
        } else {
            NSLog(@"%@", error.debugDescription);
            [self.locationManager stopUpdatingLocation];
            
        }
    }];
    if ([currentLocation distanceFromLocation:[[CLLocation alloc] initWithLatitude:currentCentre.latitude longitude:currentCentre.longitude]] >= 1609)
    {
        pins = false;
        [self.mapView setRegion:MKCoordinateRegionMake(currentLocation.coordinate, MKCoordinateSpanMake(0.1f, 0.1f)) animated:YES];
    }
    if (pins == false)
    {
        
        currentCentre = currentLocation.coordinate;
       [self generateFavorites];
        pins = true;
        changeView = true;
    }
    
}

-(void) queryGooglePlaces: (NSString *) restName {
    NSString * restNam = [restName stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSString * restNa = [restNam stringByReplacingOccurrencesOfString:@"-" withString:@"%20"];
    NSString * restN = [restNa stringByReplacingOccurrencesOfString:@"&" withString:@""];
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%@&rankBy=distance&sensor=true&name=%@&key=%@", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, [NSString stringWithFormat:@"%i", 4023], restN, kGOOGLE_API_KEY];
    NSLog(@"looking for %@", restN);
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    // Retrieve the results of the URL.
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
    if ([self fetchedData:data]== false)
        {
            [self queryGooglePlacesDouble:(NSString *) restName];
        }
}

-(void) queryGooglePlacesDouble: (NSString *) restName {
    NSString * restNam = [restName stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSString * restNa = [restNam stringByReplacingOccurrencesOfString:@"-" withString:@"%20"];
     NSString * restN = [restNa stringByReplacingOccurrencesOfString:@"&" withString:@""];
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%@&rankBy=distance&sensor=true&name=%@&key=%@", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, [NSString stringWithFormat:@"%i", 10000], restN, kGOOGLE_API_KEY];
    NSLog(@"looking for %@", restN);
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    // Retrieve the results of the URL.
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
}
-(BOOL)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    NSArray* places = [json objectForKey:@"results"];
    //Write out the data to the console.
    if ([places count] == 0)
         {
              return false;
         }
    NSLog(@"Retreived %lu restaurants", (unsigned long)places.count);
    [self plotPositions:places];
    return true;
}


-(void)plotPositions:(NSArray *)data {
    int num = (int)[data count];
//    if (num > 5)
//    {
//        num = 5;
//    }
    if ([data count] == 0)
    {
        
    }
    for (int i=0; i<num; i++) {
        NSDictionary* place = [data objectAtIndex:i];
        
        NSDictionary *geo = [place objectForKey:@"geometry"];
        
        NSDictionary *loc = [geo objectForKey:@"location"];
        
        NSString *name=[place objectForKey:@"name"];
        
        NSString *vicinity=[place objectForKey:@"vicinity"];
        
        NSDictionary *photoDict = [[place objectForKey:@"photos"] objectAtIndex:0];
        NSString *photoRef = [photoDict objectForKey:@"photo_reference"];
        CLLocationCoordinate2D placeCoord;
        
        placeCoord.latitude=[[loc objectForKey:@"lat"] doubleValue];
        
        placeCoord.longitude=[[loc objectForKey:@"lng"] doubleValue];
        
        MapPoint *placeObject = [[MapPoint alloc] initWithName:name address:vicinity coordinate:placeCoord];
        placeObject.pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?photoreference=%@&key=%@&sensor=false&maxwidth=320", photoRef, kGOOGLE_API_KEY]];
        placeObject.distance = [currentLocation distanceFromLocation:[[CLLocation alloc] initWithLatitude:placeObject.coordinate.latitude longitude:placeObject.coordinate.longitude]];
        placeObject.distance= (placeObject.distance * 0.000621371);
//        placeObject.distance = floorf(dist * 100 + 0.5) / 100;
        placeObject.direction = [self getHeadingForDirectionFromCoordinate:currentLocation.coordinate toCoordinate:placeObject.coordinate];
        placeObject.description = [NSString stringWithFormat:@"%@  %.2f mi %@", [vicinity substringToIndex:[vicinity rangeOfString:@","].location], placeObject.distance, placeObject.direction];
        placeObject.placeID = [place objectForKey:@"place_id"];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [mapView addAnnotation:placeObject];
            
            [self addToAnnotationList:placeObject];
        });
    }
    [self.tableView reloadData];
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
    LocationViewController *locationView=[mainstoryboard instantiateViewControllerWithIdentifier:@"LocationViewController"];
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
    
    LocationViewController *locationView=[mainstoryboard instantiateViewControllerWithIdentifier:@"LocationViewController"];
    int numb = (int)indexPath.row;
    MapPoint *store =  [annotationList objectAtIndex:numb];
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
    [self.mapView setRegion:MKCoordinateRegionMake(currentLocation.coordinate, MKCoordinateSpanMake(0.1f, 0.1f)) animated:YES];
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