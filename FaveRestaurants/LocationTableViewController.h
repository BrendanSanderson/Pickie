//
//  LocationViewController.h
//  Pickie
//
//  Created by Brendan Sanderson on 7/6/15.
//  Copyright (c) 2015 Brendan Sanderson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MapPoint.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface LocationTableViewController : UITableViewController < UITableViewDelegate, MKMapViewDelegate>{
}
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UIImageView *coverImage;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;
@property (strong, nonatomic) IBOutlet UILabel *numberLabel;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UILabel *websiteLabel;
@property (strong, nonatomic) IBOutlet UIButton *directionButton;
@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
- (IBAction)getDirections:(id)sender;
@property (strong, nonatomic) MapPoint *location;
@end
