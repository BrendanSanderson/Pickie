//
//  FindViewController.h
//  FaveResturants
//
//  Created by Lee Anne Sanderson on 6/15/15.
//  Copyright (c) 2015 Brendan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define kGOOGLE_API_KEY @"AIzaSyDytEJD4kUrUP5AqlDxqszBZwYSTmoqGdY"


@interface FindOneViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate> {
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLLocation *currentLocation;
    CLPlacemark *placemark;
    CLLocationCoordinate2D currentCentre;
    int currenDist;
    BOOL firstLaunch;
}
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
- (IBAction)switchView:(id)sender;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) PFObject* favorite;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) IBOutlet UITableView* tableView;
@end