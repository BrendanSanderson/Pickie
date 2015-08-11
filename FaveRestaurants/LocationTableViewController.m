//
//  LocationViewController.m
//  Pickie
//
//  Created by Brendan Sanderson on 7/6/15.
//  Copyright (c) 2015 Brendan Sanderson. All rights reserved.
//

#import "LocationTableViewController.h"
#import <Parse/Parse.h>
#import "MapPoint.h"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)


@implementation LocationTableViewController
@synthesize location, addressLabel, distanceLabel, mapView, directionButton, coverImage, titleLabel, numberLabel, websiteLabel;
UIImageView *loadingImage;
- (void)viewDidLoad {
    loadingImage = [[UIImageView alloc] initWithFrame:self.view.frame];
    loadingImage.backgroundColor = [[UIColor alloc]initWithRed:227.0/255.0 green:223/255.0 blue:215/255.0 alpha:1.0];
    [self.view addSubview:loadingImage];
    UITapGestureRecognizer *call = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(call)];
    [numberLabel addGestureRecognizer:call];
    numberLabel.userInteractionEnabled = true;
    UITapGestureRecognizer *openWebsite = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openWebsite)];
    [websiteLabel addGestureRecognizer:openWebsite];
    websiteLabel.userInteractionEnabled = true;
    self.view.backgroundColor = [[UIColor alloc]initWithRed:227.0/255.0 green:223/255.0 blue:215/255.0 alpha:1.0];
    [super viewDidLoad];
    
}   
-(void) viewDidAppear:(BOOL)animated
{
    loadingImage.hidden = false;
    dispatch_async(kBgQueue, ^{
        NSURL *detailsURL= [NSURL URLWithString:[NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?placeid=%@&key=AIzaSyDytEJD4kUrUP5AqlDxqszBZwYSTmoqGdY", location.placeID]];
        NSData* data = [NSData dataWithContentsOfURL: detailsURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });
    
    
    self.title = location.name;
    titleLabel.text = location.name;
    addressLabel.text = location.address;
    distanceLabel.text = [NSString stringWithFormat:@"Location: %.2f mi  %@", location.distance, location.direction];
    coverImage.image = [UIImage imageWithData:[[NSData alloc] initWithContentsOfURL: location.pictureURL]];
    [mapView removeAnnotations:[mapView annotations]];
    [mapView addAnnotation:location];
    [mapView setRegion:MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.01f, 0.01f)) animated:NO];
    [super viewDidAppear:animated];
    loadingImage.hidden = true;
}
-(void)fetchedData:(NSData *)responseData {
    NSError *error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          
                          options:kNilOptions
                          error:&error];
    NSDictionary* place = [json objectForKey:@"result"];
    numberLabel.text = [place objectForKey:@"formatted_phone_number"];
    websiteLabel.text = [place objectForKey:@"website"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    // Define your reuse identifier.
    static NSString *identifier = @"MapPoint";
    
    if ([annotation isKindOfClass:[MapPoint class]]) {
        MKAnnotationView *annotationView = (MKAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.image = [UIImage imageNamed:@"pickyMapIcon.png"];
        annotationView.enabled = YES;
        
        return annotationView;
    }
    return nil;
}

- (void) call
{
    NSString *phoneNum = [[numberLabel.text componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    NSString *phoneNumber = [[NSString alloc] initWithFormat:@"tel://%@", phoneNum];
    NSURL *phoneURL = [[NSURL alloc] initWithString:phoneNumber];
    if ([[UIApplication sharedApplication] canOpenURL:phoneURL]) {
        [[UIApplication sharedApplication] openURL:phoneURL];
    } else
    {
        NSLog(@"calling num");
    }
}
- (void) openWebsite
{
    NSURL *phoneURL = [[NSURL alloc] initWithString:websiteLabel.text];
    if ([[UIApplication sharedApplication] canOpenURL:phoneURL]) {
        [[UIApplication sharedApplication] openURL:phoneURL];
    } else
    {
        NSLog(@"opening website");
    }
}

- (IBAction)getDirections:(id)sender {
    //    NSString *urlString = [[NSString alloc] initWithFormat:@"http://maps.apple.com/?q=%.5f,%.5f",
    //                           location.coordinate.latitude, location.coordinate.longitude];
    NSString* url = [NSString stringWithFormat: @"http://maps.apple.com/maps?saddr=Current+Location&daddr=%f,%f", location.coordinate.latitude, location.coordinate.longitude];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}
@end
