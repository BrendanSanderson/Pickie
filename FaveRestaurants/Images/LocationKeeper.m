//
//  LocationKeeper.m
//  Pickie
//
//  Created by Brendan Sanderson on 7/6/15.
//  Copyright (c) 2015 Brendan Sanderson. All rights reserved.
//

#import "LocationKeeper.h"
#define kGotLocationNotification @"kGotLocationNotification"
#import "FavoritesViewController.h"
#import <Parse/Parse.h>
#import "Mappoint.h"

@implementation LocationKeeper
@synthesize currentLocation, currentCentre, annotationList, locationManager, favorites;
bool pins, changeView, firstLaunch;
+ (LocationKeeper*) sharedInstance {
    static LocationKeeper *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}


- (id) init {
    if ((self = [super init])) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.delegate = self;
        annotationList = [[NSMutableArray alloc] init];
        favorites = [[NSMutableArray alloc] init];
        [locationManager startUpdatingLocation];
        firstLaunch = true;
        pins = false;
        [self generateFavorites];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(generateFavorites) name:@"updateFavorites" object:nil];
        
    }
    return self;
}


- (void) findRestaurants
{
    [annotationList removeAllObjects];
    pins = true;
    for (PFObject *object in favorites) {
        [self queryGooglePlaces:object];
        
    }
    if ([favorites count] == 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"updateLocations" object:self];
    }
}
- (void) addAnnotations:(PFObject*) obj
{
    pins = true;
    [self queryGooglePlaces:obj];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}
-(void) queryGooglePlaces: (PFObject *) object {
    NSString * restNam = [[NSString stringWithFormat:@"%@", object[@"restaurantName"]] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSString * restNa = [restNam stringByReplacingOccurrencesOfString:@"-" withString:@"%20"];
    NSString * restN = [restNa stringByReplacingOccurrencesOfString:@"&" withString:@""];
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%@&rankBy=distance&sensor=true&name=%@&key=%@", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, [NSString stringWithFormat:@"%i", 4023], restN, kGOOGLE_API_KEY];
    NSLog(@"looking for %@", restN);
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    // Retrieve the results of the URL.
    NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
    if (data == nil)
    {
        return;
    }
    dispatch_async(kBgQueue, ^{
        if ([self fetchedData:data ojb:object]== false)
    {
        [self queryGooglePlacesDouble:object];
    }
        });
}

- (void) generateFavorites
{
    PFQuery *query = [PFQuery queryWithClassName:@"Favorites"];
    [query fromLocalDatastore];
    [query whereKey:@"UserID" equalTo:[[NSUserDefaults standardUserDefaults] stringForKey:@"userID"]];
    NSLog(@"Testing for user: %@", [[NSUserDefaults standardUserDefaults]stringForKey:@"userID"]);
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if ([favorites count] == [objects count])
            {
                [self findRestaurants];
            }
            bool noNewObjects = YES;
            int n = 0;
            PFObject *new;
            for (PFObject *fave in objects)
            {
                if (![favorites containsObject:fave])
                {
                    noNewObjects = NO;
                    n++;
                    new = fave;
                }
            }

            if (noNewObjects == YES)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                [self purgeAnnotations:objects];
                    });
            }
            else if (n==1)
            {
                favorites = [NSMutableArray arrayWithArray:objects];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self addAnnotations:new];
                });
                [[NSNotificationCenter defaultCenter] postNotificationName:@"foundFavorites" object:self];
            }
            else
            {
                favorites = [NSMutableArray arrayWithArray:objects];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"foundFavorites" object:self];
                    [self performSelectorInBackground:@selector(findRestaurants) withObject:nil];
                });
            }
        }
        else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}
- (void) purgeAnnotations:(NSArray*) objects
{
    for (PFObject *obj in favorites)
    {
        if (![objects containsObject:obj])
        {
            NSArray *temp = [NSArray arrayWithArray:annotationList];
            for (MapPoint *point in temp)
                if ([point.searchName isEqualToString:obj[@"restaurantName"]])
                {
                    [annotationList removeObject:point];
                }
        }
    }
    favorites = [NSMutableArray arrayWithArray:objects];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateLocations" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"foundFavorites" object:self];
}

-(void) queryGooglePlacesDouble: (PFObject *) object {
    NSString * restNam = [[NSString stringWithFormat:@"%@", object[@"restaurantName"]] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    NSString * restNa = [restNam stringByReplacingOccurrencesOfString:@"-" withString:@"%20"];
    NSString * restN = [restNa stringByReplacingOccurrencesOfString:@"&" withString:@""];
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%@&rankBy=distance&sensor=true&name=%@&key=%@", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude, [NSString stringWithFormat:@"%i", 10000], restN, kGOOGLE_API_KEY];
    NSLog(@"looking for %@", restN);
    NSURL *googleRequestURL=[NSURL URLWithString:url];
    
    // Retrieve the results of the URL.
    NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
    [self fetchedData:data ojb:object];
}
-(BOOL)fetchedData:(NSData *)responseData ojb:(PFObject*)object {
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
    [self plotPositions:places obj:object];

    return true;
}


- (NSString *)deviceLocation
{
    
    NSString *theLocation = [NSString stringWithFormat:@"latitude: %f longitude: %f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
    return theLocation;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    currentLocation = newLocation;
    if ([currentLocation distanceFromLocation:[[CLLocation alloc] initWithLatitude:currentCentre.coordinate.latitude longitude:currentCentre.coordinate.longitude]] >= 1609)
    {
        currentCentre = currentLocation;
        if (firstLaunch == true)
        {
            firstLaunch = false;
        }
        else
        {
            [self findRestaurants];
            pins = true;
            changeView = true;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateLocations" object:self];
        }
    }
}
-(void)plotPositions:(NSArray *)data obj:(PFObject*)object {
    int num = (int)[data count];
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
        placeObject.searchName = object[@"restaurantName"];
        [self addToAnnotationList:placeObject];
    }
  //  [self.tableView reloadData];
    dispatch_async(dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateLocations" object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"foundFavorites" object:self];
    });
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


@end