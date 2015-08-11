//
//  LocationKeeper.h
//  Pickie
//
//  Created by Brendan Sanderson on 7/6/15.
//  Copyright (c) 2015 Brendan Sanderson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#define kGOOGLE_API_KEY @"AIzaSyDytEJD4kUrUP5AqlDxqszBZwYSTmoqGdY"
#define degreesToRadians(x) (M_PI * x / 180.0)
#define radiandsToDegrees(x) (x * 180.0 / M_PI)
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#import "FavoritesViewController.h"
#import <Parse/Parse.h>
#import "Mappoint.h"
@interface LocationKeeper : NSObject <CLLocationManagerDelegate>

+ (LocationKeeper*) sharedInstance;

@property (nonatomic, readonly) CLLocation *currentLocation;
@property (nonatomic, readonly) CLLocation *currentCentre;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, readonly) NSMutableArray *annotationList;
@property (nonatomic, readonly) NSMutableArray *favorites;

- (NSString *)deviceLocation;
@end