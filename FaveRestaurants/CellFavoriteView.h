//
//  UITableCellView+CellLocationView.h
//  FaveRestaurants
//
//  Created by Henry Sanderson on 7/15/15.
//  Copyright (c) 2015 King_B. All rights reserved.
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