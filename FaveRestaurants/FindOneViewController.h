//
//  FindOneViewController.h
//  Pickie
//
//  Created by Brendan Sanderson on 7/6/15.
//  Copyright (c) 2015 Brendan Sanderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#import "LocationKeeper.h"


@interface FindOneViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate> {
    BOOL firstLaunch;
}
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
- (IBAction)switchView:(id)sender;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) PFObject* favorite;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) IBOutlet UITableView* tableView;
@property (strong, nonatomic) IBOutlet UILabel *noResultsLabel;
@end