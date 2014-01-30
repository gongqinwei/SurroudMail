//
//  POITableViewController.h
//  WeiChat
//
//  Created by Qinwei Gong on 1/29/14.
//  Copyright (c) 2014 WeiChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@protocol POIDelegate <NSObject>

- (void)selectedPOI:(NSString *)poi;

@end


@interface POITableViewController : UITableViewController

@property (nonatomic, strong) CLPlacemark *currentLocation;
@property (nonatomic, strong) NSArray *POIs;
@property (nonatomic, strong) id<POIDelegate> poiDelegate;

@end
