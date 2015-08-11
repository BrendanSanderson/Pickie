//
//  FindViewController.h
//  Pickie
//
//  Created by Brendan Sanderson on 7/6/15.
//  Copyright (c) 2015 Brendan Sanderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)


@interface FindViewController : UIViewController <MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate> {
    BOOL firstLaunch;
}
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
- (IBAction)switchView:(id)sender;
- (IBAction)FindMyLocation:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *noResultsLabel;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) IBOutlet UITableView* tableView;
@end