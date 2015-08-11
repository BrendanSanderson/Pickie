//
//  CellLocationView.h
//  Pickie
//
//  Created by Brendan Sanderson on 7/6/15.
//  Copyright (c) 2015 Brendan Sanderson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CellLocationView : UITableViewCell
{
    
}
@property (nonatomic) IBOutlet UILabel* distanceLabel;
@property (nonatomic) IBOutlet UILabel* directionLabel;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;

@end